#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick performance comparison between baseline and Intel-optimized builds

.DESCRIPTION
    This script builds both baseline and Intel-optimized configurations,
    then runs a quick performance comparison using the JFK audio sample.
    Perfect for demonstrating the performance improvements from Intel optimizations.

.PARAMETER SkipBuild
    Skip building, use existing binaries

.PARAMETER AudioFile
    Audio file to use for testing (default: samples/jfk.wav)

.PARAMETER Iterations
    Number of test iterations (default: 3)

.EXAMPLE
    ./quick-compare.ps1
    Build and compare baseline vs Intel-optimized

.EXAMPLE
    ./quick-compare.ps1 -SkipBuild -Iterations 5
    Compare existing builds with 5 iterations
#>

param(
    [switch]$SkipBuild,
    [string]$AudioFile = "samples/jfk.wav",
    [int]$Iterations = 3
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "Cyan" }
    }
    Write-Host "[$timestamp] " -ForegroundColor Gray -NoNewline
    Write-Host "[$Level] " -ForegroundColor $color -NoNewline
    Write-Host $Message
}

function Test-Prerequisites {
    Write-Log "Checking prerequisites..."

    # Check if we're in the right directory
    if (-not (Test-Path "CMakeLists.txt")) {
        throw "Not in whisper.cpp root directory"
    }

    # Check for required tools
    $tools = @("cmake", "ninja")
    foreach ($tool in $tools) {
        try {
            & $tool --version 2>&1 | Out-Null
            Write-Log "✓ $tool available"
        }
        catch {
            throw "$tool is required but not found"
        }
    }

    # Check for audio file
    if (-not (Test-Path $AudioFile)) {
        throw "Audio file not found: $AudioFile"
    }

    # Check for model file
    $modelPaths = @(
        "models/ggml-base.en.bin",
        "models/ggml-base.bin",
        "models/ggml-tiny.en.bin",
        "models/ggml-tiny.bin"
    )

    $modelFound = $false
    $modelPath = ""
    foreach ($path in $modelPaths) {
        if (Test-Path $path) {
            $modelPath = $path
            $modelFound = $true
            break
        }
    }

    if (-not $modelFound) {
        Write-Log "No model file found. Please download a model to the models/ directory" "ERROR"
        Write-Log "Available model paths checked: $($modelPaths -join ', ')" "ERROR"
        throw "Model file required for testing"
    }

    Write-Log "✓ Using model: $modelPath" "SUCCESS"
    return $modelPath
}

function Build-Configuration {
    param([string]$PresetName, [string]$ConfigName)

    Write-Log "Building $ConfigName configuration..."

    try {
        # Configure
        Write-Log "Configuring with preset: $PresetName"
        $output = & cmake --preset $PresetName 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Configuration failed: $output" "ERROR"
            return $false
        }

        # Build
        Write-Log "Building..."
        $buildDir = "out/build/$PresetName"
        $output = & cmake --build $buildDir --config Release 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Build failed: $output" "ERROR"
            return $false
        }

        Write-Log "✓ $ConfigName build completed" "SUCCESS"
        return $true

    }
    catch {
        Write-Log "Build exception: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-ExecutablePath {
    param([string]$PresetName)

    $possiblePaths = @(
        "out/build/$PresetName/main.exe",
        "out/build/$PresetName/bin/main.exe",
        "out/build/$PresetName/bin/Release/main.exe",
        "out/build/$PresetName/Release/main.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Measure-TranscriptionPerformance {
    param([string]$ExecutablePath, [string]$ModelPath, [string]$AudioPath, [string]$ConfigName, [int]$Iteration)

    Write-Log "  Running iteration $Iteration for $ConfigName..."

    $arguments = @(
        "-m", $ModelPath,
        "-f", $AudioPath,
        "--print-progress"
    )

    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $ExecutablePath
        $processInfo.Arguments = ($arguments -join " ")
        $processInfo.UseShellExecute = $false
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null
        $output = $process.StandardOutput.ReadToEnd()
        $errorOutput = $process.StandardError.ReadToEnd()

        $process.WaitForExit()
        $stopwatch.Stop()

        # Extract transcribed text
        $transcriptionText = ""
        $lines = $output -split "`n"
        foreach ($line in $lines) {
            if ($line -match "\[[\d:.]+\s*-->\s*[\d:.]+\]\s*(.+)") {
                $transcriptionText += $matches[1].Trim() + " "
            }
        }

        # Extract model load time if available
        $modelLoadTime = 0
        if ($output -match "load time\s*=\s*([\d.]+)\s*ms") {
            $modelLoadTime = [float]$matches[1]
        }

        return @{
            Success           = ($process.ExitCode -eq 0)
            TranscriptionTime = $stopwatch.ElapsedMilliseconds
            ModelLoadTime     = $modelLoadTime
            TranscriptionText = $transcriptionText.Trim()
            Output            = $output
            Error             = $errorOutput
        }

    }
    catch {
        Write-Log "Error during test: $($_.Exception.Message)" "ERROR"
        return @{
            Success           = $false
            TranscriptionTime = 0
            ModelLoadTime     = 0
            TranscriptionText = ""
            Output            = ""
            Error             = $_.Exception.Message
        }
    }
}

function Show-Results {
    param([hashtable]$BaselineResults, [hashtable]$IntelResults)

    Write-Host "`n" + "="*80 -ForegroundColor Cyan
    Write-Host " PERFORMANCE COMPARISON RESULTS" -ForegroundColor Cyan
    Write-Host "="*80 -ForegroundColor Cyan

    Write-Host "`nTest Configuration:" -ForegroundColor Yellow
    Write-Host "  Audio File: $AudioFile"
    Write-Host "  Iterations: $Iterations"
    Write-Host "  Test Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    # Calculate statistics
    $baselineTimes = $BaselineResults.Times
    $intelTimes = $IntelResults.Times

    $baselineAvg = ($baselineTimes | Measure-Object -Average).Average
    $intelAvg = ($intelTimes | Measure-Object -Average).Average

    $baselineMin = ($baselineTimes | Measure-Object -Minimum).Minimum
    $intelMin = ($intelTimes | Measure-Object -Minimum).Minimum

    Write-Host "`n" + "-"*60 -ForegroundColor Green
    Write-Host "BASELINE BUILD RESULTS" -ForegroundColor Green
    Write-Host "-"*60 -ForegroundColor Green
    Write-Host "  Executable: $($BaselineResults.ExecutablePath)"
    Write-Host "  Successful Runs: $($BaselineResults.SuccessfulRuns)/$Iterations"
    Write-Host "  Average Time: $([math]::Round($baselineAvg, 2)) ms"
    Write-Host "  Best Time: $baselineMin ms"
    Write-Host "  Transcription: '$($BaselineResults.SampleTranscription)'"

    Write-Host "`n" + "-"*60 -ForegroundColor Blue
    Write-Host "INTEL OPTIMIZED BUILD RESULTS" -ForegroundColor Blue
    Write-Host "-"*60 -ForegroundColor Blue
    Write-Host "  Executable: $($IntelResults.ExecutablePath)"
    Write-Host "  Successful Runs: $($IntelResults.SuccessfulRuns)/$Iterations"
    Write-Host "  Average Time: $([math]::Round($intelAvg, 2)) ms"
    Write-Host "  Best Time: $intelMin ms"
    Write-Host "  Transcription: '$($IntelResults.SampleTranscription)'"

    # Performance comparison
    Write-Host "`n" + "="*60 -ForegroundColor Magenta
    Write-Host "PERFORMANCE IMPROVEMENT" -ForegroundColor Magenta
    Write-Host "="*60 -ForegroundColor Magenta

    if ($baselineAvg -gt 0 -and $intelAvg -gt 0) {
        $speedup = $baselineAvg / $intelAvg
        $improvement = ((1 - (1 / $speedup)) * 100)

        Write-Host "  Average Performance:" -ForegroundColor Yellow
        Write-Host "    Baseline: $([math]::Round($baselineAvg, 1)) ms"
        Write-Host "    Intel:    $([math]::Round($intelAvg, 1)) ms"

        if ($speedup -gt 1) {
            Write-Host "    Speedup:  $([math]::Round($speedup, 2))x faster" -ForegroundColor Green
            Write-Host "    Improvement: $([math]::Round($improvement, 1))% faster" -ForegroundColor Green
        }
        else {
            $slowdown = $intelAvg / $baselineAvg
            Write-Host "    Slowdown: $([math]::Round($slowdown, 2))x slower" -ForegroundColor Red
        }

        # Best time comparison
        $bestSpeedup = $baselineMin / $intelMin
        Write-Host "`n  Best Run Performance:"
        Write-Host "    Baseline: $baselineMin ms"
        Write-Host "    Intel:    $intelMin ms"

        if ($bestSpeedup -gt 1) {
            Write-Host "    Best Speedup: $([math]::Round($bestSpeedup, 2))x faster" -ForegroundColor Green
        }

        # Audio processing rate
        $audioFile = Get-Item $AudioFile
        $audioDuration = 11  # JFK sample is 11 seconds, could be dynamic

        $baselineRate = $audioDuration / ($baselineAvg / 1000)
        $intelRate = $audioDuration / ($intelAvg / 1000)

        Write-Host "`n  Audio Processing Rate:"
        Write-Host "    Baseline: $([math]::Round($baselineRate, 2))x realtime"
        Write-Host "    Intel:    $([math]::Round($intelRate, 2))x realtime"

    }
    else {
        Write-Host "  Unable to calculate performance comparison due to test failures" -ForegroundColor Red
    }

    Write-Host "`n" + "="*80 -ForegroundColor Cyan
}

# Main execution
try {
    Write-Log "Starting Quick Performance Comparison" "SUCCESS"

    # Check prerequisites
    $modelPath = Test-Prerequisites

    # Build configurations if not skipping
    if (-not $SkipBuild) {
        Write-Log "Building configurations..."

        # Build baseline
        $baselineBuildSuccess = Build-Configuration "default" "Baseline"

        # Build Intel optimized
        $intelBuildSuccess = Build-Configuration "ninja-intel-optimized" "Intel Optimized"

        if (-not $baselineBuildSuccess -and -not $intelBuildSuccess) {
            throw "Both builds failed"
        }

        if (-not $baselineBuildSuccess) {
            Write-Log "Baseline build failed, will try to use existing binary" "WARN"
        }

        if (-not $intelBuildSuccess) {
            Write-Log "Intel build failed, will try to use existing binary" "WARN"
        }
    }

    # Find executables
    $baselineExe = Get-ExecutablePath "default"
    $intelExe = Get-ExecutablePath "ninja-intel-optimized"

    # Fallback to current build if others not found
    if (-not $baselineExe) {
        $baselineExe = "build/bin/Release/main.exe"
        if (-not (Test-Path $baselineExe)) {
            $baselineExe = $null
        }
    }

    if (-not $intelExe -and (Test-Path "build/bin/Release/main.exe")) {
        Write-Log "Using current build as Intel optimized (assuming it has Intel optimizations)" "WARN"
        $intelExe = "build/bin/Release/main.exe"
    }

    if (-not $baselineExe -and -not $intelExe) {
        throw "No executables found to test"
    }

    # Run performance tests
    Write-Log "Running performance tests..."

    $baselineResults = @{
        ExecutablePath      = $baselineExe
        Times               = @()
        SuccessfulRuns      = 0
        SampleTranscription = ""
    }

    $intelResults = @{
        ExecutablePath      = $intelExe
        Times               = @()
        SuccessfulRuns      = 0
        SampleTranscription = ""
    }

    # Test baseline if available
    if ($baselineExe) {
        Write-Log "Testing baseline configuration..."
        for ($i = 1; $i -le $Iterations; $i++) {
            $result = Measure-TranscriptionPerformance $baselineExe $modelPath $AudioFile "Baseline" $i
            if ($result.Success) {
                $baselineResults.Times += $result.TranscriptionTime
                $baselineResults.SuccessfulRuns++
                if ([string]::IsNullOrEmpty($baselineResults.SampleTranscription)) {
                    $baselineResults.SampleTranscription = $result.TranscriptionText
                }
            }
        }
    }

    # Test Intel optimized if available
    if ($intelExe) {
        Write-Log "Testing Intel optimized configuration..."
        for ($i = 1; $i -le $Iterations; $i++) {
            $result = Measure-TranscriptionPerformance $intelExe $modelPath $AudioFile "Intel" $i
            if ($result.Success) {
                $intelResults.Times += $result.TranscriptionTime
                $intelResults.SuccessfulRuns++
                if ([string]::IsNullOrEmpty($intelResults.SampleTranscription)) {
                    $intelResults.SampleTranscription = $result.TranscriptionText
                }
            }
        }
    }

    # Show results
    Show-Results $baselineResults $intelResults

    Write-Log "Quick comparison completed!" "SUCCESS"

}
catch {
    Write-Log "Quick comparison failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
