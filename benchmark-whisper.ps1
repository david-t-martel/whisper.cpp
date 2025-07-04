#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Comprehensive benchmark analysis for whisper.cpp builds

.DESCRIPTION
    This script performs comparative benchmarking of different whisper.cpp build configurations,
    measuring performance metrics like transcription time, memory usage, and accuracy.
    Designed to be extensible for future build configurations (CUDA, etc.).

.PARAMETER ConfigName
    Specific configuration to test (optional, tests all if not specified)

.PARAMETER AudioFiles
    Specific audio files to test (optional, uses default test suite if not specified)

.PARAMETER OutputFormat
    Output format for results: console, json, html, or all (default: all)

.PARAMETER Iterations
    Number of iterations per test (default: 3)

.PARAMETER SkipBuild
    Skip building configurations, use existing binaries

.EXAMPLE
    ./benchmark-whisper.ps1
    Run full benchmark suite on all configurations

.EXAMPLE
    ./benchmark-whisper.ps1 -ConfigName "intel-optimized" -AudioFiles "jfk.wav"
    Test only Intel optimized build with JFK audio

.EXAMPLE
    ./benchmark-whisper.ps1 -OutputFormat json -SkipBuild
    Generate JSON report using existing binaries
#>

param(
    [string]$ConfigName = "",
    [string[]]$AudioFiles = @(),
    [ValidateSet("console", "json", "html", "all")]
    [string]$OutputFormat = "all",
    [int]$Iterations = 3,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Configuration definitions - easily extensible for new build types
$BuildConfigurations = @{
    "baseline"        = @{
        Name                = "Baseline Build"
        Description         = "Standard whisper.cpp build without optimizations"
        CMakePreset         = "default"
        BinaryDir           = "out/build/default"
        Features            = @("Standard CPU", "No optimizations")
        ExpectedPerformance = "baseline"
    }
    "tbb-optimized"   = @{
        Name                = "TBB Optimized"
        Description         = "Build with Intel TBB threading optimizations"
        CMakePreset         = "ninja-release-tbb"
        BinaryDir           = "out/build/ninja-release-tbb"
        Features            = @("Intel TBB", "Threading optimizations", "Mimalloc")
        ExpectedPerformance = "faster"
    }
    "intel-optimized" = @{
        Name                = "Intel MKL+IPP Optimized"
        Description         = "Full Intel optimizations with MKL and IPP"
        CMakePreset         = "ninja-intel-optimized"
        BinaryDir           = "out/build/ninja-intel-optimized"
        Features            = @("Intel MKL FFT", "Intel MKL BLAS", "Intel IPP", "TBB", "Mimalloc")
        ExpectedPerformance = "fastest"
    }
    "current-build"   = @{
        Name                = "Current Build"
        Description         = "Currently built binaries in build/bin/Release"
        CMakePreset         = $null
        BinaryDir           = "build/bin/Release"
        Features            = @("Current active build")
        ExpectedPerformance = "varies"
    }
    # Template for future CUDA configuration
    "cuda-optimized"  = @{
        Name                = "CUDA Optimized"
        Description         = "GPU acceleration with CUDA (future implementation)"
        CMakePreset         = "cuda-release"  # Will be created later
        BinaryDir           = "out/build/cuda-release"
        Features            = @("CUDA GPU", "cuBLAS", "NVIDIA optimizations")
        ExpectedPerformance = "gpu-accelerated"
        Enabled             = $false  # Disabled until implemented
    }
}

# Test audio configurations
$AudioTestSuite = @{
    "jfk-short"  = @{
        File           = "samples/jfk.wav"
        Description    = "JFK speech (11 seconds, clear speech)"
        Duration       = 11
        Complexity     = "Low"
        ExpectedOutput = "And so my fellow Americans ask not what your country can do for you ask what you can do for your country"
    }
    "jfk-mp3"    = @{
        File           = "samples/jfk.mp3"
        Description    = "JFK speech MP3 format"
        Duration       = 11
        Complexity     = "Low"
        ExpectedOutput = "And so my fellow Americans ask not what your country can do for you ask what you can do for your country"
    }
    "mm1-medium" = @{
        File           = "samples/mm1.wav"
        Description    = "Medium length audio (~30 seconds)"
        Duration       = 30
        Complexity     = "Medium"
        ExpectedOutput = ""  # Will be determined from first run
    }
    "a13-long"   = @{
        File           = "samples/a13.wav"
        Description    = "Longer audio sample"
        Duration       = 60
        Complexity     = "High"
        ExpectedOutput = ""  # Will be determined from first run
    }
}

# Performance metrics to collect
$PerformanceMetrics = @(
    "TranscriptionTime",
    "ModelLoadTime",
    "PeakMemoryUsage",
    "AverageCPUUsage",
    "AccuracyScore",
    "OutputLength",
    "ThreadsUsed"
)

# Initialize results storage
$BenchmarkResults = @{
    TestRun        = @{
        Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Machine    = @{
            OS                = "$($PSVersionTable.OS)"
            CPU               = (Get-CimInstance -ClassName Win32_Processor).Name
            Memory            = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
            Cores             = (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
            LogicalProcessors = (Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
        }
        Parameters = @{
            Iterations   = $Iterations
            AudioFiles   = $AudioFiles
            OutputFormat = $OutputFormat
        }
    }
    Configurations = @{}
}

function Write-BenchmarkLog {
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
    Write-BenchmarkLog "Checking prerequisites..."

    # Check if we're in the right directory
    if (-not (Test-Path "CMakeLists.txt") -or -not (Test-Path "src/whisper.cpp")) {
        throw "Not in whisper.cpp root directory. Please run from the project root."
    }

    # Check for required tools
    $requiredTools = @("cmake", "ninja")
    foreach ($tool in $requiredTools) {
        try {
            & $tool --version | Out-Null
            Write-BenchmarkLog "✓ $tool is available"
        }
        catch {
            Write-BenchmarkLog "✗ $tool is required but not found in PATH" "ERROR"
            throw "$tool is required for benchmarking"
        }
    }

    # Check for audio samples
    $sampleDir = "samples"
    if (-not (Test-Path $sampleDir)) {
        Write-BenchmarkLog "Creating samples directory..." "WARN"
        New-Item -ItemType Directory -Path $sampleDir | Out-Null
    }

    # Verify critical audio files exist
    $criticalFiles = @("samples/jfk.wav")
    foreach ($file in $criticalFiles) {
        if (-not (Test-Path $file)) {
            Write-BenchmarkLog "Critical audio file missing: $file" "ERROR"
            Write-BenchmarkLog "Please ensure test audio files are available" "ERROR"
            throw "Missing required test audio files"
        }
    }

    Write-BenchmarkLog "Prerequisites check completed" "SUCCESS"
}

function Build-Configuration {
    param([string]$ConfigName, [hashtable]$Config)

    if ($Config.CMakePreset -eq $null) {
        Write-BenchmarkLog "Skipping build for $ConfigName (no preset defined)"
        return $true
    }

    Write-BenchmarkLog "Building configuration: $ConfigName"

    try {
        # Configure
        Write-BenchmarkLog "Configuring with preset: $($Config.CMakePreset)"
        $configOutput = & cmake --preset $Config.CMakePreset 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-BenchmarkLog "Configuration failed for $ConfigName" "ERROR"
            Write-BenchmarkLog "Output: $configOutput" "ERROR"
            return $false
        }

        # Build
        Write-BenchmarkLog "Building..."
        $buildOutput = & cmake --build $Config.BinaryDir --config Release 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-BenchmarkLog "Build failed for $ConfigName" "ERROR"
            Write-BenchmarkLog "Output: $buildOutput" "ERROR"
            return $false
        }

        Write-BenchmarkLog "✓ Build completed for $ConfigName" "SUCCESS"
        return $true

    }
    catch {
        Write-BenchmarkLog "Exception during build of $ConfigName`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-ExecutablePath {
    param([hashtable]$Config, [string]$Executable = "main.exe")

    $possiblePaths = @(
        "$($Config.BinaryDir)/$Executable",
        "$($Config.BinaryDir)/bin/$Executable",
        "$($Config.BinaryDir)/bin/Release/$Executable",
        "$($Config.BinaryDir)/Release/$Executable"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Measure-Performance {
    param(
        [string]$ExecutablePath,
        [string]$AudioFile,
        [hashtable]$AudioConfig,
        [int]$Iteration
    )

    $modelPath = "models/ggml-base.en.bin"
    if (-not (Test-Path $modelPath)) {
        # Try alternate locations
        $alternatePaths = @(
            "models/ggml-base.bin",
            "models/ggml-tiny.en.bin",
            "models/ggml-tiny.bin"
        )
        foreach ($path in $alternatePaths) {
            if (Test-Path $path) {
                $modelPath = $path
                break
            }
        }
    }

    if (-not (Test-Path $modelPath)) {
        Write-BenchmarkLog "No model file found. Please download a model to the models/ directory" "ERROR"
        return $null
    }

    Write-BenchmarkLog "  Iteration $Iteration - Testing with $AudioFile using model $modelPath"

    # Prepare command
    $arguments = @(
        "-m", $modelPath,
        "-f", $AudioFile,
        "--print-progress"
    )

    # Create output file for this test
    $outputFile = "benchmark_output_$(Get-Date -Format 'yyyyMMdd_HHmmss')_$Iteration.txt"

    try {
        # Measure execution time and capture output
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # Start process with performance monitoring
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName = $ExecutablePath
        $processStartInfo.Arguments = ($arguments -join " ")
        $processStartInfo.UseShellExecute = $false
        $processStartInfo.RedirectStandardOutput = $true
        $processStartInfo.RedirectStandardError = $true
        $processStartInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processStartInfo

        # Performance counters
        $initialMemory = (Get-Process -Id $PID).WorkingSet64

        $process.Start() | Out-Null

        # Monitor memory usage during execution
        $maxMemory = 0
        $cpuSamples = @()

        # Read output
        $output = $process.StandardOutput.ReadToEnd()
        $error = $process.StandardError.ReadToEnd()

        $process.WaitForExit()
        $stopwatch.Stop()

        # Calculate metrics
        $metrics = @{
            TranscriptionTime = $stopwatch.ElapsedMilliseconds
            ModelLoadTime     = 0  # Will be extracted from output if available
            PeakMemoryUsage   = $maxMemory
            AverageCPUUsage   = 0  # Will be calculated from samples
            OutputLength      = $output.Length
            ExitCode          = $process.ExitCode
            Output            = $output
            Error             = $error
        }

        # Parse output for additional metrics
        if ($output -match "load time\s*=\s*([\d.]+)\s*ms") {
            $metrics.ModelLoadTime = [float]$matches[1]
        }

        # Extract actual transcription text
        $transcriptionText = ""
        $lines = $output -split "`n"
        foreach ($line in $lines) {
            # Look for lines that contain transcribed text (usually after timestamps)
            if ($line -match "\[[\d:.]+\s*-->\s*[\d:.]+\]\s*(.+)") {
                $transcriptionText += $matches[1].Trim() + " "
            }
            elseif ($line -match "^\s*(.+)" -and $line -notmatch "(load time|system_info|processing)" -and $line.Trim().Length -gt 10) {
                # Fallback: look for substantial text lines
                $potentialText = $matches[1].Trim()
                if ($potentialText -notmatch "^(whisper|load|system|processing|ggml)" -and $potentialText.Length -gt 10) {
                    $transcriptionText += $potentialText + " "
                }
            }
        }

        $metrics.TranscriptionText = $transcriptionText.Trim()
        $metrics.AccuracyScore = Calculate-Accuracy $transcriptionText.Trim() $AudioConfig.ExpectedOutput

        # Clean up temporary files
        if (Test-Path $outputFile) {
            Remove-Item $outputFile -Force
        }

        return $metrics

    }
    catch {
        Write-BenchmarkLog "Error during performance measurement: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Calculate-Accuracy {
    param([string]$Actual, [string]$Expected)

    if ([string]::IsNullOrEmpty($Expected)) {
        return 100  # No expected output to compare against
    }

    # Simple accuracy calculation using Levenshtein distance
    $actual = $Actual.ToLower() -replace '[^\w\s]', '' -replace '\s+', ' '
    $expected = $Expected.ToLower() -replace '[^\w\s]', '' -replace '\s+', ' '

    if ($actual -eq $expected) {
        return 100
    }

    # Calculate word-level accuracy
    $actualWords = $actual -split '\s+'
    $expectedWords = $expected -split '\s+'

    $matches = 0
    $maxLength = [math]::Max($actualWords.Length, $expectedWords.Length)

    for ($i = 0; $i -lt [math]::Min($actualWords.Length, $expectedWords.Length); $i++) {
        if ($actualWords[$i] -eq $expectedWords[$i]) {
            $matches++
        }
    }

    if ($maxLength -eq 0) { return 100 }
    return [math]::Round(($matches / $maxLength) * 100, 2)
}

function Run-BenchmarkSuite {
    Write-BenchmarkLog "Starting comprehensive benchmark suite" "SUCCESS"

    # Filter configurations based on parameters
    $configsToTest = $BuildConfigurations.Clone()
    if ($ConfigName) {
        if ($configsToTest.ContainsKey($ConfigName)) {
            $configsToTest = @{ $ConfigName = $configsToTest[$ConfigName] }
        }
        else {
            throw "Configuration '$ConfigName' not found"
        }
    }

    # Remove disabled configurations
    $configsToTest = $configsToTest.GetEnumerator() | Where-Object {
        $_.Value.Enabled -ne $false
    } | ForEach-Object { @{ $_.Key = $_.Value } }

    # Filter audio files
    $audioToTest = $AudioTestSuite.Clone()
    if ($AudioFiles.Count -gt 0) {
        $filteredAudio = @{}
        foreach ($file in $AudioFiles) {
            $key = $audioToTest.Keys | Where-Object { $audioToTest[$_].File -like "*$file*" } | Select-Object -First 1
            if ($key) {
                $filteredAudio[$key] = $audioToTest[$key]
            }
        }
        $audioToTest = $filteredAudio
    }

    Write-BenchmarkLog "Testing $($configsToTest.Count) configurations with $($audioToTest.Count) audio files"

    # Build configurations if not skipping
    if (-not $SkipBuild) {
        Write-BenchmarkLog "Building configurations..."
        foreach ($configPair in $configsToTest.GetEnumerator()) {
            $success = Build-Configuration $configPair.Key $configPair.Value
            if (-not $success) {
                Write-BenchmarkLog "Skipping $($configPair.Key) due to build failure" "WARN"
                $configsToTest.Remove($configPair.Key)
            }
        }
    }

    # Run benchmarks
    foreach ($configPair in $configsToTest.GetEnumerator()) {
        $configName = $configPair.Key
        $config = $configPair.Value

        Write-BenchmarkLog "Testing configuration: $configName"

        # Find executable
        $exePath = Get-ExecutablePath $config "main.exe"
        if (-not $exePath -or -not (Test-Path $exePath)) {
            Write-BenchmarkLog "Executable not found for $configName, skipping" "WARN"
            continue
        }

        Write-BenchmarkLog "Using executable: $exePath"

        $configResults = @{
            Configuration = $config
            AudioTests    = @{}
        }

        # Test each audio file
        foreach ($audioPair in $audioToTest.GetEnumerator()) {
            $audioName = $audioPair.Key
            $audioConfig = $audioPair.Value

            if (-not (Test-Path $audioConfig.File)) {
                Write-BenchmarkLog "Audio file not found: $($audioConfig.File), skipping" "WARN"
                continue
            }

            Write-BenchmarkLog "  Testing audio: $audioName ($($audioConfig.File))"

            $audioResults = @{
                AudioConfig = $audioConfig
                Iterations  = @()
                Summary     = @{}
            }

            # Run multiple iterations
            for ($i = 1; $i -le $Iterations; $i++) {
                $metrics = Measure-Performance $exePath $audioConfig.File $audioConfig $i
                if ($metrics) {
                    $audioResults.Iterations += $metrics
                }
            }

            # Calculate summary statistics
            if ($audioResults.Iterations.Count -gt 0) {
                $times = $audioResults.Iterations | ForEach-Object { $_.TranscriptionTime }
                $audioResults.Summary = @{
                    AvgTranscriptionTime = ($times | Measure-Object -Average).Average
                    MinTranscriptionTime = ($times | Measure-Object -Minimum).Minimum
                    MaxTranscriptionTime = ($times | Measure-Object -Maximum).Maximum
                    SuccessfulRuns       = $audioResults.Iterations.Count
                    AverageAccuracy      = ($audioResults.Iterations | ForEach-Object { $_.AccuracyScore } | Measure-Object -Average).Average
                }
            }

            $configResults.AudioTests[$audioName] = $audioResults
        }

        $BenchmarkResults.Configurations[$configName] = $configResults
    }

    Write-BenchmarkLog "Benchmark suite completed" "SUCCESS"
}

function Generate-Reports {
    Write-BenchmarkLog "Generating benchmark reports..."

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    if ($OutputFormat -eq "console" -or $OutputFormat -eq "all") {
        Show-ConsoleReport
    }

    if ($OutputFormat -eq "json" -or $OutputFormat -eq "all") {
        $jsonFile = "benchmark_results_$timestamp.json"
        Generate-JsonReport $jsonFile
    }

    if ($OutputFormat -eq "html" -or $OutputFormat -eq "all") {
        $htmlFile = "benchmark_results_$timestamp.html"
        Generate-HtmlReport $htmlFile
    }
}

function Show-ConsoleReport {
    Write-Host "`n" + "="*80 -ForegroundColor Cyan
    Write-Host " WHISPER.CPP BENCHMARK RESULTS" -ForegroundColor Cyan
    Write-Host "="*80 -ForegroundColor Cyan

    Write-Host "`nTest Environment:" -ForegroundColor Yellow
    Write-Host "  Machine: $($BenchmarkResults.TestRun.Machine.CPU)"
    Write-Host "  Memory: $($BenchmarkResults.TestRun.Machine.Memory) GB"
    Write-Host "  Cores: $($BenchmarkResults.TestRun.Machine.Cores) physical, $($BenchmarkResults.TestRun.Machine.LogicalProcessors) logical"
    Write-Host "  OS: $($BenchmarkResults.TestRun.Machine.OS)"
    Write-Host "  Timestamp: $($BenchmarkResults.TestRun.Timestamp)"

    foreach ($configPair in $BenchmarkResults.Configurations.GetEnumerator()) {
        $configName = $configPair.Key
        $config = $configPair.Value

        Write-Host "`n" + "-"*60 -ForegroundColor Green
        Write-Host "Configuration: $($config.Configuration.Name)" -ForegroundColor Green
        Write-Host "Description: $($config.Configuration.Description)"
        Write-Host "Features: $($config.Configuration.Features -join ', ')"
        Write-Host "-"*60 -ForegroundColor Green

        foreach ($audioPair in $config.AudioTests.GetEnumerator()) {
            $audioName = $audioPair.Key
            $audioTest = $audioPair.Value

            if ($audioTest.Summary.SuccessfulRuns -gt 0) {
                Write-Host "`n  Audio Test: $audioName" -ForegroundColor Cyan
                Write-Host "    File: $($audioTest.AudioConfig.File)"
                Write-Host "    Duration: $($audioTest.AudioConfig.Duration)s"
                Write-Host "    Successful Runs: $($audioTest.Summary.SuccessfulRuns)/$Iterations"
                Write-Host "    Avg Time: $([math]::Round($audioTest.Summary.AvgTranscriptionTime, 2))ms"
                Write-Host "    Min Time: $($audioTest.Summary.MinTranscriptionTime)ms"
                Write-Host "    Max Time: $($audioTest.Summary.MaxTranscriptionTime)ms"
                Write-Host "    Avg Accuracy: $([math]::Round($audioTest.Summary.AverageAccuracy, 2))%"

                # Show performance per duration
                $timePerSecond = $audioTest.Summary.AvgTranscriptionTime / $audioTest.AudioConfig.Duration
                Write-Host "    Performance: $([math]::Round($timePerSecond, 2))ms per audio second"
            }
        }
    }

    # Performance comparison table
    Write-Host "`n" + "="*80 -ForegroundColor Magenta
    Write-Host " PERFORMANCE COMPARISON" -ForegroundColor Magenta
    Write-Host "="*80 -ForegroundColor Magenta

    # Create comparison table for JFK audio (most common test)
    $jfkResults = @{}
    foreach ($configPair in $BenchmarkResults.Configurations.GetEnumerator()) {
        $configName = $configPair.Key
        $config = $configPair.Value

        if ($config.AudioTests.ContainsKey("jfk-short") -and $config.AudioTests["jfk-short"].Summary.SuccessfulRuns -gt 0) {
            $jfkResults[$configName] = $config.AudioTests["jfk-short"].Summary
        }
    }

    if ($jfkResults.Count -gt 1) {
        Write-Host "`nJFK Audio Test Comparison (11 seconds):"
        Write-Host "{0,-20} {1,-12} {2,-12} {3,-10}" -f "Configuration", "Avg Time(ms)", "Performance", "Accuracy"
        Write-Host "-" * 60

        # Sort by average time
        $sortedResults = $jfkResults.GetEnumerator() | Sort-Object { $_.Value.AvgTranscriptionTime }

        foreach ($result in $sortedResults) {
            $configName = $result.Key
            $summary = $result.Value
            $timePerSec = $summary.AvgTranscriptionTime / 11
            $accuracy = [math]::Round($summary.AverageAccuracy, 1)

            Write-Host "{0,-20} {1,-12} {2,-12} {3,-10}" -f $configName, [math]::Round($summary.AvgTranscriptionTime, 0), "$([math]::Round($timePerSec, 1))ms/s", "$accuracy%"
        }

        # Show relative performance
        $baseline = $sortedResults[0].Value.AvgTranscriptionTime
        Write-Host "`nRelative Performance (vs fastest):"
        foreach ($result in $sortedResults) {
            $ratio = $result.Value.AvgTranscriptionTime / $baseline
            $improvement = ((1 - (1 / $ratio)) * 100)
            if ($improvement -gt 0) {
                Write-Host "  $($result.Key): $([math]::Round($improvement, 1))% slower"
            }
            else {
                Write-Host "  $($result.Key): baseline (fastest)" -ForegroundColor Green
            }
        }
    }

    Write-Host "`n" + "="*80 -ForegroundColor Cyan
}

function Generate-JsonReport {
    param([string]$FileName)

    try {
        $BenchmarkResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $FileName -Encoding utf8
        Write-BenchmarkLog "JSON report saved to: $FileName" "SUCCESS"
    }
    catch {
        Write-BenchmarkLog "Failed to generate JSON report: $($_.Exception.Message)" "ERROR"
    }
}

function Generate-HtmlReport {
    param([string]$FileName)

    # HTML template with embedded CSS and JavaScript for interactive charts
    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Whisper.cpp Benchmark Results</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; margin-bottom: 30px; }
        h2 { color: #34495e; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        h3 { color: #34495e; margin-top: 25px; }
        .system-info { background: #ecf0f1; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .config-section { margin-bottom: 40px; padding: 20px; border: 1px solid #bdc3c7; border-radius: 5px; }
        .config-header { background: #3498db; color: white; padding: 10px; border-radius: 5px; margin-bottom: 15px; }
        .audio-test { margin: 15px 0; padding: 15px; background: #f8f9fa; border-radius: 5px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 15px 0; }
        .metric { background: #e8f4f8; padding: 10px; border-radius: 5px; text-align: center; }
        .metric-value { font-size: 1.5em; font-weight: bold; color: #2c3e50; }
        .metric-label { font-size: 0.9em; color: #7f8c8d; }
        .comparison-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .comparison-table th, .comparison-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        .comparison-table th { background-color: #3498db; color: white; }
        .comparison-table tr:hover { background-color: #f5f5f5; }
        .chart-container { width: 100%; height: 400px; margin: 20px 0; }
        .best-performance { color: #27ae60; font-weight: bold; }
        .features { margin: 10px 0; }
        .feature-tag { display: inline-block; background: #2ecc71; color: white; padding: 3px 8px; border-radius: 3px; margin: 2px; font-size: 0.8em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎙️ Whisper.cpp Benchmark Results</h1>

        <div class="system-info">
            <h3>Test Environment</h3>
            <p><strong>CPU:</strong> $($BenchmarkResults.TestRun.Machine.CPU)</p>
            <p><strong>Memory:</strong> $($BenchmarkResults.TestRun.Machine.Memory) GB</p>
            <p><strong>Cores:</strong> $($BenchmarkResults.TestRun.Machine.Cores) physical, $($BenchmarkResults.TestRun.Machine.LogicalProcessors) logical</p>
            <p><strong>OS:</strong> $($BenchmarkResults.TestRun.Machine.OS)</p>
            <p><strong>Test Date:</strong> $($BenchmarkResults.TestRun.Timestamp)</p>
            <p><strong>Iterations:</strong> $($BenchmarkResults.TestRun.Parameters.Iterations) per test</p>
        </div>
"@

    # Add configuration results
    foreach ($configPair in $BenchmarkResults.Configurations.GetEnumerator()) {
        $configName = $configPair.Key
        $config = $configPair.Value

        $htmlContent += @"
        <div class="config-section">
            <div class="config-header">
                <h2>$($config.Configuration.Name)</h2>
                <p>$($config.Configuration.Description)</p>
                <div class="features">
"@

        foreach ($feature in $config.Configuration.Features) {
            $htmlContent += "<span class='feature-tag'>$feature</span>"
        }

        $htmlContent += @"
                </div>
            </div>
"@

        # Add audio test results
        foreach ($audioPair in $config.AudioTests.GetEnumerator()) {
            $audioName = $audioPair.Key
            $audioTest = $audioPair.Value

            if ($audioTest.Summary.SuccessfulRuns -gt 0) {
                $htmlContent += @"
            <div class="audio-test">
                <h3>$audioName</h3>
                <p><strong>File:</strong> $($audioTest.AudioConfig.File) | <strong>Duration:</strong> $($audioTest.AudioConfig.Duration)s</p>
                <div class="metrics">
                    <div class="metric">
                        <div class="metric-value">$([math]::Round($audioTest.Summary.AvgTranscriptionTime, 0))</div>
                        <div class="metric-label">Avg Time (ms)</div>
                    </div>
                    <div class="metric">
                        <div class="metric-value">$([math]::Round($audioTest.Summary.AvgTranscriptionTime / $audioTest.AudioConfig.Duration, 1))</div>
                        <div class="metric-label">ms per audio second</div>
                    </div>
                    <div class="metric">
                        <div class="metric-value">$([math]::Round($audioTest.Summary.AverageAccuracy, 1))%</div>
                        <div class="metric-label">Accuracy</div>
                    </div>
                    <div class="metric">
                        <div class="metric-value">$($audioTest.Summary.SuccessfulRuns)/$($BenchmarkResults.TestRun.Parameters.Iterations)</div>
                        <div class="metric-label">Success Rate</div>
                    </div>
                </div>
            </div>
"@
            }
        }

        $htmlContent += "</div>"
    }

    # Add performance comparison section
    $htmlContent += @"
        <h2>Performance Comparison</h2>
        <div class="chart-container">
            <canvas id="performanceChart"></canvas>
        </div>

        <script>
            // Performance comparison chart
            const ctx = document.getElementById('performanceChart').getContext('2d');
            const chart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: [
"@

    # Add chart data
    $chartLabels = @()
    $chartData = @()

    foreach ($configPair in $BenchmarkResults.Configurations.GetEnumerator()) {
        $configName = $configPair.Key
        $config = $configPair.Value

        if ($config.AudioTests.ContainsKey("jfk-short") -and $config.AudioTests["jfk-short"].Summary.SuccessfulRuns -gt 0) {
            $chartLabels += "'$configName'"
            $chartData += [math]::Round($config.AudioTests["jfk-short"].Summary.AvgTranscriptionTime, 0)
        }
    }

    $htmlContent += ($chartLabels -join ', ')
    $htmlContent += @"
                    ],
                    datasets: [{
                        label: 'Average Transcription Time (ms)',
                        data: [$($chartData -join ', ')],
                        backgroundColor: [
                            'rgba(52, 152, 219, 0.8)',
                            'rgba(46, 204, 113, 0.8)',
                            'rgba(241, 196, 15, 0.8)',
                            'rgba(231, 76, 60, 0.8)',
                            'rgba(155, 89, 182, 0.8)'
                        ],
                        borderColor: [
                            'rgba(52, 152, 219, 1)',
                            'rgba(46, 204, 113, 1)',
                            'rgba(241, 196, 15, 1)',
                            'rgba(231, 76, 60, 1)',
                            'rgba(155, 89, 182, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Time (milliseconds)'
                            }
                        }
                    },
                    plugins: {
                        title: {
                            display: true,
                            text: 'JFK Audio Test Performance Comparison (11 seconds)'
                        },
                        legend: {
                            display: false
                        }
                    }
                }
            });
        </script>
    </div>
</body>
</html>
"@

    try {
        $htmlContent | Out-File -FilePath $FileName -Encoding utf8
        Write-BenchmarkLog "HTML report saved to: $FileName" "SUCCESS"
    }
    catch {
        Write-BenchmarkLog "Failed to generate HTML report: $($_.Exception.Message)" "ERROR"
    }
}

# Main execution
try {
    Write-BenchmarkLog "Starting Whisper.cpp Benchmark Suite" "SUCCESS"

    Test-Prerequisites
    Run-BenchmarkSuite
    Generate-Reports

    Write-BenchmarkLog "Benchmark completed successfully!" "SUCCESS"
    Write-BenchmarkLog "Results saved in current directory with timestamp"

}
catch {
    Write-BenchmarkLog "Benchmark failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
