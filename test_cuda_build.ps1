# CUDA Build Test Script for Whisper.cpp
# Tests CUDA build configuration and functionality
# Usage: .\test_cuda_build.ps1 [-TestExecution]

param(
    [switch]$TestExecution,
    [string]$Model = "models\ggml-base.en.bin",
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
        default { Write-Host $Text }
    }
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "==== $Title ====" "Cyan"
    Write-Host ""
}

function Write-Step {
    param([string]$Step)
    Write-ColorOutput "➤ $Step" "Yellow"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

# Test prerequisites
function Test-Prerequisites {
    Write-Section "Testing CUDA Prerequisites"

    # Test CUDA Toolkit
    try {
        $nvccOutput = & nvcc --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "CUDA Toolkit found: nvcc available"
            Write-Host "  $($nvccOutput | Select-String 'release')"
        }
        else {
            Write-Error "CUDA Toolkit not found or nvcc not in PATH"
            return $false
        }
    }
    catch {
        Write-Error "CUDA Toolkit not found: $($_.Exception.Message)"
        return $false
    }

    # Test NVIDIA GPU
    try {
        $nvidiaOutput = & nvidia-smi --query-gpu=name, memory.total --format=csv, noheader, nounits 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "NVIDIA GPU(s) detected:"
            $nvidiaOutput | ForEach-Object {
                Write-Host "  $_"
            }
        }
        else {
            Write-Error "No NVIDIA GPU detected or nvidia-smi not available"
            return $false
        }
    }
    catch {
        Write-Error "GPU detection failed: $($_.Exception.Message)"
        return $false
    }

    # Test CMake
    try {
        cmake --version | Out-Null
        Write-Success "CMake found"
    }
    catch {
        Write-Error "CMake not found. Please install CMake and add it to PATH."
        return $false
    }

    return $true
}

# Build CUDA configuration
function Build-CudaConfiguration {
    Write-Section "Building CUDA Configuration"

    $buildDir = "build_cuda_test"

    # Clean previous build
    if (Test-Path $buildDir) {
        Write-Step "Cleaning previous build directory"
        Remove-Item -Recurse -Force $buildDir
    }

    # Configure
    Write-Step "Configuring CMake with CUDA"
    $configResult = & cmake -B $buildDir -DCMAKE_BUILD_TYPE=Release -DWHISPER_CUDA=ON -DWHISPER_BUILD_EXAMPLES=ON 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "CMake configuration failed"
        Write-Host $configResult
        return $false
    }
    Write-Success "CMake configuration completed"

    # Build
    Write-Step "Building CUDA-enabled whisper.cpp"
    $buildResult = & cmake --build $buildDir --config Release --parallel 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed"
        Write-Host $buildResult
        return $false
    }
    Write-Success "Build completed successfully"

    return $true
}

# Test CUDA functionality
function Test-CudaFunctionality {
    param([string]$BuildDir)

    Write-Section "Testing CUDA Functionality"

    $exePath = "$BuildDir\bin\Release\whisper-cli.exe"

    if (!(Test-Path $exePath)) {
        Write-Error "whisper-cli.exe not found at: $exePath"
        return $false
    }

    if (!(Test-Path $Model)) {
        Write-Error "Model file not found: $Model"
        Write-Host "Please ensure the model file exists or specify a different path"
        return $false
    }

    if (!(Test-Path $AudioFile)) {
        Write-Error "Audio file not found: $AudioFile"
        Write-Host "Please ensure the audio file exists or specify a different path"
        return $false
    }

    Write-Step "Running CUDA-accelerated inference test"
    Write-Host "Command: $exePath -m $Model -f $AudioFile"

    $startTime = Get-Date
    $output = & $exePath -m $Model -f $AudioFile 2>&1
    $endTime = Get-Date

    if ($LASTEXITCODE -ne 0) {
        Write-Error "CUDA inference test failed"
        Write-Host $output
        return $false
    }

    $duration = ($endTime - $startTime).TotalSeconds
    Write-Success "CUDA inference test completed in $([math]::Round($duration, 2)) seconds"

    # Check for GPU usage indicators in output
    $gpuDetected = $false
    $output | ForEach-Object {
        if ($_ -match "CUDA|GPU|cuda" -and $_ -notmatch "no GPU found") {
            $gpuDetected = $true
            Write-Success "GPU utilization detected: $_"
        }
    }

    if (!$gpuDetected) {
        Write-Error "No GPU utilization detected in output. CUDA may not be active."
        Write-Host "Output excerpt:"
        $output | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
        return $false
    }

    return $true
}

# Generate test report
function Generate-TestReport {
    param([bool]$PrereqsPassed, [bool]$BuildPassed, [bool]$ExecutionPassed)

    Write-Section "CUDA Integration Test Report"

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $report = @"
WHISPER.CPP CUDA INTEGRATION TEST REPORT
Generated: $timestamp

TEST RESULTS:
"@

    $report += "`n  Prerequisites Check: $(if ($PrereqsPassed) { "✓ PASSED" } else { "✗ FAILED" })"
    $report += "`n  CUDA Build Test:     $(if ($BuildPassed) { "✓ PASSED" } else { "✗ FAILED" })"

    if ($TestExecution) {
        $report += "`n  CUDA Execution Test: $(if ($ExecutionPassed) { "✓ PASSED" } else { "✗ FAILED" })"
    }
    else {
        $report += "`n  CUDA Execution Test: SKIPPED (use -TestExecution to enable)"
    }

    $overallSuccess = $PrereqsPassed -and $BuildPassed -and ($ExecutionPassed -or !$TestExecution)
    $report += "`n`nOVERALL RESULT: $(if ($overallSuccess) { "✓ SUCCESS" } else { "✗ FAILURE" })"

    if ($overallSuccess) {
        $report += "`n`nCUDA integration is ready for use!"
        $report += "`nNext steps:"
        $report += "`n  1. Run full benchmark: .\benchmark_whisper.ps1 -Configurations @('original', 'cuda')"
        $report += "`n  2. Test with different models and audio files"
        $report += "`n  3. Monitor GPU memory usage with nvidia-smi"
    }
    else {
        $report += "`n`nCUDA integration requires fixes before use."
        $report += "`nTroubleshooting:"
        if (!$PrereqsPassed) {
            $report += "`n  - Install CUDA Toolkit 11.8 or later"
            $report += "`n  - Ensure NVIDIA GPU drivers are up to date"
            $report += "`n  - Verify nvcc and nvidia-smi are in PATH"
        }
        if (!$BuildPassed) {
            $report += "`n  - Check CMake CUDA language support"
            $report += "`n  - Verify CUDA Toolkit compatibility"
            $report += "`n  - Review CMake configuration output"
        }
        if ($TestExecution -and !$ExecutionPassed) {
            $report += "`n  - Check GPU memory availability"
            $report += "`n  - Verify model and audio file paths"
            $report += "`n  - Review application output for errors"
        }
    }

    Write-Host ""
    Write-ColorOutput $report "White"

    # Save report to file
    $reportFile = "cuda_test_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $report | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Success "Test report saved to: $reportFile"

    return $overallSuccess
}

# Main execution
try {
    Write-Section "Whisper.cpp CUDA Integration Test"

    $prereqsPassed = Test-Prerequisites
    if (!$prereqsPassed) {
        Generate-TestReport -PrereqsPassed $false -BuildPassed $false -ExecutionPassed $false
        exit 1
    }

    $buildPassed = Build-CudaConfiguration
    if (!$buildPassed) {
        Generate-TestReport -PrereqsPassed $true -BuildPassed $false -ExecutionPassed $false
        exit 1
    }

    $executionPassed = $true
    if ($TestExecution) {
        $executionPassed = Test-CudaFunctionality -BuildDir "build_cuda_test"
    }

    $overallSuccess = Generate-TestReport -PrereqsPassed $true -BuildPassed $true -ExecutionPassed $executionPassed

    if ($overallSuccess) {
        Write-Success "CUDA integration test completed successfully!"
        exit 0
    }
    else {
        Write-Error "CUDA integration test failed"
        exit 1
    }

}
catch {
    Write-Error "Test failed with exception: $($_.Exception.Message)"
    Write-Host $_.ScriptStackTrace
    exit 1
}
