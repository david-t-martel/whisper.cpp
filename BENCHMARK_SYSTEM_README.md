# Whisper.cpp Benchmark System

## Overview

This comprehensive benchmark system provides automated performance testing and comparison of different whisper.cpp build configurations. It's designed to be easily extensible for future optimizations like CUDA, OpenCL, Metal, and other accelerations.

## Key Features

- **Modular Design**: Easy to add new build configurations and test scenarios
- **Multiple Output Formats**: Console, JSON, HTML, and CSV reports
- **Performance Metrics**: Transcription time, memory usage, accuracy, and throughput
- **Visual Reports**: Interactive HTML reports with charts
- **Extensible**: Templates ready for CUDA, OpenCL, Metal, and WebAssembly builds
- **Automated**: Can run comprehensive test suites with minimal user input

## Components

### 1. Main Benchmark Script (`benchmark-whisper.ps1`)
The core benchmarking engine that:
- Builds multiple configurations
- Runs performance tests with multiple iterations
- Collects detailed metrics
- Generates comprehensive reports

### 2. Configuration File (`benchmark-config.ps1`)
Centralized configuration for:
- Build configurations (baseline, TBB, Intel MKL+IPP, CUDA, etc.)
- Audio test suites
- Performance metrics definitions
- System requirements

### 3. Scenario Runner (`run-benchmark.ps1`)
Simplified interface providing pre-defined test scenarios:
- `quick`: Fast test with essential configurations
- `standard`: Comprehensive test of all enabled configurations
- `comprehensive`: Full benchmark suite with all tests
- `stress-test`: Long-running tests with large audio files

### 4. Quick Comparison (`quick-compare.ps1`)
Simple head-to-head comparison between baseline and Intel-optimized builds.

## Usage Examples

### Quick Performance Check
```powershell
# Simple comparison between baseline and Intel builds
./quick-compare.ps1

# Skip building, use existing binaries
./quick-compare.ps1 -SkipBuild
```

### Scenario-Based Testing
```powershell
# Run quick benchmark (2 configs, 1 audio file, 2 iterations)
./run-benchmark.ps1 -Scenario quick

# Run standard benchmark (all configs, primary audio files, 3 iterations)
./run-benchmark.ps1 -Scenario standard

# Run comprehensive benchmark (all configs, all audio files, 5 iterations)
./run-benchmark.ps1 -Scenario comprehensive
```

### Custom Testing
```powershell
# Test specific configurations
./run-benchmark.ps1 -Configurations "current-build,intel-optimized" -AudioFiles "jfk-short"

# Test with custom iterations and output directory
./run-benchmark.ps1 -Scenario standard -Iterations 5 -OutputDir "detailed-results"
```

### Full Benchmark Suite
```powershell
# Complete benchmark with all options
./benchmark-whisper.ps1 -OutputFormat all -Iterations 5

# Test specific configuration only
./benchmark-whisper.ps1 -ConfigName "intel-optimized" -AudioFiles "jfk-short,mm1-medium"
```

## Build Configurations

### Currently Supported

1. **Baseline Build**
   - Standard whisper.cpp build without optimizations
   - Reference point for performance comparisons

2. **TBB Optimized**
   - Intel TBB threading optimizations
   - Improved parallelization

3. **Intel MKL+IPP Optimized**
   - Intel Math Kernel Library (MKL) for FFT and BLAS
   - Intel Integrated Performance Primitives (IPP) for audio processing
   - Maximum CPU optimization currently available

4. **Current Build**
   - Uses existing binaries in `build/bin/Release`
   - Useful for testing local modifications

### Future Configurations (Templates Ready)

5. **CUDA Optimized**
   - NVIDIA GPU acceleration
   - cuBLAS integration
   - Template: Enable by setting `Enabled = $true` in config

6. **OpenCL Optimized**
   - Cross-platform GPU acceleration
   - Template ready for implementation

7. **Metal Optimized (macOS)**
   - Apple Metal GPU acceleration
   - Apple Silicon optimization

8. **WebAssembly Build**
   - Browser/edge deployment
   - SIMD optimizations

## Audio Test Suite

### Current Test Files

1. **jfk-short** (`samples/jfk.wav`)
   - 11 seconds, clear speech
   - Primary benchmark audio
   - High priority for all tests

2. **mm1-medium** (`samples/mm1.wav`)
   - ~30 seconds, medium complexity
   - Standard benchmark audio

3. **a13-long** (`samples/a13.wav`)
   - ~60 seconds, stress test
   - Memory and performance intensive

### Future Test Categories (Templates Ready)

- **Multilingual Tests**: Spanish, French, etc.
- **Noisy Audio Tests**: Background noise robustness
- **Different Formats**: MP3, FLAC, etc.
- **Variable Quality**: Different bitrates and sample rates

## Performance Metrics

### Measured Metrics

- **Transcription Time**: Total time to process audio
- **Model Load Time**: Time to load model into memory
- **Peak Memory Usage**: Maximum memory consumption
- **CPU Usage**: Average CPU utilization
- **Accuracy Score**: Transcription accuracy vs expected output
- **Throughput Rate**: Audio seconds processed per wall clock second

### Derived Metrics

- **Speedup Factor**: Relative performance vs baseline
- **Efficiency**: Performance per CPU core
- **Real-time Factor**: How much faster than real-time playback

## Report Formats

### Console Output
- Real-time progress tracking
- Summary tables with performance comparisons
- Relative speedup calculations

### JSON Reports
- Machine-readable format
- Complete data for further analysis
- Integration with other tools

### HTML Reports
- Interactive charts using Chart.js
- Visual performance comparisons
- Professional presentation format

### CSV Export (Future)
- Spreadsheet compatibility
- Statistical analysis support

## Adding New Configurations

### 1. Define Build Configuration
In `benchmark-config.ps1`, add to `BuildConfigurations`:

```powershell
"cuda-optimized" = @{
    Name = "CUDA GPU Optimized"
    Description = "GPU acceleration with CUDA"
    CMakePreset = "cuda-release"
    BinaryDir = "out/build/cuda-release"
    Features = @("CUDA GPU", "cuBLAS", "NVIDIA optimizations")
    ExpectedPerformance = "gpu-accelerated"
    Color = "#e74c3c"
    Enabled = $true  # Enable when ready
    RequiredTools = @("nvcc", "cuda-toolkit")
    MinimumGPUMemory = "4GB"
}
```

### 2. Create CMake Preset
Add to `CMakePresets.json`:

```json
{
    "name": "cuda-release",
    "displayName": "CUDA GPU Optimized",
    "description": "GPU acceleration with CUDA",
    "generator": "Ninja",
    "binaryDir": "${sourceDir}/out/build/${presetName}",
    "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "WHISPER_CUDA": "ON",
        "WHISPER_CUBLAS": "ON"
    }
}
```

### 3. Update CMakeLists.txt
Add CUDA support options and detection logic.

### 4. Test Configuration
```powershell
./run-benchmark.ps1 -Configurations "baseline,cuda-optimized" -Scenario quick
```

## System Requirements

### Minimum Requirements
- Windows 10/11 with PowerShell 5.1+
- CMake 3.15+
- Ninja build system
- 4GB RAM
- 2GB free disk space

### For Intel Optimizations
- Intel oneAPI toolkit
- MKL and IPP libraries
- Environment variables: `ONEAPI_ROOT`, `MKLROOT`, `IPPROOT`

### For CUDA (Future)
- NVIDIA GPU with Compute Capability 5.0+
- CUDA Toolkit 11.0+
- 4GB+ GPU memory

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check CMake and Ninja installation
   - Verify Intel oneAPI environment variables
   - Run with `-SkipBuild` to use existing binaries

2. **Missing Audio Files**
   - Ensure test audio files are in `samples/` directory
   - Download using existing download scripts
   - Check file permissions

3. **Model Not Found**
   - Download whisper models to `models/` directory
   - Supported: `ggml-base.en.bin`, `ggml-tiny.en.bin`, etc.

4. **Permission Errors**
   - Run PowerShell as Administrator if needed
   - Check antivirus software interference

### Debug Information

Enable verbose logging:
```powershell
$VerbosePreference = "Continue"
./benchmark-whisper.ps1 -Verbose
```

## Performance Analysis

### Expected Results

Based on initial testing with Intel optimizations:

1. **Intel MKL+IPP vs Baseline**: 15-30% faster transcription
2. **Memory Usage**: Similar or slightly higher due to optimized libraries
3. **CPU Utilization**: Better multi-core scaling with TBB
4. **Accuracy**: Should be identical across configurations

### Benchmarking Best Practices

1. **Consistent Environment**
   - Close unnecessary applications
   - Use consistent system load
   - Run multiple iterations

2. **Thermal Management**
   - Ensure adequate cooling
   - Monitor CPU throttling
   - Allow cooldown between tests

3. **Statistical Validity**
   - Use multiple iterations (3-5 minimum)
   - Report average and best times
   - Include confidence intervals

## Future Enhancements

### Planned Features

1. **GPU Benchmarking**
   - CUDA implementation and testing
   - OpenCL cross-platform support
   - Metal support for macOS

2. **Advanced Metrics**
   - Power consumption measurement
   - Temperature monitoring
   - Network bandwidth (for distributed processing)

3. **Automated Regression Testing**
   - CI/CD integration
   - Performance regression detection
   - Automated reporting

4. **Model Comparison**
   - Different model sizes (tiny, base, small, medium, large)
   - Quantized model performance
   - Model-specific optimizations

### Contributing

To add new configurations or improve the benchmark system:

1. Fork the repository
2. Add configuration templates in `benchmark-config.ps1`
3. Implement build system changes
4. Test with existing benchmark scripts
5. Submit pull request with performance results

## License

This benchmark system follows the same license as whisper.cpp project.

---

For questions or issues with the benchmark system, please create an issue in the project repository.
