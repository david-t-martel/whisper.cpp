# Whisper.cpp Benchmark System

This directory contains benchmarking tools to compare performance across different build configurations of whisper.cpp.

## Overview

The benchmark system allows you to:
- Compare performance between original and Intel-optimized builds
- Test different optimization levels (TBB, MKL, IPP)
- Generate detailed performance reports
- Track improvements over time

## Prerequisites

1. **Audio samples**: Download test audio files to the `samples/` directory
2. **Models**: Download whisper models to the `models/` directory
3. **Build tools**: CMake, Visual Studio Build Tools, and Intel oneAPI (for optimized builds)

### Quick Setup

```powershell
# Download a test model
New-Item -ItemType Directory -Path "models" -Force
Invoke-WebRequest -Uri "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" -OutFile "models\ggml-base.en.bin"

# Use existing audio samples
# samples/jfk.wav, samples/mm1.wav, samples/a13.wav are already available
```

## Benchmark Scripts

### 1. Quick Benchmark (`quick_benchmark.ps1`)

Simple comparison between original and Intel optimized builds.

```powershell
# Quick test with default files
.\quick_benchmark.ps1

# Quick test with custom files
.\quick_benchmark.ps1 -AudioFile "samples\jfk.wav" -Model "models\ggml-base.en.bin"

# Build and test
.\quick_benchmark.ps1 -BuildFirst
```

**Features:**
- Fast execution (single run per configuration)
- Automatic build if needed
- Side-by-side performance comparison
- Color-coded output

### 2. Comprehensive Benchmark (`benchmark_whisper.ps1`)

Full benchmark suite with multiple configurations and statistical analysis.

```powershell
# Full benchmark with all configurations
.\benchmark_whisper.ps1 -AudioFile "samples\jfk.wav" -Model "models\ggml-base.en.bin"

# Custom configurations and runs
.\benchmark_whisper.ps1 -AudioFile "samples\mm1.wav" -Model "models\ggml-base.en.bin" -Configurations @("original", "intel-mkl") -Runs 5

# Clean builds
.\benchmark_whisper.ps1 -AudioFile "samples\a13.wav" -Model "models\ggml-base.en.bin" -CleanBuild

# Custom output directory
.\benchmark_whisper.ps1 -AudioFile "samples\jfk.wav" -Model "models\ggml-base.en.bin" -OutputDir "my_benchmark_results"
```

**Features:**
- Multiple build configurations
- Statistical analysis (multiple runs, averages)
- Detailed JSON reports
- Human-readable summary reports
- Performance improvement calculations
- Extensible configuration system

## Build Configurations

### Available Configurations

1. **original**: Standard build without Intel optimizations
   - Uses default threading
   - Baseline performance reference

2. **intel**: Intel optimized build with TBB
   - Uses Intel Threading Building Blocks
   - Improved parallel processing

3. **intel-mkl**: Intel build with MKL optimizations
   - Uses Intel Math Kernel Library
   - Optimized BLAS operations
   - Enhanced FFT performance

4. **intel-ipp**: Intel build with MKL and IPP optimizations
   - Uses Intel Math Kernel Library + Intel Performance Primitives
   - Optimized audio processing
   - Enhanced signal processing functions

### Adding New Configurations

Edit the `$BuildConfigs` hashtable in `benchmark_whisper.ps1`:

```powershell
$BuildConfigs = @{
    'my-config' = @{
        'preset' = 'my-preset'
        'description' = 'My custom build configuration'
        'cmake_args' = @('-DMY_OPTION=ON', '-DANOTHER_OPTION=OFF')
    }
}
```

## Output and Reports

### Quick Benchmark Output

```
=== Quick Whisper.cpp Performance Test ===

Using audio file: samples\jfk.wav
Using model: models\ggml-base.en.bin

Testing Original Build...
  Duration: 8.45 seconds
  Processing time: 7234.5 ms

Testing Intel Optimized Build...
  Duration: 6.23 seconds
  Processing time: 5456.2 ms

=== Performance Comparison ===
Intel build is 24.6% FASTER
Overall execution is 26.3% faster
```

### Comprehensive Benchmark Output

The comprehensive benchmark generates two types of reports:

1. **JSON Report** (`benchmark_report_YYYYMMDD_HHMMSS.json`):
   - Detailed results for each run
   - Raw performance metrics
   - Machine-readable format for analysis

2. **Summary Report** (`benchmark_summary_YYYYMMDD_HHMMSS.txt`):
   - Human-readable summary
   - Average performance metrics
   - Performance improvements comparison

Example summary:
```
WHISPER.CPP BENCHMARK SUMMARY
Generated: 2025-01-27 14:30:15
Audio File: samples\jfk.wav
Model File: models\ggml-base.en.bin
Runs per Configuration: 3

PERFORMANCE COMPARISON:

original (Original build without Intel optimizations):
  Valid runs: 3/3
  Average total time: 7234.5 ms
  Average load time: 234.2 ms
  Average mel time: 1234.5 ms
  Average encode time: 3456.7 ms
  Average decode time: 2309.1 ms

intel-ipp (Intel build with MKL and IPP optimizations):
  Valid runs: 3/3
  Average total time: 5456.2 ms
  Average load time: 198.3 ms
  Average mel time: 892.1 ms
  Average encode time: 2678.9 ms
  Average decode time: 1686.9 ms

PERFORMANCE IMPROVEMENTS (relative to original):
  intel-ipp: 24.6% faster
```

## Troubleshooting

### Common Issues

1. **"Audio file not found"**
   - Ensure audio files exist in the specified path
   - Use `Get-ChildItem samples\*.wav` to list available files

2. **"Model file not found"**
   - Download models to the `models/` directory
   - Check the model path and filename

3. **"CMake not found"**
   - Install CMake and add it to your PATH
   - Verify with `cmake --version`

4. **"MSBuild not found"**
   - Install Visual Studio Build Tools
   - Verify with `msbuild -version`

5. **Build failures**
   - Ensure Intel oneAPI is installed for Intel-optimized builds
   - Check CMake configuration output for errors
   - Try building manually first

### Debug Mode

For detailed build output, run CMake commands manually:

```powershell
# Configure with verbose output
cmake -B build_debug -DCMAKE_BUILD_TYPE=Release -DWHISPER_MKL=ON -DWHISPER_IPP=ON --verbose

# Build with verbose output
cmake --build build_debug --config Release --verbose
```

## Performance Tips

1. **Use Release builds**: Always use `-DCMAKE_BUILD_TYPE=Release` for benchmarking
2. **Close other applications**: Minimize system load during benchmarking
3. **Use consistent audio**: Same audio file across all tests for fair comparison
4. **Multiple runs**: Use multiple runs to account for system variance
5. **Warm-up runs**: Consider running a warm-up before actual benchmarking

## Extending the System

### Adding New Metrics

Modify the `Run-Benchmark` function to extract additional metrics:

```powershell
# Add new metric extraction
if ($_ -match "my_custom_metric:\s+(\d+\.\d+)\s*ms") {
    $customMetric = [float]$matches[1]
}

# Add to result object
return @{
    # ... existing metrics ...
    'custom_metric_ms' = $customMetric
}
```

### Adding New Build Types

1. Add configuration to `$BuildConfigs`
2. Ensure required dependencies are available
3. Test manually first
4. Add to default configurations list if stable

### Integration with CI/CD

The benchmark system can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Performance Benchmark
  run: |
    .\benchmark_whisper.ps1 -AudioFile "samples\jfk.wav" -Model "models\ggml-base.en.bin" -Configurations @("original", "intel-ipp") -Runs 1
```

## Files Generated

- `build_*/`: Build directories for each configuration
- `benchmark_results/`: Default output directory
- `benchmark_report_*.json`: Detailed results
- `benchmark_summary_*.txt`: Human-readable summaries

## License

This benchmark system is part of the whisper.cpp project and follows the same license terms.
