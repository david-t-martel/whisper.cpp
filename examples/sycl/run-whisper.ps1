# MIT license
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: MIT

param(
    [Parameter(Position = 0)]
    [int]$DeviceId = 0,

    [Parameter()]
    [string]$Model = "models/ggml-base.en.bin",

    [Parameter()]
    [string]$Audio = "samples/jfk.wav",

    [Parameter()]
    [switch]$Debug,

    [Parameter()]
    [switch]$ListDevices,

    [Parameter()]
    [string]$OneAPIRoot = "C:\Program Files (x86)\Intel\oneAPI"
)

# Set up Intel oneAPI environment
function Set-IntelOneAPIEnvironment {
    param([string]$OneAPIPath)

    Write-Host "Setting up Intel oneAPI environment..." -ForegroundColor Green

    # Set basic oneAPI environment variables
    $env:ONEAPI_ROOT = $OneAPIPath

    # Find the latest compiler version
    $compilerPath = Get-ChildItem "$OneAPIPath\compiler" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($compilerPath) {
        $compilerBin = Join-Path $compilerPath.FullName "bin"
        $compilerLib = Join-Path $compilerPath.FullName "lib"
        $compilerInclude = Join-Path $compilerPath.FullName "include"

        # Add to PATH
        $env:PATH = "$compilerBin;$env:PATH"

        # Set compiler-specific variables
        $env:CMPLR_ROOT = $compilerPath.FullName
        $env:SYCL_LIBRARY_PATH = $compilerLib
        $env:SYCL_INCLUDE_PATH = $compilerInclude

        Write-Host "  Compiler: $($compilerPath.Name)" -ForegroundColor Cyan
    }

    # Find and set up MKL
    $mklPath = Get-ChildItem "$OneAPIPath\mkl" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($mklPath) {
        $env:MKLROOT = $mklPath.FullName
        $mklBin = Join-Path $mklPath.FullName "bin"
        $env:PATH = "$mklBin;$env:PATH"
        Write-Host "  MKL: $($mklPath.Name)" -ForegroundColor Cyan
    }

    # Find and set up TBB
    $tbbPath = Get-ChildItem "$OneAPIPath\tbb" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($tbbPath) {
        $env:TBBROOT = $tbbPath.FullName
        $tbbBin = Join-Path $tbbPath.FullName "bin"
        $env:PATH = "$tbbBin;$env:PATH"
        Write-Host "  TBB: $($tbbPath.Name)" -ForegroundColor Cyan
    }

    # Find and set up IPP
    $ippPath = Get-ChildItem "$OneAPIPath\ipp" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($ippPath) {
        $env:IPPROOT = $ippPath.FullName
        $ippBin = Join-Path $ippPath.FullName "bin"
        $env:PATH = "$ippBin;$env:PATH"
        Write-Host "  IPP: $($ippPath.Name)" -ForegroundColor Cyan
    }

    Write-Host "Intel oneAPI environment configured." -ForegroundColor Green
}

# Check if Intel oneAPI is available
if (Test-Path $OneAPIRoot) {
    Set-IntelOneAPIEnvironment -OneAPIPath $OneAPIRoot
}
else {
    Write-Warning "Intel oneAPI not found at $OneAPIRoot"
    Write-Warning "Please install Intel oneAPI or specify correct path with -OneAPIRoot"
    exit 1
}

# Set SYCL device
$env:GGML_SYCL_DEVICE = $DeviceId
Write-Host "GGML_SYCL_DEVICE=$env:GGML_SYCL_DEVICE" -ForegroundColor Yellow

# Enable debug mode if requested
if ($Debug) {
    $env:GGML_SYCL_DEBUG = "1"
    Write-Host "SYCL debug mode enabled" -ForegroundColor Yellow
}

# List SYCL devices if requested
if ($ListDevices) {
    Write-Host "Listing available SYCL devices..." -ForegroundColor Green
    $lsDeviceExe = ".\out\build\vs2022-sycl\bin\Release\ls-sycl-device.exe"
    if (Test-Path $lsDeviceExe) {
        & $lsDeviceExe
    }
    else {
        Write-Warning "ls-sycl-device.exe not found at $lsDeviceExe"
        Write-Warning "Please build the SYCL configuration first"
    }
    exit 0
}

# Check if whisper-cli exists
$whisperExe = ".\out\build\vs2022-sycl\bin\Release\whisper-cli.exe"
if (-not (Test-Path $whisperExe)) {
    Write-Error "whisper-cli.exe not found at $whisperExe"
    Write-Host "Please build the SYCL configuration first using:" -ForegroundColor Yellow
    Write-Host "cmake --preset vs2022-sycl" -ForegroundColor Cyan
    Write-Host "cmake --build out/build/vs2022-sycl --config Release" -ForegroundColor Cyan
    exit 1
}

# Check if model file exists
if (-not (Test-Path $Model)) {
    Write-Error "Model file not found: $Model"
    Write-Host "Available models:" -ForegroundColor Yellow
    Get-ChildItem "models\*.bin" | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Cyan }
    exit 1
}

# Check if audio file exists
if (-not (Test-Path $Audio)) {
    Write-Error "Audio file not found: $Audio"
    Write-Host "Available samples:" -ForegroundColor Yellow
    Get-ChildItem "samples\*" | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Cyan }
    exit 1
}

# Run whisper with SYCL
Write-Host "Running whisper with Intel SYCL GPU acceleration..." -ForegroundColor Green
Write-Host "Model: $Model" -ForegroundColor White
Write-Host "Audio: $Audio" -ForegroundColor White
Write-Host "Device: $env:GGML_SYCL_DEVICE" -ForegroundColor White

$startTime = Get-Date
& $whisperExe -m $Model -f $Audio --print-progress
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "Execution completed in $($duration.TotalSeconds) seconds" -ForegroundColor Green

# Usage examples in comments
<#
.SYNOPSIS
    Run whisper.cpp with Intel SYCL GPU acceleration on Windows

.DESCRIPTION
    This script sets up the Intel oneAPI environment and runs whisper.cpp
    with SYCL GPU acceleration for Intel GPUs.

.PARAMETER DeviceId
    SYCL device ID to use (default: 0)

.PARAMETER Model
    Path to the whisper model file (default: models/ggml-base.en.bin)

.PARAMETER Audio
    Path to the audio file to transcribe (default: samples/jfk.wav)

.PARAMETER Debug
    Enable SYCL debug mode

.PARAMETER ListDevices
    List available SYCL devices and exit

.PARAMETER OneAPIRoot
    Path to Intel oneAPI installation (default: C:\Program Files (x86)\Intel\oneAPI)

.EXAMPLES
    # Basic usage
    .\run-whisper.ps1

    # Use different device
    .\run-whisper.ps1 -DeviceId 1

    # Use different model and audio
    .\run-whisper.ps1 -Model "models/ggml-small.en.bin" -Audio "samples/audio.wav"

    # Enable debug mode
    .\run-whisper.ps1 -Debug

    # List available SYCL devices
    .\run-whisper.ps1 -ListDevices

    # Use custom oneAPI installation path
    .\run-whisper.ps1 -OneAPIRoot "D:\Intel\oneAPI"
#>
