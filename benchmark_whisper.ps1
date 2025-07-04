# Whisper.cpp Benchmark System
# Compares performance across different build configurations
# Usage: .\benchmark_whisper.ps1 -AudioFile "path\to\audio.wav" -Model "path\to\model.bin"

param(
    [Parameter(Mandatory = $true)]
    [string]$AudioFile,

    [Parameter(Mandatory = $true)]
    [string]$Model,

    [string]$OutputDir = "benchmark_results",

    [string[]]$Configurations = @("original", "intel", "intel-mkl", "intel-ipp", "cuda", "intel-cuda"),

    [int]$Runs = 3,

    [switch]$CleanBuild
)

# Configuration definitions
$BuildConfigs = @{
    'original'  = @{
        'preset'      = 'default'
        'description' = 'Original build without Intel optimizations'
        'cmake_args'  = @()
    }
    'intel'     = @{
        'preset'      = 'intel-optimized'
        'description' = 'Intel optimized build with TBB'
        'cmake_args'  = @('-DWHISPER_TBB=ON')
    }
    'intel-mkl' = @{
        'preset'      = 'intel-mkl-optimized'
        'description' = 'Intel build with MKL optimizations'
        'cmake_args'  = @('-DWHISPER_MKL=ON', '-DWHISPER_TBB=ON')
    }
    'intel-ipp' = @{
        'preset'      = 'intel-ipp-optimized'
        'description' = 'Intel build with MKL and IPP optimizations'
        'cmake_args'  = @('-DWHISPER_MKL=ON', '-DWHISPER_IPP=ON', '-DWHISPER_TBB=ON')
    }
    'cuda'      = @{
        'preset'      = 'ninja-cuda'
        'description' = 'CUDA GPU accelerated build'
        'cmake_args'  = @('-DWHISPER_CUDA=ON')
    }    'intel-cuda' = @{
        'preset'      = 'ninja-intel-cuda'
        'description' = 'Combined Intel CPU optimizations with CUDA GPU acceleration'
        'cmake_args'  = @('-DWHISPER_MKL=ON', '-DWHISPER_IPP=ON', '-DWHISPER_TBB=ON', '-DWHISPER_CUDA=ON')
    }
    'sycl' = @{
        'preset'      = 'ninja-sycl'
        'description' = 'Intel SYCL GPU accelerated build'
        'cmake_args'  = @('-DWHISPER_SYCL=ON')
    }
    'intel-sycl' = @{
        'preset'      = 'ninja-intel-sycl'
        'description' = 'Full Intel oneAPI stack with SYCL GPU acceleration'
        'cmake_args'  = @('-DWHISPER_MKL=ON', '-DWHISPER_IPP=ON', '-DWHISPER_TBB=ON', '-DWHISPER_SYCL=ON')
    }
}

# Color output functions
function Write-ColorOutput {
    param([string]$Text, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Text -ForegroundColor Red }
        "Green" { Write-Host $Text -ForegroundColor Green }
        "Yellow" { Write-Host $Text -ForegroundColor Yellow }
        "Blue" { Write-Host $Text -ForegroundColor Blue }
        "Cyan" { Write-Host $Text -ForegroundColor Cyan }
        "Magenta" { Write-Host $Text -ForegroundColor Magenta }
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

# Validate inputs
function Test-Prerequisites {
    Write-Section "Validating Prerequisites"

    if (!(Test-Path $AudioFile)) {
        Write-Error "Audio file not found: $AudioFile"
        exit 1
    }
    Write-Success "Audio file found: $AudioFile"

    if (!(Test-Path $Model)) {
        Write-Error "Model file not found: $Model"
        exit 1
    }
    Write-Success "Model file found: $Model"

    # Check for required tools
    try {
        cmake --version | Out-Null
        Write-Success "CMake found"
    }
    catch {
        Write-Error "CMake not found. Please install CMake and add it to PATH."
        exit 1
    }

    try {
        msbuild -version | Out-Null
        Write-Success "MSBuild found"
    }
    catch {
        Write-Error "MSBuild not found. Please install Visual Studio Build Tools."
        exit 1
    }
}

# Build a specific configuration
function Build-Configuration {
    param([string]$ConfigName, [hashtable]$Config)

    Write-Step "Building configuration: $ConfigName"
    Write-Host "  Description: $($Config.description)"

    $buildDir = "build_$ConfigName"

    if ($CleanBuild -and (Test-Path $buildDir)) {
        Write-Step "Cleaning previous build directory"
        Remove-Item -Recurse -Force $buildDir
    }

    # Configure
    Write-Step "Configuring CMake"
    $cmakeConfigArgs = @(
        "-B", $buildDir,
        "-DCMAKE_BUILD_TYPE=Release",
        "-DWHISPER_BUILD_TESTS=OFF",
        "-DWHISPER_BUILD_EXAMPLES=ON"
    ) + $Config.cmake_args

    Write-Host "  CMake args: $($cmakeConfigArgs -join ' ')"

    $configResult = & cmake @cmakeConfigArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "CMake configuration failed for $ConfigName"
        Write-Host $configResult
        return $false
    }

    # Build
    Write-Step "Building"
    $buildResult = & cmake --build $buildDir --config Release --parallel 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed for $ConfigName"
        Write-Host $buildResult
        return $false
    }

    Write-Success "Build completed for $ConfigName"
    return $true
}

# Run benchmark for a configuration
function Run-Benchmark {
    param([string]$ConfigName, [int]$RunNumber)

    $buildDir = "build_$ConfigName"
    $exePath = "$buildDir\bin\Release\whisper-cli.exe"

    if (!(Test-Path $exePath)) {
        Write-Error "Executable not found: $exePath"
        return $null
    }

    Write-Step "Running benchmark $RunNumber for $ConfigName"

    # Capture timing and output
    $startTime = Get-Date

    $output = & $exePath -m $Model -f $AudioFile --print-progress --print-colors --output-txt 2>&1
    $exitCode = $LASTEXITCODE

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds

    if ($exitCode -ne 0) {
        Write-Error "Benchmark failed for $ConfigName (run $RunNumber)"
        Write-Host $output
        return $null
    }

    # Extract performance metrics from output
    $loadTime = $null
    $melTime = $null
    $encodeTime = $null
    $decodeTime = $null
    $totalTime = $null

    $output | ForEach-Object {
        if ($_ -match "whisper_model_load: loading model.*took\s+(\d+\.\d+)\s*ms") {
            $loadTime = [float]$matches[1]
        }
        if ($_ -match "whisper_pcm_to_mel:.*took\s+(\d+\.\d+)\s*ms") {
            $melTime = [float]$matches[1]
        }
        if ($_ -match "whisper_encode:.*took\s+(\d+\.\d+)\s*ms") {
            $encodeTime = [float]$matches[1]
        }
        if ($_ -match "whisper_decode:.*took\s+(\d+\.\d+)\s*ms") {
            $decodeTime = [float]$matches[1]
        }
        if ($_ -match "whisper_print_timings:\s+total time\s+=\s+(\d+\.\d+)\s*ms") {
            $totalTime = [float]$matches[1]
        }
    }

    return @{
        'configuration'    = $ConfigName
        'run'              = $RunNumber
        'duration_seconds' = $duration
        'load_time_ms'     = $loadTime
        'mel_time_ms'      = $melTime
        'encode_time_ms'   = $encodeTime
        'decode_time_ms'   = $decodeTime
        'total_time_ms'    = $totalTime
        'exit_code'        = $exitCode
        'timestamp'        = $startTime.ToString("yyyy-MM-dd HH:mm:ss")
    }
}

# Generate benchmark report
function Generate-Report {
    param([array]$Results)

    Write-Section "Generating Benchmark Report"

    # Ensure output directory exists
    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportFile = "$OutputDir\benchmark_report_$timestamp.json"
    $summaryFile = "$OutputDir\benchmark_summary_$timestamp.txt"

    # Save detailed results as JSON
    $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Success "Detailed results saved to: $reportFile"

    # Generate summary report
    $summary = @"
WHISPER.CPP BENCHMARK SUMMARY
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Audio File: $AudioFile
Model File: $Model
Runs per Configuration: $Runs

PERFORMANCE COMPARISON:
"@

    # Group results by configuration and calculate averages
    $configStats = @{}

    foreach ($result in $Results) {
        if ($result -eq $null) { continue }

        $config = $result.configuration
        if (!$configStats.ContainsKey($config)) {
            $configStats[$config] = @{
                'runs'        = @()
                'description' = $BuildConfigs[$config].description
            }
        }
        $configStats[$config].runs += $result
    }

    # Calculate and display averages
    foreach ($config in $configStats.Keys | Sort-Object) {
        $runs = $configStats[$config].runs
        $validRuns = $runs | Where-Object { $_.total_time_ms -ne $null }

        if ($validRuns.Count -eq 0) {
            $summary += "`n`n$config ($(($BuildConfigs[$config].description))):`n  No valid runs completed"
            continue
        }

        $avgTotal = ($validRuns | Measure-Object -Property total_time_ms -Average).Average
        $avgLoad = ($validRuns | Measure-Object -Property load_time_ms -Average).Average
        $avgMel = ($validRuns | Measure-Object -Property mel_time_ms -Average).Average
        $avgEncode = ($validRuns | Measure-Object -Property encode_time_ms -Average).Average
        $avgDecode = ($validRuns | Measure-Object -Property decode_time_ms -Average).Average

        $summary += "`n`n$config ($($BuildConfigs[$config].description)):"
        $summary += "`n  Valid runs: $($validRuns.Count)/$($runs.Count)"
        $summary += "`n  Average total time: $([math]::Round($avgTotal, 2)) ms"
        $summary += "`n  Average load time: $([math]::Round($avgLoad, 2)) ms"
        $summary += "`n  Average mel time: $([math]::Round($avgMel, 2)) ms"
        $summary += "`n  Average encode time: $([math]::Round($avgEncode, 2)) ms"
        $summary += "`n  Average decode time: $([math]::Round($avgDecode, 2)) ms"
    }

    # Performance comparison (relative to original)
    if ($configStats.ContainsKey('original') -and $configStats['original'].runs.Count -gt 0) {
        $originalAvg = ($configStats['original'].runs | Where-Object { $_.total_time_ms -ne $null } | Measure-Object -Property total_time_ms -Average).Average

        $summary += "`n`nPERFORMANCE IMPROVEMENTS (relative to original):"

        foreach ($config in $configStats.Keys | Sort-Object) {
            if ($config -eq 'original') { continue }

            $validRuns = $configStats[$config].runs | Where-Object { $_.total_time_ms -ne $null }
            if ($validRuns.Count -eq 0) { continue }

            $configAvg = ($validRuns | Measure-Object -Property total_time_ms -Average).Average
            $improvement = (($originalAvg - $configAvg) / $originalAvg) * 100

            if ($improvement -gt 0) {
                $summary += "`n  $config`: $([math]::Round($improvement, 1))% faster"
            }
            else {
                $summary += "`n  $config`: $([math]::Round(-$improvement, 1))% slower"
            }
        }
    }

    $summary += "`n`nDetailed results available in: $reportFile"

    # Save summary
    $summary | Out-File -FilePath $summaryFile -Encoding UTF8
    Write-Success "Summary report saved to: $summaryFile"

    # Display summary
    Write-Host ""
    Write-ColorOutput $summary "White"
}

# Main execution
try {
    Write-Section "Whisper.cpp Benchmark System"
    Write-Host "Configurations to test: $($Configurations -join ', ')"
    Write-Host "Runs per configuration: $Runs"
    Write-Host "Output directory: $OutputDir"

    Test-Prerequisites

    $allResults = @()

    # Build and test each configuration
    foreach ($configName in $Configurations) {
        if (!$BuildConfigs.ContainsKey($configName)) {
            Write-Error "Unknown configuration: $configName"
            continue
        }

        Write-Section "Configuration: $configName"

        $config = $BuildConfigs[$configName]

        # Build
        $buildSuccess = Build-Configuration -ConfigName $configName -Config $config
        if (!$buildSuccess) {
            Write-Error "Skipping benchmarks for $configName due to build failure"
            continue
        }

        # Run benchmarks
        Write-Step "Running $Runs benchmark(s)"
        for ($i = 1; $i -le $Runs; $i++) {
            $result = Run-Benchmark -ConfigName $configName -RunNumber $i
            $allResults += $result

            if ($result -ne $null) {
                Write-Success "Run $i completed in $([math]::Round($result.duration_seconds, 2)) seconds"
            }
        }
    }

    # Generate report
    if ($allResults.Count -gt 0) {
        Generate-Report -Results $allResults
        Write-Success "Benchmark completed successfully!"
    }
    else {
        Write-Error "No benchmark results to report"
        exit 1
    }

}
catch {
    Write-Error "Benchmark failed with error: $($_.Exception.Message)"
    Write-Host $_.ScriptStackTrace
    exit 1
}
