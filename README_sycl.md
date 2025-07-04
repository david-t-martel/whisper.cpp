# Intel SYCL GPU Acceleration for whisper.cpp

This guide explains how to build and use whisper.cpp with Intel SYCL GPU acceleration on Windows and Linux.

## Table of Contents

- [Background](#background)
- [Prerequisites](#prerequisites)
- [Quick Start (Windows)](#quick-start-windows)
- [Quick Start (Linux)](#quick-start-linux)
- [Supported Hardware](#supported-hardware)
- [Advanced Building](#advanced-building)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Background

SYCL is a higher-level programming model to improve programming productivity on various hardware accelerators—such as CPUs, GPUs, and FPGAs. It is a single-source embedded domain-specific language based on pure C++17.

oneAPI is a specification that is open and standards-based, supporting multiple architecture types including but not limited to GPU, CPU, and FPGA. Intel uses SYCL as direct programming language to support CPU, GPUs and FPGAs.

This implementation provides Intel GPU acceleration for whisper.cpp, leveraging Intel's oneAPI toolkit and SYCL runtime.

## Prerequisites

### Intel oneAPI Toolkit

1. Download and install [Intel oneAPI Base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html)
2. Optionally install [Intel oneAPI HPC Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit-download.html) for additional optimizations
3. Default installation paths:
   - Windows: `C:\Program Files (x86)\Intel\oneAPI`
   - Linux: `/opt/intel/oneapi` or `~/intel/oneapi`

### Hardware Requirements

- **Intel GPU**: Intel Arc, Iris Xe, or newer integrated graphics
- **CPU**: Intel SYCL also supports CPU execution as fallback
- **Memory**: Sufficient GPU memory for model loading (varies by model size)

## Supported Hardware

|Intel GPU| Status | Verified Model|
|-|-|-|
|Intel Data Center Max Series| ✅ Support| Max 1550|
|Intel Data Center Flex Series| ✅ Support| Flex 170|
|Intel Arc Series| ✅ Support| Arc 770, Arc A380|
|Intel built-in Arc GPU| ✅ Support| built-in Arc GPU in Meteor Lake|
|Intel iGPU| ✅ Support| iGPU in i5-1250P, i7-1165G7|

## Quick Start (Windows)

### 1. Build with SYCL Support

```powershell
# Quick build (recommended)
.\quick_sycl_build.ps1

# Custom oneAPI path
.\quick_sycl_build.ps1 -OneAPIRoot "C:\Path\To\oneAPI"

# Clean build
.\quick_sycl_build.ps1 -Clean

# Debug build
.\quick_sycl_build.ps1 -BuildType Debug
```

### 2. Validate Build

```powershell
# Run validation tests
.\validate_sycl_build.ps1

# With custom model and audio
.\validate_sycl_build.ps1 -ModelPath "models\ggml-large.bin" -AudioFile "my_audio.wav"
```

### 3. List Available SYCL Devices

```powershell
.\build\examples\sycl\Release\ls-sycl-device.exe
```

### 4. Run Transcription

```powershell
# Basic transcription
.\build\bin\Release\main.exe -m models\ggml-base.en.bin -f samples\jfk.wav

# Force SYCL GPU usage
.\build\bin\Release\main.exe -m models\ggml-base.en.bin -f samples\jfk.wav --sycl-gpu
```

## Quick Start (Linux)


## Linux

### Setup Environment

1. Install Intel GPU driver.

a. Please install Intel GPU driver by official guide: [Install GPU Drivers](https://dgpu-docs.intel.com/driver/installation.html).

Note: for iGPU, please install the client GPU driver.

b. Add user to group: video, render.

```
sudo usermod -aG render username
sudo usermod -aG video username
```

Note: re-login to enable it.

c. Check

```
sudo apt install clinfo
sudo clinfo -l
```

Output (example):

```
Platform #0: Intel(R) OpenCL Graphics
 `-- Device #0: Intel(R) Arc(TM) A770 Graphics


Platform #0: Intel(R) OpenCL HD Graphics
 `-- Device #0: Intel(R) Iris(R) Xe Graphics [0x9a49]
```

2. Install Intel� oneAPI Base toolkit.


a. Please follow the procedure in [Get the Intel� oneAPI Base Toolkit ](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit.html).

Recommend to install to default folder: **/opt/intel/oneapi**.

Following guide use the default folder as example. If you use other folder, please modify the following guide info with your folder.

b. Check

```
source /opt/intel/oneapi/setvars.sh

sycl-ls
```

There should be one or more level-zero devices. Like **[ext_oneapi_level_zero:gpu:0]**.

Output (example):
```
[opencl:acc:0] Intel(R) FPGA Emulation Platform for OpenCL(TM), Intel(R) FPGA Emulation Device OpenCL 1.2  [2023.16.10.0.17_160000]
[opencl:cpu:1] Intel(R) OpenCL, 13th Gen Intel(R) Core(TM) i7-13700K OpenCL 3.0 (Build 0) [2023.16.10.0.17_160000]
[opencl:gpu:2] Intel(R) OpenCL Graphics, Intel(R) Arc(TM) A770 Graphics OpenCL 3.0 NEO  [23.30.26918.50]
[ext_oneapi_level_zero:gpu:0] Intel(R) Level-Zero, Intel(R) Arc(TM) A770 Graphics 1.3 [1.3.26918]

```

2. Build locally:

```
mkdir -p build
cd build
source /opt/intel/oneapi/setvars.sh

#for FP16
#cmake .. -DWHISPER_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DWHISPER_SYCL_F16=ON 

#for FP32
cmake .. -DWHISPER_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx

#build example/main only
#cmake --build . --config Release --target main

#build all binary
cmake --build . --config Release -v

```

or

```
./examples/sycl/build.sh
```

Note:

- By default, it will build for all binary files. It will take more time. To reduce the time, we recommend to build for **example/main** only.

### Run

1. Put model file to folder **models**

2. Enable oneAPI running environment

```
source /opt/intel/oneapi/setvars.sh
```

3. List device ID

Run without parameter:

```
./build/bin/ls-sycl-device

or

./build/bin/main
```

Check the ID in startup log, like:

```
found 4 SYCL devices:
  Device 0: Intel(R) Arc(TM) A770 Graphics,	compute capability 1.3,
    max compute_units 512,	max work group size 1024,	max sub group size 32,	global mem size 16225243136
  Device 1: Intel(R) FPGA Emulation Device,	compute capability 1.2,
    max compute_units 24,	max work group size 67108864,	max sub group size 64,	global mem size 67065057280
  Device 2: 13th Gen Intel(R) Core(TM) i7-13700K,	compute capability 3.0,
    max compute_units 24,	max work group size 8192,	max sub group size 64,	global mem size 67065057280
  Device 3: Intel(R) Arc(TM) A770 Graphics,	compute capability 3.0,
    max compute_units 512,	max work group size 1024,	max sub group size 32,	global mem size 16225243136

```

|Attribute|Note|
|-|-|
|compute capability 1.3|Level-zero running time, recommended |
|compute capability 3.0|OpenCL running time, slower than level-zero in most cases|

4. Set device ID and execute whisper.cpp

Set device ID = 0 by **GGML_SYCL_DEVICE=0**

```
GGML_SYCL_DEVICE=0 ./build/bin/main -m models/ggml-base.en.bin -f samples/jfk.wav
```
or run by script:

```
./examples/sycl/run_whisper.sh
```



5. Check the device ID in output

Like:
```
Using device **0** (Intel(R) Arc(TM) A770 Graphics) as main device
```


## Environment Variable

#### Build

|Name|Value|Function|
|-|-|-|
|WHISPER_SYCL|ON (mandatory)|Enable build with SYCL code path. <br>For FP32/FP16, WHISPER_SYCL=ON is mandatory.|
|WHISPER_SYCL_F16|ON (optional)|Enable FP16 build with SYCL code path.For FP32, do not set it.|
|CMAKE_C_COMPILER|icx|Use icx compiler for SYCL code path|
|CMAKE_CXX_COMPILER|icpx|use icpx for SYCL code path|

#### Running


|Name|Value|Function|
|-|-|-|
|GGML_SYCL_DEVICE|0 (default) or 1|Set the device id used. Check the device ids by default running output|
|GGML_SYCL_DEBUG|0 (default) or 1|Enable log function by macro: GGML_SYCL_DEBUG|

## Known Issue

- Error:  `error while loading shared libraries: libsycl.so.7: cannot open shared object file: No such file or directory`.

  Miss to enable oneAPI running environment.

  Install oneAPI base toolkit and enable it by: `source /opt/intel/oneapi/setvars.sh`.


- Hang during startup

  llama.cpp use mmap as default way to read model file and copy to GPU. In some system, memcpy will be abnormal and block.

  Solution: add **--no-mmap**.

## Todo

- Support to build in Windows.

- Support multiple cards.
### Setup Environment

1. Install Intel GPU driver:
   - Follow the official guide: [Install GPU Drivers](https://dgpu-docs.intel.com/driver/installation.html)
   - For iGPU, install the client GPU driver
   - Add user to groups: `video`, `render`

2. Setup oneAPI environment:
```bash
# Source the oneAPI environment
source /opt/intel/oneapi/setvars.sh

# Or for user installation
source ~/intel/oneapi/setvars.sh
```

### Build

```bash
# Configure with CMake
cmake -B build -DWHISPER_SYCL=ON -DCMAKE_CXX_COMPILER=icpx -DCMAKE_C_COMPILER=icx

# Build
cmake --build build --config Release --parallel

# List SYCL devices
./build/examples/sycl/ls-sycl-device

# Run transcription
./build/bin/main -m models/ggml-base.en.bin -f samples/jfk.wav
```

## Advanced Building

### Manual CMake Configuration (Windows)

```powershell
# Set up oneAPI environment (if not using scripts)
& "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"

# Configure
cmake -B build -DWHISPER_SYCL=ON -DCMAKE_CXX_COMPILER=icpx -DCMAKE_C_COMPILER=icx

# Build
cmake --build build --config Release --parallel
```

### CMake Presets

```powershell
# List available presets
cmake --list-presets

# Use SYCL preset
cmake --preset vs2022-sycl
cmake --build --preset vs2022-sycl-release
```

### Build Options

| Option | Description | Default |
|--------|-------------|---------|
| `WHISPER_SYCL` | Enable SYCL GPU acceleration | OFF |
| `WHISPER_SYCL_F16` | Use FP16 precision | ON |
| `CMAKE_CXX_COMPILER` | Set to `icpx` for Intel DPC++ | System default |
| `CMAKE_C_COMPILER` | Set to `icx` for Intel compiler | System default |

## Performance Optimization

### Model Recommendations

- **Base models**: Good balance of speed and accuracy
- **Large models**: Better accuracy, requires more GPU memory
- **Quantized models**: Faster inference, some accuracy trade-off

### SYCL-Specific Options

```bash
# Use all available SYCL devices
./main -m model.bin -f audio.wav --sycl-all

# Specify work group size
./main -m model.bin -f audio.wav --sycl-work-group-size 64

# Enable profiling
./main -m model.bin -f audio.wav --sycl-profile
```

## Troubleshooting

### Common Issues

1. **"SYCL device not found"**
   - Verify Intel GPU drivers are installed
   - Check device availability with `ls-sycl-device`
   - Ensure oneAPI environment is properly set up

2. **Build fails with compiler errors**
   - Verify Intel DPC++ compiler is in PATH
   - Check oneAPI toolkit installation
   - Try clean build

3. **Runtime errors**
   - Ensure sufficient GPU memory
   - Try CPU fallback with `--sycl-cpu`
   - Check model file integrity

### Debug Build

```powershell
# Windows
.\quick_sycl_build.ps1 -BuildType Debug

# Linux
cmake -B build -DWHISPER_SYCL=ON -DCMAKE_BUILD_TYPE=Debug
```

### Environment Variables

```bash
# Enable SYCL debugging
export SYCL_PI_TRACE=1

# Set device selection
export SYCL_DEVICE_FILTER=gpu

# Force specific platform
export SYCL_PLATFORM_FILTER=level_zero
```

## Benchmarking

### Windows

```powershell
# Comprehensive benchmark
.\benchmark_whisper.ps1 -Config "Intel SYCL"

# Custom benchmark
.\test_sycl_build.ps1 -RunBenchmark
```

### Compare Performance

```bash
# CPU vs SYCL comparison
./main -m model.bin -f audio.wav -t 1          # CPU
./main -m model.bin -f audio.wav --sycl-gpu    # SYCL GPU
```

## oneAPI Libraries Used

- **Intel DPC++**: SYCL compiler and runtime
- **Intel MKL**: Math Kernel Library for optimized linear algebra
- **Intel TBB**: Threading Building Blocks for parallelization
- **Intel IPP**: Integrated Performance Primitives for signal processing
- **Level Zero**: GPU driver interface (automatic)

## Known Issues

- Windows support is actively being improved
- Some Intel GPU models may have limited FP16 support
- Memory allocation can be optimized further for large models

## Contributing

When contributing SYCL-related changes:
1. Test on both Intel GPU and CPU backends
2. Ensure compatibility with different Intel GPU generations
3. Update documentation and build scripts as needed
4. Follow SYCL best practices for performance

## Support and Resources

- [Intel oneAPI Documentation](https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2024-0/intel-oneapi-programming-guide.html)
- [SYCL Specification](https://www.khronos.org/sycl/)
- [Intel GPU Drivers](https://www.intel.com/content/www/us/en/support/articles/000005629/graphics.html)
- [whisper.cpp SYCL Issues](https://github.com/ggerganov/whisper.cpp/issues)## vcpkg Integration Status

✅ **vcpkg dependencies are fully integrated and working!**

The project now supports clean vcpkg-only builds with the `ninja-vcpkg-clean` preset:

```bash
# Configure and build with vcpkg dependencies only
cmake --preset ninja-vcpkg-clean
cmake --build --preset ninja-vcpkg-clean-build -j 2
```

**Enabled vcpkg libraries:**
- ✅ libsndfile (audio I/O)
- ✅ SDL2 (audio streaming)
- ✅ curl (HTTP client)
- ✅ cpprestsdk (REST API)
- ✅ boost-stacktrace (debugging)
- ✅ taskflow (task parallelism)

**Note:** Intel oneAPI and vcpkg can be used independently. Use `ninja-vcpkg-clean` for vcpkg-only builds to avoid conflicts.

For detailed test results, see [VCPKG_INTEGRATION_TEST.md](./VCPKG_INTEGRATION_TEST.md).