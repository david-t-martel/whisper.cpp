# Test TBB Build Script for whisper.cpp
param(
    [string]$BuildType = "Release",
    [switch]$Clean,
    [switch]$Verbose
)

Write-Host "=== Testing TBB Integration with whisper.cpp ===" -ForegroundColor Green

$BuildDir = "build_test_tbb"
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

Write-Host "`n1. Configuring CMake with TBB..." -ForegroundColor Cyan
$ConfigArgs = @(
    ".."
    "-DWHISPER_TBB=ON"
    "-DWHISPER_MIMALLOC=ON"
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

Write-Host "`n2. Building the project..." -ForegroundColor Cyan
$BuildArgs = @(
    "--build", "."
    "--config", $BuildType
)

if ($Verbose) {
    $BuildArgs += "--verbose"
}

& cmake @BuildArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Set-Location $SourceDir
    exit 1
}

Write-Host "`n3. Checking built binaries..." -ForegroundColor Cyan
$Binaries = @("bin\main.exe", "bin\stream.exe", "src\whisper.dll")

foreach ($binary in $Binaries) {
    if (Test-Path $binary) {
        $info = Get-Item $binary
        Write-Host "[OK] $binary ($($info.Length) bytes)" -ForegroundColor Green
    }
    else {
        Write-Host "[MISSING] $binary" -ForegroundColor Red
    }
}

Write-Host "`n4. Checking TBB linkage..." -ForegroundColor Cyan
$DumpbinPath = Get-Command dumpbin -ErrorAction SilentlyContinue
if ($DumpbinPath) {
    Write-Host "Checking dependencies of whisper.dll:" -ForegroundColor Yellow
    & dumpbin /dependents "src\whisper.dll" | Select-String -Pattern "tbb|TBB"
}
else {
    Write-Host "dumpbin not found - install Visual Studio Build Tools for dependency analysis" -ForegroundColor Yellow
}

Write-Host "`n5. Testing runtime with TBB..." -ForegroundColor Cyan
if (Test-Path "bin\main.exe") {
    Write-Host "Running main.exe --help to verify it loads correctly:" -ForegroundColor Yellow
    & "bin\main.exe" --help 2>&1 | Select-Object -First 10    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Binary runs successfully" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Binary failed to run (exit code: $LASTEXITCODE)" -ForegroundColor Red
    }
}

Set-Location $SourceDir

Write-Host "`n=== TBB Integration Test Complete ===" -ForegroundColor Green
Write-Host "Build artifacts are in: $BuildDir" -ForegroundColor Cyan
