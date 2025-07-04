# Quick Whisper.cpp Performance Test
# Simple comparison between original and Intel optimized builds
# Usage: .\quick_benchmark.ps1 [-AudioFile "path\to\audio.wav"] [-Model "path\to\model.bin"]

param(
    [string]$AudioFile = "samples\jfk.wav",
    [string]$Model = "models\ggml-base.en.bin",
    [switch]$BuildFirst
)

function Write-ColorOutput {
    param([string]$Text, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Text -ForegroundColor Red }
        "Green" { Write-Host $Text -ForegroundColor Green }
        "Yellow" { Write-Host $Text -ForegroundColor Yellow }
        "Blue" { Write-Host $Text -ForegroundColor Blue }
        "Cyan" { Write-Host $Text -ForegroundColor Cyan }
        default { Write-Host $Text }
    }
}

Write-ColorOutput "=== Quick Whisper.cpp Performance Test ===" "Cyan"
Write-Host ""

# Check if files exist
if (!(Test-Path $AudioFile)) {
    Write-ColorOutput "Audio file not found: $AudioFile" "Red"
    Write-Host "Available audio files:"
    Get-ChildItem -Path "samples" -Filter "*.wav" | ForEach-Object { Write-Host "  samples\$($_.Name)" }
    exit 1
}

if (!(Test-Path $Model)) {
    Write-ColorOutput "Model file not found: $Model" "Red"
    Write-Host "Please download a model first. Example:"
    Write-Host "  Invoke-WebRequest -Uri 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin' -OutFile 'models\ggml-base.en.bin'"
    exit 1
}

Write-ColorOutput "Using audio file: $AudioFile" "Green"
Write-ColorOutput "Using model: $Model" "Green"
Write-Host ""

# Build configurations if requested
if ($BuildFirst) {
    Write-ColorOutput "Building configurations..." "Yellow"

    # Original build
    Write-Host "Building original configuration..."
    cmake -B build_original -DCMAKE_BUILD_TYPE=Release -DWHISPER_BUILD_EXAMPLES=ON | Out-Null
    cmake --build build_original --config Release --parallel | Out-Null

    # Intel optimized build
    Write-Host "Building Intel optimized configuration..."
    cmake -B build_intel -DCMAKE_BUILD_TYPE=Release -DWHISPER_BUILD_EXAMPLES=ON -DWHISPER_MKL=ON -DWHISPER_IPP=ON -DWHISPER_TBB=ON | Out-Null
    cmake --build build_intel --config Release --parallel | Out-Null

    Write-ColorOutput "Builds completed!" "Green"
    Write-Host ""
}

# Test function
function Test-Configuration {
    param([string]$Name, [string]$ExePath, [string]$Color)

    Write-ColorOutput "Testing $Name..." $Color

    if (!(Test-Path $ExePath)) {
        Write-ColorOutput "Executable not found: $ExePath" "Red"
        return $null
    }

    $startTime = Get-Date
    $output = & $ExePath -m $Model -f $AudioFile 2>&1
    $endTime = Get-Date

    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "Test failed for $Name" "Red"
        return $null
    }

    $duration = ($endTime - $startTime).TotalSeconds

    # Extract performance metrics
    $totalTime = $null
    $output | ForEach-Object {
        if ($_ -match "whisper_print_timings:\s+total time\s+=\s+(\d+\.\d+)\s*ms") {
            $totalTime = [float]$matches[1]
        }
    }

    Write-ColorOutput "  Duration: $([math]::Round($duration, 2)) seconds" $Color
    if ($totalTime) {
        Write-ColorOutput "  Processing time: $([math]::Round($totalTime, 1)) ms" $Color
    }

    return @{
        'name' = $Name
        'duration' = $duration
        'processing_time' = $totalTime
    }
}

# Run tests
$results = @()

# Test original build
$originalResult = Test-Configuration -Name "Original Build" -ExePath "build_original\bin\Release\whisper-cli.exe" -Color "Blue"
if ($originalResult) { $results += $originalResult }

Write-Host ""

# Test Intel optimized build
$intelResult = Test-Configuration -Name "Intel Optimized Build" -ExePath "build_intel\bin\Release\whisper-cli.exe" -Color "Green"
if ($intelResult) { $results += $intelResult }

# Compare results
if ($results.Count -eq 2) {
    Write-Host ""
    Write-ColorOutput "=== Performance Comparison ===" "Cyan"

    $original = $results[0]
    $intel = $results[1]

    if ($original.processing_time -and $intel.processing_time) {
        $improvement = (($original.processing_time - $intel.processing_time) / $original.processing_time) * 100

        if ($improvement -gt 0) {
            Write-ColorOutput "Intel build is $([math]::Round($improvement, 1))% FASTER" "Green"
        } else {
            Write-ColorOutput "Intel build is $([math]::Round(-$improvement, 1))% slower" "Red"
        }
    }

    $durationImprovement = (($original.duration - $intel.duration) / $original.duration) * 100
    if ($durationImprovement -gt 0) {
        Write-ColorOutput "Overall execution is $([math]::Round($durationImprovement, 1))% faster" "Green"
    } else {
        Write-ColorOutput "Overall execution is $([math]::Round(-$durationImprovement, 1))% slower" "Red"
    }
}

Write-Host ""
Write-ColorOutput "Test completed!" "Cyan"
