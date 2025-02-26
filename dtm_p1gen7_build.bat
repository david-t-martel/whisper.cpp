REM filepath: /C:/codedev/whisper.cpp/dtm_p1gen7_build.bat
@echo off
setlocal enabledelayedexpansion

REM Set environment variables
set "VCPKG_ROOT=C:\codedev\vcpkg"
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8"
set "CUDA_ARCH=89"  REM Ada Lovelace architecture (RTX 40xx)
set "OPENVINO_PATH=C:\Program Files (x86)\Intel\openvino_2024.6.0"
set "NUM_CORES=%NUMBER_OF_PROCESSORS%"

REM -----------------------------------------------------------
REM 1. ENVIRONMENT VERIFICATION
REM -----------------------------------------------------------
if not defined VCPKG_ROOT (
    echo Error: VCPKG_ROOT environment variable not set
    exit /b 1
)

REM Verify Visual Studio installation
if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    echo Error: Visual Studio 2022 not found
    exit /b 1
)

REM Verify OpenVINO installation
if not exist "C:/Program Files (x86)/Intel/openvino_2024.6.0/setupvars.bat" (
    echo Error: OpenVINO not found
    exit /b 1
)

REM Verify CUDA installation
if not exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin\nvcc.exe" (
    echo Error: CUDA Toolkit not found
    exit /b 1
)

REM Check for NVIDIA GPU
nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo Error: No NVIDIA GPU detected
    exit /b 1
)

REM -----------------------------------------------------------
REM 2. ENVIRONMENT SETUP
REM -----------------------------------------------------------
REM Setup OpenVINO environment
call "C:/Program Files (x86)/Intel/openvino_2024.6.0/setupvars.bat"

REM Setup Visual Studio environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM Path setup
set "PATH=%VCPKG_ROOT%;%PATH%"
set "PATH=C:\codedev\msys64\mingw64\bin;%PATH%"

REM Get CPU core count
for /f "tokens=*" %%i in ('wmic cpu get NumberOfLogicalProcessors ^| findstr [0-9]') do set "NUM_CORES=%%i"

REM Get GPU info
echo NVIDIA GPU Information:
nvidia-smi --query-gpu=gpu_name,driver_version --format=csv,noheader

REM -----------------------------------------------------------
REM 3. CUDA CONFIGURATION
REM -----------------------------------------------------------
REM Set CUDA environment variables (consolidated)
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8"
set "CUDA_BIN_PATH=%CUDA_PATH%\bin"
set "CUDA_LIB_PATH=%CUDA_PATH%\lib\x64"
set "CUDA_INCLUDE_PATH=%CUDA_PATH%\include"
set "PATH=%CUDA_BIN_PATH%;%PATH%"

REM Set CUDA architecture
for /f "tokens=*" %%i in ('nvidia-smi --query-gpu=gpu_name --format=csv,noheader') do (
    set "GPU_NAME=%%i"
    if "!GPU_NAME!"=="NVIDIA RTX 2000 Ada Generation Laptop GPU" set "CUDA_ARCH=89"
)

REM Verify CUDA architecture was set
if not defined CUDA_ARCH (
    echo Warning: Unknown GPU architecture, using default for Ada Lovelace
    set "CUDA_ARCH=89"
)
set "CUDA_ARCH_PTX=%CUDA_ARCH%"
set "CUDAARCHS=%CUDA_ARCH%"

echo Using CUDA architecture: sm_%CUDA_ARCH%

REM Set unified CUDA compilation flags
set "CUDA_HOST_COMPILER=cl.exe"
set "CUDA_PROPAGATE_HOST_FLAGS=off"
set "CUDA_NVCC_FLAGS=--use_fast_math;-O3;--threads=%NUM_CORES%;--disable-warnings;--diag-suppress=221"
set "CUDAFE_FLAGS=--display_error_number"

REM CUDA optimization settings
set "CUDA_CACHE_PATH=%LOCALAPPDATA%\CUDA\Cache"
if not exist "%CUDA_CACHE_PATH%" mkdir "%CUDA_CACHE_PATH%"
set "CUDA_CACHE_MAXSIZE=4294967296"
set "CUDA_FORCE_PTX_JIT=1"
set "CUDA_AUTO_BOOST=1"
set "CUDA_MANAGED_FORCE_DEVICE_ALLOC=1"
set "CUDA_DEVICE_ORDER=PCI_BUS_ID"
set "CUDA_VISIBLE_DEVICES=0"
set "CUDA_ERROR_REPORTING=1"

REM Set GGML CUDA optimizations
set "GGML_CUDA_FORCE_DMMV=1"
set "GGML_CUDA_FORCE_MMQ=1"
set "GGML_CUDA_DMMV_X=32"
set "GGML_CUDA_MMV_Y=1"
set "CUDA_FORCE_BLAS_KERNELS=1"
set "CUDA_ALLOC_ALWAYS_MALLOC=1"

REM Check CUDA compiler version
echo Checking CUDA compiler version...
"%CUDA_PATH%\bin\nvcc" --version
if errorlevel 1 (
    echo Error: CUDA compiler version check failed
    exit /b 1
)

REM -----------------------------------------------------------
REM 4. SYSTEM OPTIMIZATION
REM -----------------------------------------------------------
REM Set system performance settings
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
set "ProcessorPerformance=100"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\bc5038f7-23e0-4960-96da-33abaf5935ec" /v "ACSettingIndex" /t REG_DWORD /d %ProcessorPerformance% /f

REM Optimize virtual memory
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=32768,MaximumSize=32768

REM Set processor scheduling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f

REM Optimize memory performance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f

REM -----------------------------------------------------------
REM 5. BUILD PREPARATION
REM -----------------------------------------------------------
REM Set OpenVINO performance hints
set "OPENVINO_ENABLE_PERFORMANCE_HINT=1"
set "OPENVINO_NUM_THREADS=%NUM_CORES%"
set "OPENVINO_CACHE_DIR=%LOCALAPPDATA%\OpenVINO\Cache"
if not exist "%OPENVINO_CACHE_DIR%" mkdir "%OPENVINO_CACHE_DIR%"

REM Add MSVC intrinsics path
set "INCLUDE=%INCLUDE%;C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\include"
set "INCLUDE=%INCLUDE%;%VCToolsInstallDir%\include"
set "__VSCMD_PREINIT_INCLUDE=%INCLUDE%"

REM Set C/C++ build flags
set "CL=/MP /Zm500 /Y-"
set "CXXFLAGS=/Zm500"
set "CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL"

REM Set Link Time Optimization flags
set "CMAKE_CXX_FLAGS_RELEASE=/MD /O2 /Ob2 /GL /DNDEBUG"
set "CMAKE_C_FLAGS_RELEASE=/MD /O2 /Ob2 /GL /DNDEBUG"
set "CMAKE_EXE_LINKER_FLAGS_RELEASE=/LTCG /INCREMENTAL:NO /OPT:REF /OPT:ICF"
set "CMAKE_SHARED_LINKER_FLAGS_RELEASE=/LTCG /INCREMENTAL:NO /OPT:REF /OPT:ICF"

REM Link optimization flags should be set before CMAKE command
set "CMAKE_CXX_FLAGS_RELEASE=%CMAKE_CXX_FLAGS_RELEASE% /GL"

REM Set build environment
set "VERBOSE=1"
set "CMAKE_VERBOSE_MAKEFILE=ON"
set "CMAKE_MAKE_PROGRAM=ninja"
set "CMAKE_BUILD_PARALLEL_LEVEL=%NUM_CORES%"

REM Set ccache if available
where ccache >nul 2>&1
if not errorlevel 1 (
    set "CMAKE_CUDA_COMPILER_LAUNCHER=ccache"
    set "CMAKE_CXX_COMPILER_LAUNCHER=ccache"
    set "CMAKE_C_COMPILER_LAUNCHER=ccache"
)

REM Clean build directory (done once)
rmdir /s /q build
mkdir build

REM Install required vcpkg packages
echo Installing vcpkg dependencies...
"%VCPKG_ROOT%\vcpkg" install ^
   cuda-api-wrappers:x64-windows ^
   mimalloc:x64-windows ^
   tbb:x64-windows ^
   libsndfile:x64-windows ^
   cpprestsdk:x64-windows ^
   --triplet=x64-windows

REM Add vcpkg packages to path
set "PATH=%VCPKG_ROOT%\installed\x64-windows\bin;%PATH%"

REM Install vcpkg packages if not already installed
echo Installing required vcpkg packages...
"%VCPKG_ROOT%\vcpkg" install ^
   mimalloc:x64-windows ^
   tbb:x64-windows ^
   libsndfile:x64-windows ^
   boost-stacktrace:x64-windows ^
   cuda-api-wrappers:x64-windows ^
   taskflow:x64-windows ^
   sdl2:x64-windows ^
   curl:x64-windows ^
   cpprestsdk:x64-windows ^
   --triplet=x64-windows

REM -----------------------------------------------------------
REM 6. CMAKE CONFIGURATION
REM -----------------------------------------------------------
REM Start timing
set "START_TIME=%TIME%"

REM Configure with Ninja
cmake -G "Ninja" -B build ^
    -DCMAKE_POLICY_DEFAULT_CMP0048=NEW ^
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW ^
    -DCMAKE_POLICY_DEFAULT_CMP0104=NEW ^
    -DCMAKE_MINIMUM_REQUIRED_VERSION="3.10" ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
    -DVCPKG_TARGET_TRIPLET=x64-windows ^
    -DVCPKG_INSTALLED_DIR="%VCPKG_ROOT%\installed" ^
    -DCMAKE_C_COMPILER=cl.exe ^
    -DCMAKE_CXX_COMPILER=cl.exe ^
    -DCMAKE_CUDA_COMPILER="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8/bin/nvcc.exe" ^
    -DCMAKE_CUDA_HOST_COMPILER=cl.exe ^
    -DCMAKE_CUDA_ARCHITECTURES=%CUDA_ARCH% ^
    -DCMAKE_CUDA_FLAGS="-arch=sm_%CUDA_ARCH% -Xcudafe=\"--display_error_number --diag_suppress=221\"" ^
    -DCMAKE_CUDA_FLAGS_RELEASE="-O3" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
    -DCMAKE_C_FLAGS_RELEASE="%CMAKE_C_FLAGS_RELEASE% /Zi-" ^
    -DCMAKE_CXX_FLAGS_RELEASE="%CMAKE_CXX_FLAGS_RELEASE% /Zi-" ^
    -DCMAKE_CXX_FLAGS="/MP" ^
    -DCMAKE_SHARED_LINKER_FLAGS="%CMAKE_SHARED_LINKER_FLAGS_RELEASE%" ^
    -DCMAKE_EXE_LINKER_FLAGS="%CMAKE_EXE_LINKER_FLAGS_RELEASE%" ^
    -DCMAKE_PCH_INSTANTIATE_TEMPLATES=ON ^
    -DCMAKE_UNITY_BUILD=ON ^
    -DCMAKE_UNITY_BUILD_BATCH_SIZE=10 ^
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON ^
    -DWHISPER_OPENVINO=ON ^
    -DGGML_CUDA=ON ^
    -DGGML_OPENMP=ON ^
    -DGGML_AVX2=ON ^
    -DGGML_AVX=ON ^
    -DGGML_F16C=ON ^
    -DGGML_FMA=ON ^
    -DWHISPER_SDL2=ON ^
    -DWHISPER_CURL=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCUDA_TOOLKIT_ROOT_DIR="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8" ^
    -DInferenceEngine_DIR="C:/Program Files (x86)/Intel/openvino_2024.6.0/runtime/cmake" ^
    -DWHISPER_MIMALLOC=ON ^
    -DWHISPER_LIBSNDFILE=ON ^
    -DWHISPER_SERVER_CPPRESTSDK=ON ^
    -DWHISPER_BUILD_TESTS=ON ^
    -DWHISPER_USE_CMOCKA=ON ^
    -DWHISPER_TBB=ON ^
    -DWHISPER_BOOST_STACKTRACE=ON ^
    -DWHISPER_CUDA_API_WRAPPERS=ON ^
    -DWHISPER_BUILD_EXAMPLES=ON

REM Check for CMake errors
if errorlevel 1 (
    echo CMake configuration failed
    exit /b 1
)

REM Display Ninja version
echo Build system: Ninja
ninja --version

REM -----------------------------------------------------------
REM 7. BUILD EXECUTION
REM -----------------------------------------------------------

REM Add before build command
set "CUDA_DEVICE_HEAP_SIZE=2048"
set "CUDA_DEVICE_MAX_CONNECTIONS=32"

REM Build with Ninja
cmake --build build --parallel %NUM_CORES%

if errorlevel 1 (
    echo Build failed
    exit /b 1
)

REM Calculate build time
set "END_TIME=%TIME%"
call :calculate_duration "%START_TIME%" "%END_TIME%"
echo Build duration: %DURATION%

REM -----------------------------------------------------------
REM 8. ARTIFACTS ORGANIZATION
REM -----------------------------------------------------------
REM Create output directories
if not exist "build\bin\Release" mkdir "build\bin\Release"
if not exist "build\bin\Release\examples" mkdir "build\bin\Release\examples"
if not exist "build\bin\Release\samples" mkdir "build\bin\Release\samples"

REM Copy dependencies
echo Copying dependencies...
set "DEPENDENCIES_OK=1"

call :copy_dlls "%INTEL_OPENVINO_DIR%\runtime\bin\*.dll" "build\bin\Release" "OpenVINO"
call :copy_dlls "%INTEL_OPENVINO_DIR%\runtime\3rdparty\tbb\bin\*.dll" "build\bin\Release" "TBB"
call :copy_dlls "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Redist\MSVC\14.38.33130\x64\Microsoft.VC143.CRT\*.dll" "build\bin\Release" "MSVC"
call :copy_dlls "%INTEL_OPENVINO_DIR%\runtime\3rdparty\*.dll" "build\bin\Release" "Other"

REM Copy executables
echo Copying example executables...
xcopy /y "build\bin\*.exe" "build\bin\Release\"
xcopy /y "build\bin\Release\whisper-*.*" "build\bin\Release\examples\"
xcopy /y "build\examples\*.exe" "build\bin\Release\examples\"
xcopy /y "build\samples\*.exe" "build\bin\Release\samples\"

if %DEPENDENCIES_OK%==0 (
    echo Error: Some dependencies failed to copy
    exit /b 1
)

echo Build completed successfully
exit /b 0

REM -----------------------------------------------------------
REM 9. HELPER FUNCTIONS
REM -----------------------------------------------------------
:copy_dlls
xcopy /y %~1 %~2
if errorlevel 1 (
    echo Error copying %~3 dependencies
    set "DEPENDENCIES_OK=0"
)
goto :eof

:verify_performance
echo Verifying system capabilities...
set "PERF_OK=1"
wmic cpu get Name, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors
if errorlevel 1 set "PERF_OK=0"
nvcc --version > nul 2>&1
if errorlevel 1 set "PERF_OK=0"
wmic ComputerSystem get TotalPhysicalMemory
if errorlevel 1 set "PERF_OK=0"
if %PERF_OK%==0 (
    echo Warning: Performance verification failed
    echo Some optimizations may not be available
)
goto :eof

:calculate_duration
set "START_H=%~1:~0,2%"
set "START_M=%~1:~3,2%"
set "START_S=%~1:~6,2%"
set "END_H=%~2:~0,2%"
set "END_M=%~2:~3,2%"
set "END_S=%~2:~6,2%"
set /a "DURATION_S=(END_H-START_H)*3600 + (END_M-START_M)*60 + (END_S-START_S)"
set "DURATION=%DURATION_S% seconds"
goto :eof

REM Run a simple test
echo Running simple test...
build\bin\main -h

echo.
echo All done!

exit /b 0