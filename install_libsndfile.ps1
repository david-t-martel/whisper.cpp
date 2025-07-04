#!/usr/bin/env pwsh
# Install libsndfile via vcpkg for whisper.cpp

param(
    [string]$VcpkgRoot = $env:VCPKG_ROOT,
    [string]$Triplet = "x64-windows"
)

Write-Host "Installing libsndfile via vcpkg..." -ForegroundColor Green

# Check if VCPKG_ROOT environment variable is set
if ([string]::IsNullOrEmpty($VcpkgRoot)) {
    Write-Host "VCPKG_ROOT environment variable is not set" -ForegroundColor Red
    Write-Host "Please set VCPKG_ROOT environment variable or specify -VcpkgRoot parameter" -ForegroundColor Yellow
    Write-Host "Example: `$env:VCPKG_ROOT = 'C:\vcpkg'" -ForegroundColor Cyan
    exit 1
}

# Check if vcpkg directory exists
if (-not (Test-Path $VcpkgRoot)) {
    Write-Host "vcpkg not found at $VcpkgRoot" -ForegroundColor Red
    Write-Host "Please install vcpkg first or update VCPKG_ROOT environment variable" -ForegroundColor Yellow
    exit 1
}

# Set vcpkg executable path
$VcpkgExe = Join-Path $VcpkgRoot "vcpkg.exe"

if (-not (Test-Path $VcpkgExe)) {
    Write-Host "vcpkg.exe not found at $VcpkgExe" -ForegroundColor Red
    exit 1
}

try {
    Write-Host "Installing packages from vcpkg.json manifest..." -ForegroundColor Cyan

    # In manifest mode, just run vcpkg install without package names
    & $VcpkgExe install --triplet $Triplet

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All packages from manifest installed successfully!" -ForegroundColor Green

        # Show installation location
        $InstallPath = Join-Path $VcpkgRoot "installed\$Triplet"
        Write-Host "Installation location: $InstallPath" -ForegroundColor Cyan

        # Check if libsndfile files exist
        $IncludeDir = Join-Path $InstallPath "include"
        $LibDir = Join-Path $InstallPath "lib"

        Write-Host "`nChecking libsndfile installation:" -ForegroundColor Cyan
        if (Test-Path (Join-Path $IncludeDir "sndfile.h")) {
            Write-Host "  ✅ Headers: $(Join-Path $IncludeDir "sndfile.h")" -ForegroundColor Green
        }
        else {
            Write-Host "  ❌ Headers not found" -ForegroundColor Red
        }

        $SndFileLib = Join-Path $LibDir "sndfile.lib"
        if (Test-Path $SndFileLib) {
            Write-Host "  ✅ Library: $SndFileLib" -ForegroundColor Green
        }
        else {
            Write-Host "  ❌ Library not found" -ForegroundColor Red
        }

        Write-Host "`nTo use libsndfile in whisper.cpp:" -ForegroundColor Yellow
        Write-Host "1. Set WHISPER_LIBSNDFILE=ON in CMake" -ForegroundColor White
        Write-Host "2. Make sure VCPKG_ROOT environment variable is set" -ForegroundColor White
        Write-Host "3. Configure with: cmake -DWHISPER_LIBSNDFILE=ON ..." -ForegroundColor White

    }
    else {
        Write-Host "❌ Failed to install packages from manifest" -ForegroundColor Red
        exit 1
    }

}
catch {
    Write-Host "❌ Error installing packages: $_" -ForegroundColor Red
    exit 1
}
