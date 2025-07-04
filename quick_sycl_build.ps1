# Quick SYCL Build Script for whisper.cpp
# This script provides a streamlined approach to building whisper.cpp with Intel SYCL support

param(
    [Parameter()]
    [string]$OneAPIRoot = "C:\Program Files (x86)\Intel\oneAPI",

    [Parameter()]
    [switch]$Clean,

    [Parameter()]
    [string]$BuildType = "Release"
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

function Set-IntelOneAPIEnvironment {
    param([string]$OneAPIPath)

    Write-ColorOutput "Setting up Intel oneAPI environment..." "Yellow"

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

        Write-ColorOutput "  ✅ Compiler: $($compilerPath.Name)" "Cyan"
    }

    # Find and set up MKL
    $mklPath = Get-ChildItem "$OneAPIPath\mkl" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($mklPath) {
        $env:MKLROOT = $mklPath.FullName
        $mklBin = Join-Path $mklPath.FullName "bin"
        $env:PATH = "$mklBin;$env:PATH"
        Write-ColorOutput "  ✅ MKL: $($mklPath.Name)" "Cyan"
    }

    # Find and set up TBB
    $tbbPath = Get-ChildItem "$OneAPIPath\tbb" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($tbbPath) {
        $env:TBBROOT = $tbbPath.FullName
        $tbbBin = Join-Path $tbbPath.FullName "bin"
        $env:PATH = "$tbbBin;$env:PATH"
        Write-ColorOutput "  ✅ TBB: $($tbbPath.Name)" "Cyan"
    }

    # Find and set up IPP
    $ippPath = Get-ChildItem "$OneAPIPath\ipp" -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($ippPath) {
        $env:IPPROOT = $ippPath.FullName
        $ippBin = Join-Path $ippPath.FullName "bin"
        $env:PATH = "$ippBin;$env:PATH"
        Write-ColorOutput "  ✅ IPP: $($ippPath.Name)" "Cyan"
    }
}

# Main execution
Write-ColorOutput "=== Quick SYCL Build for whisper.cpp ===" "Blue"

# Check prerequisites
if (-not (Test-Path $OneAPIRoot)) {
    Write-ColorOutput "❌ Intel oneAPI not found at $OneAPIRoot" "Red"
    exit 1
}

# Set up environment
Set-IntelOneAPIEnvironment -OneAPIPath $OneAPIRoot

# Check for Intel DPC++ compiler
$dpcpp = Get-Command icpx -ErrorAction SilentlyContinue
if (-not $dpcpp) {
    $dpcpp = Get-Command dpcpp -ErrorAction SilentlyContinue
}

if (-not $dpcpp) {
    Write-ColorOutput "❌ Intel DPC++ compiler not found" "Red"
    exit 1
}

Write-ColorOutput "✅ Using compiler: $($dpcpp.Source)" "Green"

# Navigate to project directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Clean build directory if requested
if ($Clean -and (Test-Path "build")) {
    Write-ColorOutput "Cleaning build directory..." "Yellow"
    Remove-Item -Recurse -Force "build"
}

# Create build directory
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

Set-Location "build"

# Configure with CMake
Write-ColorOutput "Configuring with CMake..." "Yellow"
$cmakeArgs = @(
    ".."
    "-DWHISPER_SYCL=ON"
    "-DCMAKE_BUILD_TYPE=$BuildType"
    "-DCMAKE_CXX_COMPILER=icpx"
    "-DCMAKE_C_COMPILER=icx"
)

cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ CMake configuration failed" "Red"
    exit 1
}

# Build
Write-ColorOutput "Building..." "Yellow"
cmake --build . --config $BuildType --parallel
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "❌ Build failed" "Red"
    exit 1
}

Write-ColorOutput "✅ Build completed successfully!" "Green"

# List SYCL devices if available
$lsSyclDevice = ".\examples\sycl\$BuildType\ls-sycl-device.exe"
if (Test-Path $lsSyclDevice) {
    Write-ColorOutput "=== Available SYCL Devices ===" "Blue"
    & $lsSyclDevice
}
else {
    Write-ColorOutput "⚠️  ls-sycl-device not found at $lsSyclDevice" "Yellow"
}

Write-ColorOutput "=== Build Complete ===" "Green"
Write-ColorOutput "Executables are in: $(Get-Location)" "Cyan"
