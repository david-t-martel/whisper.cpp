# Intel SYCL Build and Test Script for whisper.cpp
# This script builds whisper.cpp with Intel SYCL support and runs basic tests

param(
    [Parameter()]
    [string]$OneAPIRoot = "C:\Program Files (x86)\Intel\oneAPI",

    [Parameter()]
    [switch]$SkipBuild,

    [Parameter()]
    [switch]$CleanBuild,

    [Parameter()]
    [string]$Preset = "vs2022-sycl",

    [Parameter()]
    [switch]$ListDevices,

    [Parameter()]
    [switch]$RunBenchmark
)

function Write-ColorOutput {
    param([string]$Text, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Text -ForegroundColor Red }
        "Green" { Write-Host $Text -ForegroundColor Green }
        "Yellow" { Write-Host $Text -ForegroundColor Yellow }
        "Blue" { Write-Host $Text -ForegroundColor Blue }
        "Cyan" { Write-Host $Text -ForegroundColor Cyan }
        "Magenta" { Write-Host $Text -ForegroundColor Magenta }
        default { Write-Host $Text -ForegroundColor White }
    }
}

function Test-Prerequisites {
    Write-ColorOutput "=== Testing SYCL Prerequisites ===" "Blue"

    # Check Intel oneAPI installation
    if (-not (Test-Path $OneAPIRoot)) {
        Write-ColorOutput "❌ Intel oneAPI not found at $OneAPIRoot" "Red"
        Write-ColorOutput "Please install Intel oneAPI or specify correct path with -OneAPIRoot" "Yellow"
        return $false
    }
    Write-ColorOutput "✅ Intel oneAPI found at $OneAPIRoot" "Green"

    # Set up oneAPI environment using native PowerShell approach
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

    Set-IntelOneAPIEnvironment -OneAPIPath $OneAPIRoot

    # Check DPC++ compiler
    $dpcpp = Get-Command icpx -ErrorAction SilentlyContinue
    if (-not $dpcpp) {
        $dpcpp = Get-Command dpcpp -ErrorAction SilentlyContinue
    }

    if ($dpcpp) {
        Write-ColorOutput "✅ Intel DPC++ compiler found: $($dpcpp.Source)" "Green"
        $version = & $dpcpp.Source --version 2>&1 | Select-Object -First 1
        Write-ColorOutput "   Version: $version" "Cyan"
    }
    else {
        Write-ColorOutput "❌ Intel DPC++ compiler not found" "Red"
        return $false
    }

    # Check for Intel GPU
    try {
        $gpuInfo = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*Intel*" }
        if ($gpuInfo) {
            Write-ColorOutput "✅ Intel GPU detected: $($gpuInfo.Name)" "Green"
        }
        else {
            Write-ColorOutput "⚠️  No Intel GPU detected (SYCL can still use CPU)" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "⚠️  Could not check for Intel GPU" "Yellow"
    }

    return $true
}

function Build-SYCLWhisper {
    param([string]$BuildPreset)

    Write-ColorOutput "=== Building whisper.cpp with Intel SYCL ===" "Blue"

    if ($CleanBuild) {
        Write-ColorOutput "Cleaning previous build..." "Yellow"
        $buildDirs = @("build", "out\build\$BuildPreset")
        foreach ($buildDir in $buildDirs) {
            if (Test-Path $buildDir) {
                Remove-Item -Recurse -Force $buildDir
                Write-ColorOutput "  Cleaned: $buildDir" "Gray"
            }
        }
    }

    # Try preset-based build first, then fallback to direct cmake
    Write-ColorOutput "Attempting preset-based build: $BuildPreset" "Yellow"

    # Check if preset exists
    $presetExists = $false
    try {
        $presets = cmake --list-presets=configure 2>&1
        if ($presets -match $BuildPreset) {
            $presetExists = $true
        }
    }
    catch {
        Write-ColorOutput "Could not list presets, trying direct build" "Yellow"
    }

    if ($presetExists) {
        # Configure with preset
        $configResult = cmake --preset $BuildPreset
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ CMake configuration with preset successful" "Green"

            # Build with preset
            $buildResult = cmake --build "out\build\$BuildPreset" --config Release
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Preset build successful" "Green"
                return $true
            }
        }
        Write-ColorOutput "⚠️  Preset build failed, trying direct cmake..." "Yellow"
    }

    # Fallback to direct cmake build
    Write-ColorOutput "Using direct CMake build..." "Yellow"

    # Configure
    $cmakeArgs = @(
        "-B", "build"
        "-DWHISPER_SYCL=ON"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_CXX_COMPILER=icpx"
        "-DCMAKE_C_COMPILER=icx"
    )

    $configResult = cmake @cmakeArgs .
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ CMake configuration failed" "Red"
        return $false
    }
    Write-ColorOutput "✅ CMake configuration successful" "Green"

    # Build
    Write-ColorOutput "Building whisper.cpp..." "Yellow"
    $buildResult = cmake --build build --config Release --parallel
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Build failed" "Red"
        return $false
    }
    Write-ColorOutput "✅ Build successful" "Green"

    return $true
}

function Test-SYCLDevices {
    Write-ColorOutput "=== Testing SYCL Device Detection ===" "Blue"

    # Try multiple possible paths for ls-sycl-device
    $lsDevicePaths = @(
        "build\examples\sycl\Release\ls-sycl-device.exe",
        "build\examples\sycl\Debug\ls-sycl-device.exe",
        "out\build\$Preset\examples\sycl\Release\ls-sycl-device.exe",
        "out\build\$Preset\examples\sycl\Debug\ls-sycl-device.exe"
    )

    $lsDeviceExe = $null
    foreach ($path in $lsDevicePaths) {
        if (Test-Path $path) {
            $lsDeviceExe = $path
            break
        }
    }

    if (-not $lsDeviceExe) {
        Write-ColorOutput "❌ ls-sycl-device.exe not found in any expected location" "Red"
        Write-ColorOutput "   Checked paths:" "Yellow"
        foreach ($path in $lsDevicePaths) {
            Write-ColorOutput "   - $path" "Gray"
        }
        return $false
    }

    Write-ColorOutput "Using ls-sycl-device: $lsDeviceExe" "Cyan"
    Write-ColorOutput "Available SYCL devices:" "Cyan"
    & $lsDeviceExe
    return $true
}

function Test-SYCLInference {
    Write-ColorOutput "=== Testing SYCL Inference ===" "Blue"

    # Try multiple possible paths for main executable
    $whisperPaths = @(
        "build\bin\Release\main.exe",
        "build\bin\Debug\main.exe",
        "out\build\$Preset\bin\Release\main.exe",
        "out\build\$Preset\bin\Debug\main.exe"
    )

    $whisperExe = $null
    foreach ($path in $whisperPaths) {
        if (Test-Path $path) {
            $whisperExe = $path
            break
        }
    }

    if (-not $whisperExe) {
        Write-ColorOutput "❌ whisper main.exe not found in any expected location" "Red"
        Write-ColorOutput "   Checked paths:" "Yellow"
        foreach ($path in $whisperPaths) {
            Write-ColorOutput "   - $path" "Gray"
        }
        return $false
    }

    Write-ColorOutput "Using whisper executable: $whisperExe" "Cyan"

    # Check for model and audio files
    $model = "models\ggml-tiny.en.bin"
    $audio = "samples\jfk.wav"

    if (-not (Test-Path $model)) {
        Write-ColorOutput "❌ Model not found: $model" "Red"
        Write-ColorOutput "   Downloading tiny model..." "Yellow"

        # Try to download the model
        $downloadScript = "models\download-ggml-model.cmd"
        if (Test-Path $downloadScript) {
            & $downloadScript tiny.en
            if (-not (Test-Path $model)) {
                Write-ColorOutput "❌ Failed to download model" "Red"
                return $false
            }
        }
        else {
            Write-ColorOutput "   Please download models manually or run: .\models\download-ggml-model.cmd tiny.en" "Yellow"
            return $false
        }
    }

    if (-not (Test-Path $audio)) {
        Write-ColorOutput "❌ Audio sample not found: $audio" "Red"
        Write-ColorOutput "   Please ensure the jfk.wav sample exists in the samples directory" "Yellow"
        return $false
    }

    # Test SYCL acceleration
    Write-ColorOutput "Testing SYCL GPU acceleration..." "Yellow"
    $env:GGML_SYCL_DEVICE = "0"

    $startTime = Get-Date
    & $whisperExe -m $model -f $audio --print-progress -np
    $endTime = Get-Date

    if ($LASTEXITCODE -eq 0) {
        $duration = ($endTime - $startTime).TotalSeconds
        Write-ColorOutput "✅ SYCL inference successful in $duration seconds" "Green"
        return $true
    }
    else {
        Write-ColorOutput "❌ SYCL inference failed" "Red"
        return $false
    }
}

function Run-SYCLBenchmark {
    Write-ColorOutput "=== Running SYCL Performance Benchmark ===" "Blue"

    # Find the whisper executable
    $whisperPaths = @(
        "build\bin\Release\main.exe",
        "build\bin\Debug\main.exe",
        "out\build\$Preset\bin\Release\main.exe",
        "out\build\$Preset\bin\Debug\main.exe"
    )

    $whisperExe = $null
    foreach ($path in $whisperPaths) {
        if (Test-Path $path) {
            $whisperExe = $path
            break
        }
    }

    if (-not $whisperExe) {
        Write-ColorOutput "❌ whisper executable not found for benchmark" "Red"
        return
    }

    $models = @("ggml-tiny.en.bin", "ggml-base.en.bin", "ggml-small.en.bin")
    $audio = "samples\jfk.wav"

    if (-not (Test-Path $audio)) {
        Write-ColorOutput "❌ Audio sample not found: $audio" "Red"
        return
    }

    foreach ($model in $models) {
        $modelPath = "models\$model"
        if (Test-Path $modelPath) {
            Write-ColorOutput "Benchmarking $model with SYCL..." "Cyan"

            # SYCL GPU test
            $env:GGML_SYCL_DEVICE = "0"
            Write-ColorOutput "  SYCL GPU (device 0):" "Yellow"
            $startTime = Get-Date
            & $whisperExe -m $modelPath -f $audio --print-progress -np 2>&1 | Out-Null
            $endTime = Get-Date
            $syclTime = ($endTime - $startTime).TotalSeconds
            Write-ColorOutput "    Time: $syclTime seconds" "Green"

            # CPU fallback test
            Remove-Item Env:\GGML_SYCL_DEVICE -ErrorAction SilentlyContinue
            Write-ColorOutput "  CPU fallback:" "Yellow"
            $startTime = Get-Date
            & $whisperExe -m $modelPath -f $audio --print-progress -np -t 1 2>&1 | Out-Null
            $endTime = Get-Date
            $cpuTime = ($endTime - $startTime).TotalSeconds
            Write-ColorOutput "    Time: $cpuTime seconds" "Green"

            # Calculate speedup
            if ($cpuTime -gt 0 -and $syclTime -gt 0) {
                $speedup = [math]::Round($cpuTime / $syclTime, 2)
                Write-ColorOutput "    SYCL Speedup: ${speedup}x" "Magenta"
            }

            Write-ColorOutput "" "White"
        }
        else {
            Write-ColorOutput "⚠️  Model not found: $modelPath (skipping)" "Yellow"
        }
    }
}

# Main execution
Write-ColorOutput "Intel SYCL whisper.cpp Build and Test Script" "Magenta"
Write-ColorOutput "=============================================" "Magenta"

# Test prerequisites
if (-not (Test-Prerequisites)) {
    Write-ColorOutput "Prerequisites check failed. Exiting." "Red"
    exit 1
}

# List devices only if requested
if ($ListDevices) {
    if (-not $SkipBuild) {
        if (-not (Build-SYCLWhisper -BuildPreset $Preset)) {
            exit 1
        }
    }
    Test-SYCLDevices
    exit 0
}

# Build unless skipped
if (-not $SkipBuild) {
    if (-not (Build-SYCLWhisper -BuildPreset $Preset)) {
        exit 1
    }
}

# Test SYCL functionality
Test-SYCLDevices
Test-SYCLInference

# Run benchmark if requested
if ($RunBenchmark) {
    Run-SYCLBenchmark
}

Write-ColorOutput "=== SYCL Test Complete ===" "Green"

<#
.SYNOPSIS
    Build and test whisper.cpp with Intel SYCL GPU acceleration

.DESCRIPTION
    This script builds whisper.cpp with Intel SYCL support and runs comprehensive tests
    to verify SYCL GPU acceleration is working correctly.

.PARAMETER OneAPIRoot
    Path to Intel oneAPI installation (default: C:\Program Files (x86)\Intel\oneAPI)

.PARAMETER SkipBuild
    Skip the build step and only run tests

.PARAMETER CleanBuild
    Clean previous build before building

.PARAMETER Preset
    CMake preset to use (default: vs2022-sycl)

.PARAMETER ListDevices
    List available SYCL devices and exit

.PARAMETER RunBenchmark
    Run performance benchmarks comparing SYCL vs CPU

.EXAMPLES
    # Basic build and test
    .\test_sycl_build.ps1

    # Clean build with benchmark
    .\test_sycl_build.ps1 -CleanBuild -RunBenchmark

    # List SYCL devices only
    .\test_sycl_build.ps1 -ListDevices

    # Use different preset
    .\test_sycl_build.ps1 -Preset "ninja-sycl"

    # Skip build, just test
    .\test_sycl_build.ps1 -SkipBuild
#>
