#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Simple benchmark runner for whisper.cpp with different scenarios

.DESCRIPTION
    This script provides easy-to-use benchmark scenarios for testing whisper.cpp performance
    across different build configurations. Uses benchmark-config.ps1 for configuration.

.PARAMETER Scenario
    Pre-defined test scenario: quick, standard, comprehensive, stress-test

.PARAMETER Configurations
    Specific configurations to test (comma-separated)

.PARAMETER AudioFiles
    Specific audio files to test (comma-separated)

.PARAMETER Iterations
    Number of iterations per test

.PARAMETER OutputDir
    Directory to save results (default: benchmark-results)

.EXAMPLE
    ./run-benchmark.ps1 -Scenario quick
    Run quick benchmark scenario

.EXAMPLE
    ./run-benchmark.ps1 -Configurations "current-build,intel-optimized" -AudioFiles "jfk-short"
    Test specific configurations with specific audio

.EXAMPLE
    ./run-benchmark.ps1 -Scenario comprehensive -OutputDir "detailed-results"
    Run comprehensive benchmark and save to custom directory
#>

param(
    [ValidateSet("quick", "standard", "comprehensive", "stress-test")]
    [string]$Scenario = "standard",
    [string[]]$Configurations = @(),
    [string[]]$AudioFiles = @(),
    [int]$Iterations = 0,
    [string]$OutputDir = "benchmark-results"
)

$ErrorActionPreference = "Stop"

# Load configuration
. "$PSScriptRoot\benchmark-config.ps1"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "Cyan" }
    }
    Write-Host "[$timestamp] " -ForegroundColor Gray -NoNewline
    Write-Host "[$Level] " -ForegroundColor $color -NoNewline
    Write-Host $Message
}

function Get-ScenarioConfig {
    param([string]$ScenarioName)

    if (-not $BenchmarkConfig.TestScenarios.ContainsKey($ScenarioName)) {
        throw "Unknown scenario: $ScenarioName. Available scenarios: $($BenchmarkConfig.TestScenarios.Keys -join ', ')"
    }

    return $BenchmarkConfig.TestScenarios[$ScenarioName]
}

function Test-ConfigurationPrerequisites {
    param([string]$ConfigName, [hashtable]$Config)

    # Check if configuration has system requirements
    if ($BenchmarkConfig.SystemRequirements.ContainsKey($ConfigName)) {
        $requirements = $BenchmarkConfig.SystemRequirements[$ConfigName]

        # Check required tools
        if ($requirements.RequiredTools) {
            foreach ($tool in $requirements.RequiredTools) {
                try {
                    & $tool --version 2>&1 | Out-Null
                    Write-Log "✓ $tool is available"
                }
                catch {
                    Write-Log "✗ Required tool '$tool' not found for configuration '$ConfigName'" "ERROR"
                    return $false
                }
            }
        }

        # Check required environment variables
        if ($requirements.Environment) {
            foreach ($envVar in $requirements.Environment) {
                if (-not (Get-ChildItem Env: | Where-Object Name -eq $envVar)) {
                    Write-Log "✗ Required environment variable '$envVar' not set for configuration '$ConfigName'" "WARN"
                }
            }
        }
    }

    return $true
}

function Build-BenchmarkCommand {
    param([hashtable]$ScenarioConfig, [string[]]$OverrideConfigs, [string[]]$OverrideAudioFiles, [int]$OverrideIterations)

    $args = @()

    # Determine configurations to test
    $configsToTest = if ($OverrideConfigs.Count -gt 0) { $OverrideConfigs } else { $ScenarioConfig.Configurations }
    if ($configsToTest.Count -gt 0) {
        $args += "-ConfigName"
        $args += ($configsToTest -join ",")
    }

    # Determine audio files to test
    $audioToTest = if ($OverrideAudioFiles.Count -gt 0) { $OverrideAudioFiles } else { $ScenarioConfig.AudioFiles }
    if ($audioToTest.Count -gt 0) {
        $args += "-AudioFiles"
        $args += ($audioToTest -join ",")
    }

    # Determine iterations
    $iterationsToUse = if ($OverrideIterations -gt 0) { $OverrideIterations } else { $ScenarioConfig.Iterations }
    $args += "-Iterations"
    $args += $iterationsToUse

    # Add output format
    $args += "-OutputFormat"
    $args += "all"

    return $args
}

function Show-ScenarioInfo {
    param([hashtable]$ScenarioConfig, [string[]]$FinalConfigs, [string[]]$FinalAudioFiles, [int]$FinalIterations)

    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host " BENCHMARK SCENARIO: $($ScenarioConfig.Name.ToUpper())" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "Description: $($ScenarioConfig.Description)" -ForegroundColor White
    Write-Host "`nTest Configuration:" -ForegroundColor Yellow
    Write-Host "  Configurations: $($FinalConfigs -join ', ')" -ForegroundColor White
    Write-Host "  Audio Files: $($FinalAudioFiles -join ', ')" -ForegroundColor White
    Write-Host "  Iterations: $FinalIterations" -ForegroundColor White
    Write-Host "  Output Directory: $OutputDir" -ForegroundColor White
    Write-Host ""
}

function Show-AvailableConfigurations {
    Write-Host "`nAvailable Build Configurations:" -ForegroundColor Yellow
    foreach ($configPair in $BenchmarkConfig.BuildConfigurations.GetEnumerator()) {
        $config = $configPair.Value
        $status = if ($config.Enabled -eq $false) { " (DISABLED)" } else { "" }
        Write-Host "  $($configPair.Key): $($config.Name)$status" -ForegroundColor White
        Write-Host "    $($config.Description)" -ForegroundColor Gray
        Write-Host "    Features: $($config.Features -join ', ')" -ForegroundColor Gray
    }
}

function Show-AvailableAudioTests {
    Write-Host "`nAvailable Audio Tests:" -ForegroundColor Yellow
    foreach ($audioPair in $BenchmarkConfig.AudioTestSuite.GetEnumerator()) {
        $audio = $audioPair.Value
        $status = if ($audio.Enabled -eq $false) { " (DISABLED)" } else { "" }
        $exists = if (Test-Path $audio.File) { "✓" } else { "✗" }
        Write-Host "  $($audioPair.Key): $($audio.Description)$status [$exists]" -ForegroundColor White
        Write-Host "    File: $($audio.File) | Duration: $($audio.Duration)s | Priority: $($audio.Priority)" -ForegroundColor Gray
    }
}

# Main execution
try {
    Write-Log "Starting Whisper.cpp Benchmark Runner" "SUCCESS"

    # Create output directory
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
        Write-Log "Created output directory: $OutputDir"
    }

    # Get scenario configuration
    $scenarioConfig = Get-ScenarioConfig $Scenario

    # Determine final configuration
    $finalConfigs = if ($Configurations.Count -gt 0) { $Configurations } else {
        if ($scenarioConfig.Configurations.Count -gt 0) { $scenarioConfig.Configurations } else {
            $BenchmarkConfig.BuildConfigurations.Keys | Where-Object { $BenchmarkConfig.BuildConfigurations[$_].Enabled -ne $false }
        }
    }

    $finalAudioFiles = if ($AudioFiles.Count -gt 0) { $AudioFiles } else {
        if ($scenarioConfig.AudioFiles.Count -gt 0) { $scenarioConfig.AudioFiles } else {
            $BenchmarkConfig.AudioTestSuite.Keys | Where-Object { $BenchmarkConfig.AudioTestSuite[$_].Enabled -ne $false }
        }
    }

    $finalIterations = if ($Iterations -gt 0) { $Iterations } else { $scenarioConfig.Iterations }

    # Show scenario information
    Show-ScenarioInfo $scenarioConfig $finalConfigs $finalAudioFiles $finalIterations

    # Check prerequisites for selected configurations
    Write-Log "Checking prerequisites for selected configurations..."
    $validConfigs = @()
    foreach ($configName in $finalConfigs) {
        if ($BenchmarkConfig.BuildConfigurations.ContainsKey($configName)) {
            $config = $BenchmarkConfig.BuildConfigurations[$configName]
            if ($config.Enabled -ne $false) {
                if (Test-ConfigurationPrerequisites $configName $config) {
                    $validConfigs += $configName
                    Write-Log "✓ Configuration '$configName' is ready" "SUCCESS"
                }
                else {
                    Write-Log "✗ Configuration '$configName' failed prerequisite check" "WARN"
                }
            }
            else {
                Write-Log "Configuration '$configName' is disabled" "WARN"
            }
        }
        else {
            Write-Log "Unknown configuration: $configName" "WARN"
        }
    }

    if ($validConfigs.Count -eq 0) {
        Write-Log "No valid configurations found to test" "ERROR"
        Show-AvailableConfigurations
        exit 1
    }

    # Check audio files
    Write-Log "Checking audio files..."
    $validAudioFiles = @()
    foreach ($audioName in $finalAudioFiles) {
        if ($BenchmarkConfig.AudioTestSuite.ContainsKey($audioName)) {
            $audioConfig = $BenchmarkConfig.AudioTestSuite[$audioName]
            if (Test-Path $audioConfig.File) {
                $validAudioFiles += $audioName
                Write-Log "✓ Audio file '$audioName' found: $($audioConfig.File)" "SUCCESS"
            }
            else {
                Write-Log "✗ Audio file '$audioName' not found: $($audioConfig.File)" "WARN"
            }
        }
        else {
            Write-Log "Unknown audio test: $audioName" "WARN"
        }
    }

    if ($validAudioFiles.Count -eq 0) {
        Write-Log "No valid audio files found to test" "ERROR"
        Show-AvailableAudioTests
        exit 1
    }

    # Build command arguments for main benchmark script
    $benchmarkArgs = Build-BenchmarkCommand $scenarioConfig $validConfigs $validAudioFiles $finalIterations

    Write-Log "Starting benchmark execution..."
    Write-Log "Command: ./benchmark-whisper.ps1 $($benchmarkArgs -join ' ')"

    # Change to output directory and run benchmark
    Push-Location $OutputDir
    try {
        & "$PSScriptRoot\benchmark-whisper.ps1" @benchmarkArgs
    }
    finally {
        Pop-Location
    }

    Write-Log "Benchmark completed! Results saved in: $OutputDir" "SUCCESS"

    # Show available result files
    $resultFiles = Get-ChildItem -Path $OutputDir -Filter "benchmark_results_*" | Sort-Object LastWriteTime -Descending
    if ($resultFiles.Count -gt 0) {
        Write-Log "Generated result files:"
        foreach ($file in $resultFiles) {
            Write-Log "  $($file.Name)" "SUCCESS"
        }
    }

}
catch {
    Write-Log "Benchmark runner failed: $($_.Exception.Message)" "ERROR"

    if ($_.Exception.Message -match "Unknown scenario") {
        Write-Host "`nAvailable scenarios:" -ForegroundColor Yellow
        foreach ($scenarioPair in $BenchmarkConfig.TestScenarios.GetEnumerator()) {
            Write-Host "  $($scenarioPair.Key): $($scenarioPair.Value.Name)" -ForegroundColor White
            Write-Host "    $($scenarioPair.Value.Description)" -ForegroundColor Gray
        }
    }

    exit 1
}
