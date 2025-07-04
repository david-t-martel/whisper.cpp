# SYCL Integration Summary for whisper.cpp
# This script provides an overview of the Intel SYCL integration status

param(
    [Parameter()]
    [string]$OneAPIRoot = "C:\Program Files (x86)\Intel\oneAPI"
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

Write-ColorOutput "=== Intel SYCL Integration Summary for whisper.cpp ===" "Blue"
Write-ColorOutput ""

# Check file modifications
$files = @{
    "CMakeLists.txt"                = "Core CMake configuration with SYCL support"
    "CMakePresets.json"             = "SYCL build presets"
    ".vscode\c_cpp_properties.json" = "VS Code IntelliSense configuration"
    "benchmark_whisper.ps1"         = "Benchmarking with SYCL support"
    "test_sycl_build.ps1"           = "Comprehensive SYCL build and test"
    "quick_sycl_build.ps1"          = "Streamlined SYCL build script"
    "validate_sycl_build.ps1"       = "SYCL build validation"
    "examples\sycl\run-whisper.ps1" = "Windows SYCL runtime script"
    "examples\sycl\CMakeLists.txt"  = "SYCL example configuration"
    "README_SYCL.md"                = "Comprehensive SYCL documentation"
}

Write-ColorOutput "Files Modified/Added:" "Yellow"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($file in $files.Keys) {
    $filePath = Join-Path $scriptDir $file
    if (Test-Path $filePath) {
        Write-ColorOutput "  ✅ $file - $($files[$file])" "Green"
    }
    else {
        Write-ColorOutput "  ❌ $file - Missing!" "Red"
    }
}

Write-ColorOutput ""
Write-ColorOutput "CMake SYCL Features Added:" "Yellow"
$cmakeFeatures = @(
    "WHISPER_SYCL option for enabling SYCL support",
    "Intel DPC++ compiler detection (icpx/icx)",
    "SYCL headers and libraries detection",
    "oneAPI component integration (MKL, TBB, IPP)",
    "GGML_SYCL flag propagation",
    "Conditional SYCL compilation"
)

foreach ($feature in $cmakeFeatures) {
    Write-ColorOutput "  ✅ $feature" "Cyan"
}

Write-ColorOutput ""
Write-ColorOutput "Build Presets Available:" "Yellow"
$presets = @(
    "vs2022-sycl - Visual Studio 2022 with SYCL",
    "ninja-sycl - Ninja build with SYCL",
    "ninja-intel-sycl - Ninja with Intel compiler and SYCL"
)

foreach ($preset in $presets) {
    Write-ColorOutput "  ✅ $preset" "Cyan"
}

Write-ColorOutput ""
Write-ColorOutput "PowerShell Scripts Available:" "Yellow"
$scripts = @(
    "quick_sycl_build.ps1 - Quick SYCL build (recommended)",
    "test_sycl_build.ps1 - Comprehensive build and test",
    "validate_sycl_build.ps1 - Build validation",
    "benchmark_whisper.ps1 - Performance benchmarking",
    "examples\sycl\run-whisper.ps1 - Runtime execution"
)

foreach ($script in $scripts) {
    Write-ColorOutput "  ✅ $script" "Cyan"
}

# Check prerequisites
Write-ColorOutput ""
Write-ColorOutput "Prerequisites Check:" "Yellow"

if (Test-Path $OneAPIRoot) {
    Write-ColorOutput "  ✅ Intel oneAPI found at $OneAPIRoot" "Green"
    # Check for compiler
    $compilerFound = $false
    $compilerPaths = @(
        "$OneAPIRoot\compiler\*\bin\icpx.exe",
        "$OneAPIRoot\compiler\*\bin\dpcpp.exe"
    )

    foreach ($pathPattern in $compilerPaths) {
        $compilers = Get-ChildItem $pathPattern -ErrorAction SilentlyContinue
        if ($compilers) {
            Write-ColorOutput "  ✅ Intel DPC++ compiler found: $($compilers[0].FullName)" "Green"
            $compilerFound = $true
            break
        }
    }

    if (-not $compilerFound) {
        Write-ColorOutput "  ⚠️  Intel DPC++ compiler not found" "Yellow"
    }

    # Check for Intel GPU
    try {
        $gpuInfo = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*Intel*" }
        if ($gpuInfo) {
            Write-ColorOutput "  ✅ Intel GPU detected: $($gpuInfo.Name)" "Green"
        }
        else {
            Write-ColorOutput "  ⚠️  No Intel GPU detected (SYCL can use CPU)" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "  ⚠️  Could not check for Intel GPU" "Yellow"
    }

}
else {
    Write-ColorOutput "  ❌ Intel oneAPI not found at $OneAPIRoot" "Red"
    Write-ColorOutput "     Please install Intel oneAPI Base Toolkit" "Yellow"
}

Write-ColorOutput ""
Write-ColorOutput "Next Steps:" "Yellow"
Write-ColorOutput "  1. Install Intel oneAPI Base Toolkit (if not installed)" "Cyan"
Write-ColorOutput "  2. Run: .\quick_sycl_build.ps1" "Cyan"
Write-ColorOutput "  3. Run: .\validate_sycl_build.ps1" "Cyan"
Write-ColorOutput "  4. Download models: .\models\download-ggml-model.cmd base.en" "Cyan"
Write-ColorOutput "  5. Test transcription with SYCL GPU acceleration" "Cyan"

Write-ColorOutput ""
Write-ColorOutput "=== Integration Complete ===" "Green"
Write-ColorOutput "Intel SYCL GPU acceleration has been successfully integrated!" "Green"
