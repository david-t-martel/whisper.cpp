@echo off
setlocal enabledelayedexpansion

REM Add at the start of the script
if not defined VCPKG_ROOT (
    echo Error: VCPKG_ROOT environment variable not set
    exit /b 1
)

REM Verify Visual Studio installation
if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    echo Error: Visual Studio 2022 not found
    exit /b 1
)

REM Setup environments with error checking
if not exist "C:/Program Files (x86)/Intel/openvino_2024.6.0/setupvars.bat" (
    echo Error: OpenVINO not found
    exit /b 1
)
call "C:/Program Files (x86)/Intel/openvino_2024.6.0/setupvars.bat"

REM Verify required environment variables
if not defined VCPKG_ROOT (
    echo Error: VCPKG_ROOT not set
    exit /b 1
)
set "PATH=%VCPKG_ROOT%;%PATH%"
set "PATH=C:\codedev\msys64\mingw64\bin;%PATH%"

REM Add Visual Studio environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM Verify CUDA installation
if not exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin\nvcc.exe" (
    echo Error: CUDA Toolkit not found
    exit /b 1
)

REM Set advanced CUDA optimization flags
set "CUDA_CACHE_PATH=%LOCALAPPDATA%\CUDA\Cache"
if not exist "%CUDA_CACHE_PATH%" mkdir "%CUDA_CACHE_PATH%"
set "CUDA_CACHE_MAXSIZE=8192"
set "CUDA_FORCE_PTX_JIT=1"
set "CUDA_AUTO_BOOST=1"
set "CUDA_MANAGED_FORCE_DEVICE_ALLOC=1"
set "CUDA_DEVICE_ORDER=PCI_BUS_ID"
set "CUDA_VISIBLE_DEVICES=0"

REM Get CPU core count early
for /f "tokens=*" %%i in ('wmic cpu get NumberOfLogicalProcessors ^| findstr [0-9]') do set "NUM_CORES=%%i"

REM Set OpenVINO performance hints
set "OPENVINO_ENABLE_PERFORMANCE_HINT=1"
set "OPENVINO_NUM_THREADS=%NUM_CORES%"
set "OPENVINO_CACHE_DIR=%LOCALAPPDATA%\OpenVINO\Cache"
if not exist "%OPENVINO_CACHE_DIR%" mkdir "%OPENVINO_CACHE_DIR%"

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

REM Clean build directory
if exist build\ rmdir /s /q build

REM Check for NVIDIA GPU and get info
nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo Error: No NVIDIA GPU detected
    exit /b 1
)

REM Get GPU info
echo NVIDIA GPU Information:
nvidia-smi --query-gpu=gpu_name,driver_version --format=csv,noheader

REM Set CUDA architecture for RTX 2000 Ada Generation
for /f "tokens=*" %%i in ('nvidia-smi --query-gpu=gpu_name --format=csv,noheader') do (
    set "GPU_NAME=%%i"

    REM Ada Lovelace Mobile GPUs (40-series)
    if "!GPU_NAME!"=="NVIDIA RTX 2000 Ada Generation Laptop GPU" set "CUDA_ARCH=89"
)

REM Verify CUDA architecture was set
if not defined CUDA_ARCH (
    echo Warning: Unknown GPU architecture, using default for Ada Lovelace
    set "CUDA_ARCH=89"
)

echo Using CUDA architecture: sm_%CUDA_ARCH%

REM Configure with Ninja and CUDA
cmake -G "Ninja" -B build ^
    -DCMAKE_POLICY_DEFAULT_CMP0048=NEW ^
    -DCMAKE_POLICY_DEFAULT_CMP0074=NEW ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
    -DCMAKE_C_COMPILER="cl.exe" ^
    -DCMAKE_CXX_COMPILER="cl.exe" ^
    -DCMAKE_CUDA_COMPILER="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin\nvcc.exe" ^
    -DCMAKE_CUDA_ARCHITECTURES="%CUDA_ARCH%" ^
    -DCMAKE_CUDA_FLAGS="-arch=sm_%CUDA_ARCH% -Wno-deprecated-gpu-targets -O3" ^
    -DCMAKE_CUDA_FLAGS_RELEASE="-use_fast_math" ^
    -DWHISPER_OPENVINO=ON ^
    -DGGML_CUDA=ON ^
    -DGGML_OPENMP=ON ^
    -DWHISPER_SDL2=ON ^
    -DWHISPER_CURL=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8" ^
    -DInferenceEngine_DIR="C:\Program Files (x86)\Intel\openvino_2024.6.0\runtime\cmake" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_FLAGS="/O2 /GL /Qpar /favor:INTEL64 /arch:AVX2 /fp:fast /DNDEBUG" ^
    -DCMAKE_C_FLAGS="/O2 /GL /Qpar /favor:INTEL64 /arch:AVX2 /fp:fast /DNDEBUG" ^
    -DCMAKE_SHARED_LINKER_FLAGS="/LTCG /INCREMENTAL:NO /OPT:REF /OPT:ICF" ^
    -DCMAKE_EXE_LINKER_FLAGS="/LTCG"

REM Add after cmake command
if errorlevel 1 (
    echo CMake configuration failed
    exit /b 1
)
echo Build system: Ninja
ninja --version

REM Add before build command
set "START_TIME=%TIME%"

REM Build main executable and all examples
cmake --build build --config Release --target all -- -j%NUM_CORES%
if errorlevel 1 (
    echo Build failed
    exit /b 1
)

REM Add after build completion
set "END_TIME=%TIME%"
call :calculate_duration "%START_TIME%" "%END_TIME%"
echo Build duration: %DURATION%

REM Create output directory
if not exist "build\bin\Release" mkdir "build\bin\Release"

REM Create output directories for examples
if not exist "build\bin\Release\examples" mkdir "build\bin\Release\examples"
if not exist "build\bin\Release\samples" mkdir "build\bin\Release\samples"

REM Copy dependencies with verification
echo Copying dependencies...
set "DEPENDENCIES_OK=1"

call :copy_dlls "%INTEL_OPENVINO_DIR%\runtime\bin\*.dll" "build\bin\Release" "OpenVINO"
call :copy_dlls "%INTEL_OPENVINO_DIR%\runtime\3rdparty\tbb\bin\*.dll" "build\bin\Release" "TBB"
call :copy_dlls "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Redist\MSVC\14.38.33130\x64\Microsoft.VC143.CRT\*.dll" "build\bin\Release" "MSVC"
call :copy_dlls "%INTEL_OPENVINO_DIR%\runtime\3rdparty\*.dll" "build\bin\Release" "Other"

REM Copy examples to output directory
echo Copying example executables...
xcopy /y "build\bin\Release\whisper-*.*" "build\bin\Release\examples\"
xcopy /y "build\examples\*.exe" "build\bin\Release\examples\"
xcopy /y "build\samples\*.exe" "build\bin\Release\samples\"

if %DEPENDENCIES_OK%==0 (
    echo Error: Some dependencies failed to copy
    exit /b 1
)

echo Build completed successfully
exit /b 0

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

REM Check CPU features
wmic cpu get Name, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors
if errorlevel 1 set "PERF_OK=0"

REM Check CUDA capability
nvcc --version > nul 2>&1
if errorlevel 1 set "PERF_OK=0"

REM Check available memory
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