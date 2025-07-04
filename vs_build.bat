@echo off
setlocal enabledelayedexpansion

REM Visual Studio generator build
REM Setup Visual Studio environment
call "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat"

REM Clean build directory
if exist build rmdir /s /q build
mkdir build

REM Simple build following the Makefile approach
cmake -B build ^
    -G "Visual Studio 17 2022" ^
    -A x64 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DGGML_CUDA=OFF ^
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

REM Build with Visual Studio
cmake --build build --config Release --parallel %NUMBER_OF_PROCESSORS%

if errorlevel 1 (
    echo Build failed
    exit /b 1
)

echo Build completed successfully

REM Look for executables
echo Build directory contents:
if exist "build\bin\Release" (
    echo Executables in build\bin\Release:
    dir "build\bin\Release" /b
    
    if exist "build\bin\Release\main.exe" (
        echo Testing main executable...
        "build\bin\Release\main.exe" -h
    ) else if exist "build\bin\Release\whisper-cli.exe" (
        echo Testing whisper-cli executable...
        "build\bin\Release\whisper-cli.exe" -h
    )
) else if exist "build\bin" (
    echo Executables in build\bin:
    dir "build\bin" /b
) else (
    echo Looking for output files...
    dir "build" /b
)

echo Done!