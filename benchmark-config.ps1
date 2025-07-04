# Whisper.cpp Benchmark Configuration
# This file defines build configurations and test scenarios for benchmarking
# Add new configurations here to extend the benchmark suite

$BenchmarkConfig = @{
    # Build Configurations - easily extensible
    BuildConfigurations = @{
        "baseline" = @{
            Name = "Baseline Build"
            Description = "Standard whisper.cpp build without optimizations"
            CMakePreset = "default"
            BinaryDir = "out/build/default"
            Features = @("Standard CPU", "No optimizations")
            ExpectedPerformance = "baseline"
            Color = "#95a5a6"
            Enabled = $true
        }

        "tbb-optimized" = @{
            Name = "TBB Optimized"
            Description = "Build with Intel TBB threading optimizations"
            CMakePreset = "ninja-release-tbb"
            BinaryDir = "out/build/ninja-release-tbb"
            Features = @("Intel TBB", "Threading optimizations", "Mimalloc")
            ExpectedPerformance = "faster"
            Color = "#3498db"
            Enabled = $true
        }

        "intel-optimized" = @{
            Name = "Intel MKL+IPP Optimized"
            Description = "Full Intel optimizations with MKL and IPP"
            CMakePreset = "ninja-intel-optimized"
            BinaryDir = "out/build/ninja-intel-optimized"
            Features = @("Intel MKL FFT", "Intel MKL BLAS", "Intel MKL VML", "Intel IPP", "TBB", "Mimalloc")
            ExpectedPerformance = "fastest"
            Color = "#2ecc71"
            Enabled = $true
        }

        "current-build" = @{
            Name = "Current Build"
            Description = "Currently built binaries in build/bin/Release"
            CMakePreset = $null
            BinaryDir = "build/bin/Release"
            Features = @("Current active build")
            ExpectedPerformance = "varies"
            Color = "#f39c12"
            Enabled = $true
        }

        # Template for CUDA - ready to be enabled when implemented
        "cuda-optimized" = @{
            Name = "CUDA GPU Optimized"
            Description = "GPU acceleration with CUDA"
            CMakePreset = "cuda-release"
            BinaryDir = "out/build/cuda-release"
            Features = @("CUDA GPU", "cuBLAS", "NVIDIA optimizations", "GPU memory management")
            ExpectedPerformance = "gpu-accelerated"
            Color = "#e74c3c"
            Enabled = $false  # Enable when CUDA preset is created
            RequiredTools = @("nvcc", "cuda-toolkit")
            MinimumGPUMemory = "4GB"
        }

        # Template for OpenCL - ready for future implementation
        "opencl-optimized" = @{
            Name = "OpenCL GPU Optimized"
            Description = "Cross-platform GPU acceleration with OpenCL"
            CMakePreset = "opencl-release"
            BinaryDir = "out/build/opencl-release"
            Features = @("OpenCL GPU", "Cross-platform GPU", "Memory optimization")
            ExpectedPerformance = "gpu-accelerated"
            Color = "#9b59b6"
            Enabled = $false
            RequiredTools = @("opencl-headers", "opencl-libs")
        }

        # Template for Metal (macOS) - future implementation
        "metal-optimized" = @{
            Name = "Metal GPU Optimized (macOS)"
            Description = "Apple Metal GPU acceleration for macOS"
            CMakePreset = "metal-release"
            BinaryDir = "out/build/metal-release"
            Features = @("Metal GPU", "Apple Silicon optimization", "Unified memory")
            ExpectedPerformance = "gpu-accelerated"
            Color = "#1abc9c"
            Enabled = $false
            Platform = "macOS"
            RequiredTools = @("metal-tools")
        }

        # Template for WebAssembly - future implementation
        "wasm-optimized" = @{
            Name = "WebAssembly Build"
            Description = "WebAssembly build for browser/edge deployment"
            CMakePreset = "wasm-release"
            BinaryDir = "out/build/wasm-release"
            Features = @("WebAssembly", "Browser compatible", "SIMD optimizations")
            ExpectedPerformance = "portable"
            Color = "#34495e"
            Enabled = $false
            RequiredTools = @("emscripten")
        }
    }

    # Audio Test Configurations
    AudioTestSuite = @{
        "jfk-short" = @{
            File = "samples/jfk.wav"
            Description = "JFK speech (11 seconds, clear speech)"
            Duration = 11
            Complexity = "Low"
            Language = "en"
            ExpectedOutput = "And so my fellow Americans ask not what your country can do for you ask what you can do for your country"
            Priority = "High"  # Always include in quick tests
        }

        "jfk-mp3" = @{
            File = "samples/jfk.mp3"
            Description = "JFK speech MP3 format (compression test)"
            Duration = 11
            Complexity = "Low"
            Language = "en"
            ExpectedOutput = "And so my fellow Americans ask not what your country can do for you ask what you can do for your country"
            Priority = "Medium"
        }

        "mm1-medium" = @{
            File = "samples/mm1.wav"
            Description = "Medium length audio (~30 seconds)"
            Duration = 30
            Complexity = "Medium"
            Language = "en"
            ExpectedOutput = ""  # Will be determined from first run
            Priority = "High"
        }

        "a13-long" = @{
            File = "samples/a13.wav"
            Description = "Longer audio sample (stress test)"
            Duration = 60
            Complexity = "High"
            Language = "en"
            ExpectedOutput = ""
            Priority = "Medium"
        }

        # Template for multilingual tests - ready for future
        "multilingual-spanish" = @{
            File = "samples/spanish-sample.wav"
            Description = "Spanish language test"
            Duration = 15
            Complexity = "Medium"
            Language = "es"
            ExpectedOutput = ""
            Priority = "Low"
            Enabled = $false  # Enable when sample is available
        }

        "multilingual-french" = @{
            File = "samples/french-sample.wav"
            Description = "French language test"
            Duration = 15
            Complexity = "Medium"
            Language = "fr"
            ExpectedOutput = ""
            Priority = "Low"
            Enabled = $false
        }

        # Template for noisy audio tests
        "noisy-audio" = @{
            File = "samples/noisy-sample.wav"
            Description = "Audio with background noise (robustness test)"
            Duration = 20
            Complexity = "High"
            Language = "en"
            ExpectedOutput = ""
            Priority = "Low"
            Enabled = $false
        }
    }

    # Performance Test Scenarios
    TestScenarios = @{
        "quick" = @{
            Name = "Quick Test"
            Description = "Fast benchmark with essential tests only"
            Configurations = @("current-build", "intel-optimized")
            AudioFiles = @("jfk-short")
            Iterations = 2
        }

        "standard" = @{
            Name = "Standard Benchmark"
            Description = "Comprehensive test of all enabled configurations"
            Configurations = @()  # Empty = all enabled
            AudioFiles = @("jfk-short", "mm1-medium")
            Iterations = 3
        }

        "comprehensive" = @{
            Name = "Comprehensive Test"
            Description = "Full benchmark suite with all tests and multiple iterations"
            Configurations = @()  # Empty = all enabled
            AudioFiles = @()      # Empty = all enabled
            Iterations = 5
        }

        "stress-test" = @{
            Name = "Stress Test"
            Description = "Long-running tests with large audio files"
            Configurations = @("current-build", "intel-optimized")
            AudioFiles = @("a13-long")
            Iterations = 3
        }
    }

    # Model Configurations for Testing
    ModelConfigurations = @{
        "tiny.en" = @{
            File = "models/ggml-tiny.en.bin"
            Description = "Tiny English model (fast, lower accuracy)"
            Size = "39 MB"
            Languages = @("en")
            Priority = "Medium"
        }

        "base.en" = @{
            File = "models/ggml-base.en.bin"
            Description = "Base English model (good balance)"
            Size = "142 MB"
            Languages = @("en")
            Priority = "High"
        }

        "small.en" = @{
            File = "models/ggml-small.en.bin"
            Description = "Small English model (better accuracy)"
            Size = "244 MB"
            Languages = @("en")
            Priority = "Medium"
        }

        "base" = @{
            File = "models/ggml-base.bin"
            Description = "Base multilingual model"
            Size = "142 MB"
            Languages = @("multilingual")
            Priority = "Low"
        }
    }

    # Performance Metrics to Collect
    PerformanceMetrics = @{
        "TranscriptionTime" = @{
            Name = "Transcription Time"
            Unit = "milliseconds"
            Description = "Total time to transcribe audio"
            Chart = "bar"
            Priority = "High"
        }

        "ModelLoadTime" = @{
            Name = "Model Load Time"
            Unit = "milliseconds"
            Description = "Time to load the model into memory"
            Chart = "bar"
            Priority = "Medium"
        }

        "PeakMemoryUsage" = @{
            Name = "Peak Memory Usage"
            Unit = "MB"
            Description = "Maximum memory used during transcription"
            Chart = "bar"
            Priority = "High"
        }

        "AverageCPUUsage" = @{
            Name = "Average CPU Usage"
            Unit = "percentage"
            Description = "Average CPU utilization during transcription"
            Chart = "line"
            Priority = "Medium"
        }

        "AccuracyScore" = @{
            Name = "Transcription Accuracy"
            Unit = "percentage"
            Description = "Accuracy of transcribed text vs expected output"
            Chart = "bar"
            Priority = "High"
        }

        "ThroughputRate" = @{
            Name = "Throughput Rate"
            Unit = "audio_seconds/wall_seconds"
            Description = "How many seconds of audio processed per second of wall time"
            Chart = "bar"
            Priority = "High"
        }
    }

    # Report Generation Settings
    ReportSettings = @{
        "OutputFormats" = @("console", "json", "html", "csv")
        "DefaultFormat" = "all"
        "ChartLibrary" = "Chart.js"
        "Theme" = "modern"
        "IncludeSystemInfo" = $true
        "IncludeCharts" = $true
        "IncludeRawData" = $true
    }

    # System Requirements for Different Configurations
    SystemRequirements = @{
        "baseline" = @{
            MinRAM = "2GB"
            MinCores = 2
            RequiredTools = @("cmake", "ninja")
        }

        "intel-optimized" = @{
            MinRAM = "4GB"
            MinCores = 4
            RequiredTools = @("cmake", "ninja")
            RequiredLibraries = @("Intel oneAPI", "MKL", "IPP", "TBB")
            Environment = @("ONEAPI_ROOT", "MKLROOT", "IPPROOT")
        }

        "cuda-optimized" = @{
            MinRAM = "6GB"
            MinCores = 4
            MinGPUMemory = "4GB"
            RequiredTools = @("cmake", "ninja", "nvcc")
            RequiredLibraries = @("CUDA Toolkit", "cuBLAS", "cuDNN")
            GPUArchitectures = @("sm_50", "sm_60", "sm_70", "sm_80", "sm_86")
        }
    }
}

# Export the configuration for use by benchmark script
Export-ModuleMember -Variable BenchmarkConfig
