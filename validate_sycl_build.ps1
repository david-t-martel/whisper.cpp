# Simple SYCL Validation Script for whisper.cpp
# This script runs basic validation tests on the SYCL build

param(
    [Parameter()]
    [string]$ModelPath = "models\ggml-base.en.bin",

    [Parameter()]
    [string]$AudioFile = "samples\jfk.wav"
)

function Write-ColorOutput {
    param([string]$Text, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Text -ForegroundColor Red }
        "Green" { Write-Host $Text -ForegroundColor Green }
        "Yellow" { Write-Host $Text -ForegroundColor Yellow }
        "Blue" { Write-Host $Text -ForegroundColor Blue }
        "Cyan" { Write-Host $Text -ForegroundColor Cyan }
        default { Write-Host $Text -ForegroundColor White }
    }
}

Write-ColorOutput "=== SYCL Validation Tests ===" "Blue"

# Navigate to project directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Check if build exists
if (-not (Test-Path "build")) {
    Write-ColorOutput "❌ Build directory not found. Run quick_sycl_build.ps1 first." "Red"
    exit 1
}

Set-Location "build"

# Test 1: List SYCL devices
Write-ColorOutput "Test 1: Listing SYCL devices..." "Yellow"
$lsSyclDevice = ".\examples\sycl\Release\ls-sycl-device.exe"
if (-not (Test-Path $lsSyclDevice)) {
    $lsSyclDevice = ".\examples\sycl\Debug\ls-sycl-device.exe"
}

if (Test-Path $lsSyclDevice) {
    & $lsSyclDevice
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✅ SYCL device listing successful" "Green"
    }
    else {
        Write-ColorOutput "❌ SYCL device listing failed" "Red"
    }
}
else {
    Write-ColorOutput "⚠️  ls-sycl-device executable not found" "Yellow"
}

# Test 2: Check main executable exists
Write-ColorOutput "`nTest 2: Checking main executable..." "Yellow"
$mainExe = ".\bin\Release\main.exe"
if (-not (Test-Path $mainExe)) {
    $mainExe = ".\bin\Debug\main.exe"
}

if (Test-Path $mainExe) {
    Write-ColorOutput "✅ Main executable found: $mainExe" "Green"

    # Test 3: Quick help test
    Write-ColorOutput "`nTest 3: Testing executable help..." "Yellow"
    & $mainExe --help 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✅ Executable help test passed" "Green"
    }
    else {
        Write-ColorOutput "❌ Executable help test failed" "Red"
    }
}
else {
    Write-ColorOutput "❌ Main executable not found" "Red"
}

# Test 4: Model and audio file availability (if specified)
if ($ModelPath -and $AudioFile) {
    Write-ColorOutput "`nTest 4: Checking model and audio files..." "Yellow"
    Set-Location ".."  # Back to project root

    if (Test-Path $ModelPath) {
        Write-ColorOutput "✅ Model found: $ModelPath" "Green"
    }
    else {
        Write-ColorOutput "⚠️  Model not found: $ModelPath" "Yellow"
        Write-ColorOutput "   Download models using: .\models\download-ggml-model.sh base.en" "Cyan"
    }

    if (Test-Path $AudioFile) {
        Write-ColorOutput "✅ Audio file found: $AudioFile" "Green"

        # Test 5: Quick transcription test
        if ((Test-Path $ModelPath) -and (Test-Path $mainExe)) {
            Write-ColorOutput "`nTest 5: Quick transcription test..." "Yellow"
            $transcriptionResult = & $mainExe -m $ModelPath -f $AudioFile 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Transcription test passed" "Green"
                Write-ColorOutput "Sample output:" "Cyan"
                $transcriptionResult | Select-Object -Last 5 | ForEach-Object { Write-ColorOutput "  $_" "White" }
            }
            else {
                Write-ColorOutput "❌ Transcription test failed" "Red"
                Write-ColorOutput "Error output:" "Yellow"
                $transcriptionResult | Select-Object -Last 3 | ForEach-Object { Write-ColorOutput "  $_" "Red" }
            }
        }
    }
    else {
        Write-ColorOutput "⚠️  Audio file not found: $AudioFile" "Yellow"
    }
}

Write-ColorOutput "`n=== Validation Complete ===" "Green"
