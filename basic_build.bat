@echo off
setlocal enabledelayedexpansion

REM Basic whisper.cpp build without vcpkg
set "CUDA_PATH=C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8"
set "CUDA_ARCH=89"
set "NINJA_PATH=C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja"

REM Setup Visual Studio environment
call "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat"

REM Add Ninja to PATH
set "PATH=%NINJA_PATH%;%PATH%"

REM Clean build directory
if exist build rmdir /s /q build
mkdir build

REM Find the exact path to cl.exe
for /f "tokens=*" %%i in ('where cl.exe') do set "CL_EXE=%%i"
echo Using MSVC compiler: %CL_EXE%

REM No-dependency CMake configuration
cmake -G "Ninja" -B build ^
    -DCMAKE_C_COMPILER="%CL_EXE%" ^
    -DCMAKE_CXX_COMPILER="%CL_EXE%" ^
    -DCMAKE_CUDA_COMPILER="%CUDA_PATH%\bin\nvcc.exe" ^
    -DCMAKE_CUDA_HOST_COMPILER="%CL_EXE%" ^
    -DCMAKE_CUDA_FLAGS="-allow-unsupported-compiler" ^
    -DCMAKE_CUDA_ARCHITECTURES=%CUDA_ARCH% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DGGML_CUDA=ON ^
    -DGGML_OPENMP=ON ^
    -DGGML_AVX2=ON ^
    -DGGML_AVX=ON ^
    -DGGML_F16C=ON ^
    -DGGML_FMA=ON ^
    -DWHISPER_BUILD_EXAMPLES=ON ^
    -DWHISPER_SDL2=OFF ^
    -DWHISPER_CURL=OFF ^
    -DWHISPER_MIMALLOC=OFF ^
    -DWHISPER_LIBSNDFILE=OFF ^
    -DWHISPER_SERVER_CPPRESTSDK=OFF ^
    -DWHISPER_BUILD_TESTS=OFF ^
    -DWHISPER_TBB=OFF ^
    -DWHISPER_BOOST_STACKTRACE=OFF ^
    -DWHISPER_OPENVINO=OFF

if errorlevel 1 (
    echo CMake configuration failed
    exit /b 1
)

REM Build
cmake --build build --config Release --parallel %NUMBER_OF_PROCESSORS%

if errorlevel 1 (
    echo Build failed
    exit /b 1
)

echo Build completed successfully

REM Test the main executable
if exist "build\bin\main.exe" (
    echo Testing main executable...
    "build\bin\main.exe" -h
) else if exist "build\bin\whisper-cli.exe" (
    echo Testing whisper-cli executable...
    "build\bin\whisper-cli.exe" -h
) else (
    echo Available executables:
    dir "build\bin\" /b
)

echo Done!