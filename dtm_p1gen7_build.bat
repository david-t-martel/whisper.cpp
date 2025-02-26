REM filepath: /C:/codedev/whisper.cpp/dtm_p1gen7_build.bat
@echo off
setlocal enabledelayedexpansion

REM Set environment variables
set "VCPKG_ROOT=C:/codedev/vcpkg"
set "CUDA_PATH=C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8"
set "CUDA_ARCH=89"  REM Ada Lovelace architecture (RTX 40xx)
set "OPENVINO_PATH=C:/Program Files (x86)/Intel/openvino_2024.6.0"
set "NUM_CORES=%NUMBER_OF_PROCESSORS%"

REM -----------------------------------------------------------
REM 1. ENVIRONMENT VERIFICATION
REM -----------------------------------------------------------
if not defined VCPKG_ROOT (
    echo Error: VCPKG_ROOT environment variable not set
    exit /b 1
)

REM Verify Visual Studio installation
if not exist "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat" (
    echo Error: Visual Studio 2022 not found
    exit /b 1
)

REM Verify OpenVINO installation
if not exist "%OPENVINO_PATH%/setupvars.bat" (
    echo Error: OpenVINO not found
    exit /b 1
)

REM Verify CUDA installation
if not exist "%CUDA_PATH%/bin/nvcc.exe" (
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
REM Setup Visual Studio environment FIRST to ensure MSVC is used for CUDA
call "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat"

REM Setup OpenVINO environment
call "%OPENVINO_PATH%/setupvars.bat"

REM Remove any MinGW or other compilers from PATH to avoid conflicts
set "PATH=%VCPKG_ROOT%;%PATH%"

REM Get CPU core count
for /f "tokens=*" %%i in ('wmic cpu get NumberOfLogicalProcessors ^| findstr [0-9]') do set "NUM_CORES=%%i"

REM Get GPU info
echo NVIDIA GPU Information:
nvidia-smi --query-gpu=gpu_name,driver_version --format=csv,noheader

REM -----------------------------------------------------------
REM 3. VCPKG CONFIGURATION
REM -----------------------------------------------------------

REM Ensure vcpkg is properly integrated
echo Integrating vcpkg...
"%VCPKG_ROOT%/vcpkg" integrate install

REM Install dependencies using manifest mode (no package list)
echo Installing vcpkg dependencies from manifest...
"%VCPKG_ROOT%/vcpkg" install --triplet=x64-windows

REM Add vcpkg packages to path
set "PATH=%VCPKG_ROOT%/installed/x64-windows/bin;%PATH%"

REM -----------------------------------------------------------
REM 4. BUILD PREPARATION
REM -----------------------------------------------------------
REM Clean build directory
if exist build rmdir /s /q build
mkdir build

REM -----------------------------------------------------------
REM 5. CMAKE CONFIGURATION
REM -----------------------------------------------------------
REM Start timing
set "START_TIME=%TIME%"

REM Check for Ninja
where ninja >nul 2>&1
if not errorlevel 1 (
    set "CMAKE_GENERATOR=Ninja"
    set "CMAKE_GENERATOR_PLATFORM_ARG="
) else (
    REM Check for installed Ninja in standard locations
    if exist "C:/Program Files/Ninja/ninja.exe" (
        set "PATH=C:/Program Files/Ninja;%PATH%"
        set "CMAKE_GENERATOR=Ninja"
        set "CMAKE_GENERATOR_PLATFORM_ARG="
    ) else if exist "%VCPKG_ROOT%/downloads/tools/ninja/ninja-1.11.1-windows/ninja.exe" (
        set "PATH=%VCPKG_ROOT%/downloads/tools/ninja/ninja-1.11.1-windows;%PATH%"
        set "CMAKE_GENERATOR=Ninja"
        set "CMAKE_GENERATOR_PLATFORM_ARG="
    ) else (
        set "CMAKE_GENERATOR=Visual Studio 17 2022"
        set "CMAKE_GENERATOR_PLATFORM_ARG=-A x64"
    )
)

echo Using CMake generator: %CMAKE_GENERATOR%

REM Find the exact path to cl.exe
for /f "tokens=*" %%i in ('where cl.exe') do set "CL_EXE=%%i"
echo Using MSVC compiler: %CL_EXE%

REM Configure with CMake - Ensure MSVC is used for CUDA
cmake -G "%CMAKE_GENERATOR%" %CMAKE_GENERATOR_PLATFORM_ARG% -B build ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake" ^
    -DVCPKG_TARGET_TRIPLET=x64-windows ^
    -DVCPKG_INSTALLED_DIR="%VCPKG_ROOT%/installed" ^
    -DCMAKE_C_COMPILER="%CL_EXE%" ^
    -DCMAKE_CXX_COMPILER="%CL_EXE%" ^
    -DCMAKE_CUDA_COMPILER="%CUDA_PATH%/bin/nvcc.exe" ^
    -DCMAKE_CUDA_HOST_COMPILER="%CL_EXE%" ^
    -DCMAKE_CUDA_FLAGS="-allow-unsupported-compiler" ^
    -DCMAKE_CUDA_ARCHITECTURES=%CUDA_ARCH% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
    -DCMAKE_FIND_ROOT_PATH="%VCPKG_ROOT%/installed/x64-windows" ^
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
    -DCUDA_TOOLKIT_ROOT_DIR="%CUDA_PATH%" ^
    -DCUDA_HOST_COMPILER="%CL_EXE%" ^
    -DInferenceEngine_DIR="%OPENVINO_PATH%/runtime/cmake" ^
    -DWHISPER_MIMALLOC=ON ^
    -DWHISPER_LIBSNDFILE=ON ^
    -DWHISPER_SERVER_CPPRESTSDK=ON ^
    -DWHISPER_BUILD_TESTS=ON ^
    -DWHISPER_TBB=ON ^
    -DWHISPER_BOOST_STACKTRACE=ON ^
    -DWHISPER_CUDA_API_WRAPPERS=OFF ^
    -DWHISPER_BUILD_EXAMPLES=ON

REM Check for CMake errors
if errorlevel 1 (
    echo CMake configuration failed
    exit /b 1
)

REM Display build system version
if "%CMAKE_GENERATOR%"=="Ninja" (
    echo Build system: Ninja
    ninja --version
) else (
    echo Build system: MSBuild
    msbuild /version
)

REM -----------------------------------------------------------
REM 6. BUILD EXECUTION
REM -----------------------------------------------------------

REM Add CUDA environment variables for better performance
set "CUDA_DEVICE_HEAP_SIZE=2048"
set "CUDA_DEVICE_MAX_CONNECTIONS=32"

REM Build with MSVC compiler
cmake --build build --config Release --parallel %NUM_CORES%

if errorlevel 1 (
    echo Build failed
    exit /b 1
)

REM Calculate build time
set "END_TIME=%TIME%"
call :calculate_duration "%START_TIME%" "%END_TIME%"
echo Build duration: %DURATION%

REM -----------------------------------------------------------
REM 7. ARTIFACTS ORGANIZATION
REM -----------------------------------------------------------
REM Create output directories
if not exist "build/bin/Release" mkdir "build/bin/Release"
if not exist "build/bin/Release/examples" mkdir "build/bin/Release/examples"
if not exist "build/bin/Release/samples" mkdir "build/bin/Release/samples"

REM Copy dependencies
echo Copying dependencies...
set "DEPENDENCIES_OK=1"

call :copy_dlls "%INTEL_OPENVINO_DIR%/runtime/bin/*.dll" "build/bin/Release" "OpenVINO"
call :copy_dlls "%INTEL_OPENVINO_DIR%/runtime/3rdparty/tbb/bin/*.dll" "build/bin/Release" "TBB"
call :copy_dlls "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Redist/MSVC/14.38.33130/x64/Microsoft.VC143.CRT/*.dll" "build/bin/Release" "MSVC"
call :copy_dlls "%INTEL_OPENVINO_DIR%/runtime/3rdparty/*.dll" "build/bin/Release" "Other"
call :copy_dlls "%VCPKG_ROOT%/installed/x64-windows/bin/*.dll" "build/bin/Release" "VCPKG"

REM Copy executables
echo Copying example executables...
xcopy /y "build/bin/*.exe" "build/bin/Release/" >nul 2>&1
if exist "build/bin/Release/whisper-*.*" xcopy /y "build/bin/Release/whisper-*.*" "build/bin/Release/examples/" >nul 2>&1
if exist "build/examples/*.exe" xcopy /y "build/examples/*.exe" "build/bin/Release/examples/" >nul 2>&1
if exist "build/samples/*.exe" xcopy /y "build/samples/*.exe" "build/bin/Release/samples/" >nul 2>&1

if %DEPENDENCIES_OK%==0 (
    echo Error: Some dependencies failed to copy
    exit /b 1
)

echo Build completed successfully

REM Run a simple test
echo Running simple test...
"build/bin/Release/main" -h

echo.
echo All done!

exit /b 0

REM -----------------------------------------------------------
REM 8. HELPER FUNCTIONS
REM -----------------------------------------------------------
:copy_dlls
xcopy /y %~1 %~2 >nul 2>&1
if errorlevel 1 (
    echo Error copying %~3 dependencies
    set "DEPENDENCIES_OK=0"
)
goto :eof

:calculate_duration
set "START_H=%~1:~0,2%"
set "START_M=%~1:~3,2%"
set "START_S=%~1:~6,2%"
set "END_H=%~2:~0,2%"
set "END_M=%~2:~3,2%"
set "END_S=%~2:~6,2%"

REM Handle time spanning midnight
if %END_H% LSS %START_H% set /a "END_H+=24"

set /a "DURATION_S=(END_H-%START_H%)*3600 + (END_M-%START_M%)*60 + (END_S-%START_S%)"
set "DURATION=%DURATION_S% seconds"
goto :eof