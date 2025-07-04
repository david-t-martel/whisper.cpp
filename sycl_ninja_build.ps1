#!/usr/bin/env pwsh
# SYCL Ninja Build Script for whisper.cpp with Intel oneAPI

param(
    [switch]$Clean,
    [switch]$Test,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "=== Intel SYCL Ninja Build for whisper.cpp ===" -ForegroundColor Cyan

# Set oneAPI environment
$oneAPIRoot = "C:\Program Files (x86)\Intel\oneAPI"
if (-not (Test-Path $oneAPIRoot)) {
    Write-Error "Intel oneAPI not found at $oneAPIRoot"
    exit 1
}

Write-Host "Setting up Intel oneAPI environment..." -ForegroundColor Yellow
$setvars = "$oneAPIRoot\setvars.bat"
if (-not (Test-Path $setvars)) {
    Write-Error "Intel oneAPI setvars.bat not found at $setvars"
    exit 1
}

# Source Intel oneAPI environment
$env:ONEAPI_ROOT = $oneAPIRoot
$env:PATH = "$oneAPIRoot\compiler\latest\bin;" + $env:PATH
$env:CMAKE_CXX_COMPILER = "$oneAPIRoot\compiler\latest\bin\icpx.exe"
$env:CMAKE_C_COMPILER = "$oneAPIRoot\compiler\latest\bin\icx.exe"

Write-Host "✅ Using Intel DPC++ compiler: $env:CMAKE_CXX_COMPILER" -ForegroundColor Green

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning build directory..." -ForegroundColor Yellow
    if (Test-Path "build_sycl") {
        Remove-Item -Recurse -Force "build_sycl"
    }
}

# Create build directory
New-Item -ItemType Directory -Force -Path "build_sycl" | Out-Null
Set-Location "build_sycl"

try {
    # Configure CMake with Ninja and Intel compilers
    Write-Host "Configuring with CMake (Ninja)..." -ForegroundColor Yellow

    $cmakeArgs = @(
        "-G", "Ninja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_CXX_COMPILER=$env:CMAKE_CXX_COMPILER"
        "-DCMAKE_C_COMPILER=$env:CMAKE_C_COMPILER"
        "-DCMAKE_CXX_STANDARD=17"
        "-DWHISPER_SYCL=ON"
        "-DGGML_SYCL=ON"
        "-DGGML_SYCL_TARGET=INTEL"
        "-DBUILD_SHARED_LIBS=ON"
        "-DWHISPER_BUILD_EXAMPLES=ON"
        "-DWHISPER_BUILD_TESTS=ON"
        ".."
    )

    if ($Verbose) {
        $cmakeArgs += "--verbose"
    }

    & cmake @cmakeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "CMake configuration failed"
    }

    # Build
    Write-Host "Building..." -ForegroundColor Yellow
    $ninjaArgs = @()
    if ($Verbose) {
        $ninjaArgs += "-v"
    }

    & ninja @ninjaArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Ninja build failed"
    }

    Write-Host "✅ Build completed successfully!" -ForegroundColor Green

    # Test if requested
    if ($Test) {
        Write-Host "Running tests..." -ForegroundColor Yellow
        & ninja test
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Some tests failed"
        }
        else {
            Write-Host "✅ All tests passed!" -ForegroundColor Green
        }
    }

    # List available devices
    Write-Host "Listing SYCL devices..." -ForegroundColor Yellow
    $whisperMain = "bin\whisper-main.exe"
    if (Test-Path $whisperMain) {
        & $whisperMain --list-devices 2>&1 | Out-String | Write-Host
    }

}
catch {
    Write-Error "Build failed: $_"
    exit 1
}
finally {
    Set-Location ..
}

Write-Host "Build artifacts in: build_sycl\" -ForegroundColor Cyan
