# Intel oneAPI CMake Wrapper Script
# This script sets up the Intel oneAPI environment before running CMake

param(
    [Parameter()]
    [string]$OneAPIRoot = "C:\Program Files (x86)\Intel\oneAPI",

    [Parameter()]
    [string]$Preset = "ninja-sycl",

    [Parameter()]
    [switch]$Configure,

    [Parameter()]
    [switch]$Build,

    [Parameter()]
    [switch]$Clean,

    [Parameter(ValueFromRemainingArguments)]
    [string[]]$AdditionalArgs
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
Write-ColorOutput "=== Intel oneAPI CMake Wrapper ===" "Blue"

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
if ($Clean) {
    $buildDirs = @("build-sycl", "out\build\$Preset")
    foreach ($buildDir in $buildDirs) {
        if (Test-Path $buildDir) {
            Write-ColorOutput "Cleaning $buildDir..." "Yellow"
            Remove-Item -Recurse -Force $buildDir
        }
    }
}

# Configure
if ($Configure -or (-not $Build)) {
    Write-ColorOutput "Configuring with preset: $Preset" "Yellow"

    # Try preset first
    $presetExists = $false
    try {
        $presets = cmake --list-presets=configure 2>&1
        if ($presets -match $Preset) {
            $presetExists = $true
        }
    }
    catch {
        Write-ColorOutput "Could not list presets, using direct cmake" "Yellow"
    }

    if ($presetExists) {
        cmake --preset $Preset @AdditionalArgs
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ CMake configuration failed" "Red"
            exit 1
        }
    }
    else {
        # Fallback to direct cmake
        $cmakeArgs = @(
            "-B", "build-sycl"
            "-G", "Ninja"
            "-DWHISPER_SYCL=ON"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DCMAKE_CXX_COMPILER=icpx"
            "-DCMAKE_C_COMPILER=icx"
            "-DWHISPER_TBB=ON"
            "-DWHISPER_MKL=ON"
            "-DWHISPER_IPP=ON"
        )

        cmake @cmakeArgs @AdditionalArgs .
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ CMake configuration failed" "Red"
            exit 1
        }
    }

    Write-ColorOutput "✅ Configuration completed" "Green"
}

# Build
if ($Build) {
    Write-ColorOutput "Building..." "Yellow"

    $buildPath = if (Test-Path "out\build\$Preset") { "out\build\$Preset" } else { "build-sycl" }

    cmake --build $buildPath --config Release --parallel
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Build failed" "Red"
        exit 1
    }

    Write-ColorOutput "✅ Build completed successfully!" "Green"

    # Test device listing if available
    $lsSyclDevice = "$buildPath\examples\sycl\ls-sycl-device.exe"
    if (Test-Path $lsSyclDevice) {
        Write-ColorOutput "=== Available SYCL Devices ===" "Blue"
        & $lsSyclDevice
    }
}

Write-ColorOutput "=== Completed ===" "Green"
