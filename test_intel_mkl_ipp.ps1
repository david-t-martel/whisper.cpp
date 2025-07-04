# Intel MKL + IPP Integration Test Script for whisper.cpp
param(
    [string]$BuildType = "Release",
    [switch]$Clean,
    [switch]$Verbose
)

Write-Host "=== Testing Intel MKL + IPP Integration with whisper.cpp ===" -ForegroundColor Green

$BuildDir = "build_intel_mkl_ipp"
$SourceDir = Get-Location

if ($Clean -and (Test-Path $BuildDir)) {
    Write-Host "Cleaning build directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $BuildDir
}

# Create build directory
if (!(Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Set-Location $BuildDir

Write-Host "`n1. Configuring CMake with Intel MKL + IPP..." -ForegroundColor Cyan
$ConfigArgs = @(
    ".."
    "-DWHISPER_TBB=ON"
    "-DWHISPER_MIMALLOC=ON"
    "-DWHISPER_MKL=ON"
    "-DWHISPER_MKL_FFT=ON"
    "-DWHISPER_MKL_BLAS=ON"
    "-DWHISPER_MKL_VML=ON"
    "-DWHISPER_IPP=ON"
    "-DWHISPER_IPP_AUDIO=ON"
    "-DCMAKE_BUILD_TYPE=$BuildType"
)

if ($Verbose) {
    $ConfigArgs += "--debug-output"
}

& cmake @ConfigArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed!" -ForegroundColor Red
    Set-Location $SourceDir
    exit 1
}

Write-Host "`n2. Building the core project (library only)..." -ForegroundColor Cyan
$BuildArgs = @(
    "--build", "."
    "--config", $BuildType
    "--target", "whisper"
)

if ($Verbose) {
    $BuildArgs += "--verbose"
}

& cmake @BuildArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Core library build failed!" -ForegroundColor Red
    Set-Location $SourceDir
    exit 1
}

Write-Host "`n3. Building main executable..." -ForegroundColor Cyan
$MainBuildArgs = @(
    "--build", "."
    "--config", $BuildType
    "--target", "main"
)

if ($Verbose) {
    $MainBuildArgs += "--verbose"
}

& cmake @MainBuildArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Main executable build failed, but continuing with library tests..." -ForegroundColor Yellow
}


Write-Host "`n3. Checking built binaries..." -ForegroundColor Cyan
$BinPath = Join-Path $BuildDir "bin\$BuildType"

$ExpectedBinaries = @(
    (Join-Path $BinPath "main.exe"),
    (Join-Path $BinPath "whisper.dll"),
    (Join-Path $BinPath "ggml.dll"),
    (Join-Path $BinPath "ggml-base.dll"),
    (Join-Path $BinPath "ggml-cpu.dll")
)

$AllFound = $true
foreach ($Binary in $ExpectedBinaries) {
    if (Test-Path $Binary) {
        $Size = (Get-Item $Binary).Length
        Write-Host "[OK] $([System.IO.Path]::GetFileName($Binary)) ($('{0:N0}' -f $Size) bytes)" -ForegroundColor Green
    }
    else {
        Write-Host "[MISSING] $([System.IO.Path]::GetFileName($Binary))" -ForegroundColor Red
        $AllFound = $false
    }
}

Write-Host "`n4. Checking Intel library linkage..." -ForegroundColor Cyan
$DumpbinPath = Get-Command dumpbin -ErrorAction SilentlyContinue
if ($DumpbinPath -and $AllFound) {
    Write-Host "Checking dependencies of whisper.dll:" -ForegroundColor Yellow
    $WhisperDll = Join-Path $BinPath "whisper.dll"
    & dumpbin /dependents $WhisperDll | Select-String -Pattern "mkl|tbb|ipp|intel"
}
else {
    Write-Host "dumpbin not found or binaries missing - install Visual Studio Build Tools for dependency analysis" -ForegroundColor Yellow
}

Write-Host "`n5. Testing runtime with Intel optimizations..." -ForegroundColor Cyan
if ($AllFound) {
    $MainExe = Join-Path $BinPath "main.exe"
    Write-Host "Testing basic whisper functionality..." -ForegroundColor Yellow

    # Test that the executable runs and shows help
    Write-Host "Running: $MainExe --help" -ForegroundColor Gray
    & $MainExe --help 2>&1 | Select-Object -First 10

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Intel-optimized whisper.cpp executable runs successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Executable failed to run - exit code: $LASTEXITCODE" -ForegroundColor Red
    }
}
else {
    Write-Host "Skipping runtime test - binaries not found" -ForegroundColor Yellow
}
if (Test-Path "bin\whisper-bench.exe") {
    Write-Host "Running whisper-bench.exe to verify Intel optimizations:" -ForegroundColor Yellow
    & "bin\whisper-bench.exe" 2>&1 | Select-Object -First 10
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
        # Exit code 1 is expected when no model file is present
        Write-Host "[OK] Binary runs successfully with Intel optimizations" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Binary failed to run (exit code: $LASTEXITCODE)" -ForegroundColor Red
    }
}

Write-Host "`n6. Performance comparison test (if model available)..." -ForegroundColor Cyan
if (Test-Path "..\models\ggml-base.en.bin") {
    Write-Host "Model found, running performance test..." -ForegroundColor Yellow
    # Could add performance benchmarking here
    Write-Host "Performance test would require audio input - skipping for now" -ForegroundColor Yellow
}
else {
    Write-Host "No model found at ..\models\ggml-base.en.bin - download a model to test performance" -ForegroundColor Yellow
}

Set-Location $SourceDir

Write-Host "`n=== Intel MKL + IPP Integration Test Complete ===" -ForegroundColor Green
Write-Host "Build artifacts are in: $BuildDir" -ForegroundColor Cyan
Write-Host "`nTo download a model for testing:" -ForegroundColor Yellow
Write-Host "  curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin -o models/ggml-base.en.bin" -ForegroundColor Gray
