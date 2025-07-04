@echo off
setlocal enabledelayedexpansion

echo Setting up Visual Studio environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

echo Cleaning previous build...
if exist "build" rmdir /s /q "build"
mkdir build
cd build

echo Configuring with CMake (CPU-only)...
cmake -G "Visual Studio 17 2022" -A x64 ^
  -DWHISPER_CUDA=OFF ^
  -DWHISPER_CUBLAS=OFF ^
  -DWHISPER_OPENVINO=OFF ^
  -DWHISPER_COREML=OFF ^
  -DWHISPER_METAL=OFF ^
  -DWHISPER_VULKAN=OFF ^
  -DGGML_VULKAN=OFF ^
  -DGGML_CUDA=OFF ^
  -DGGML_CUBLAS=OFF ^
  -DGGML_OPENVINO=OFF ^
  -DGGML_COREML=OFF ^
  -DGGML_METAL=OFF ^
  -DWHISPER_SDL2=OFF ^
  -DWHISPER_FFMPEG=OFF ^
  -DWHISPER_LIBSNDFILE=OFF ^
  -DWHISPER_SERVER_CPPRESTSDK=OFF ^
  -DCMAKE_BUILD_TYPE=Release ^
  ..

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed
    exit /b %ERRORLEVEL%
)

echo Building with MSBuild...
msbuild whisper.cpp.sln /p:Configuration=Release /p:Platform=x64 /m

if %ERRORLEVEL% neq 0 (
    echo Build failed
    exit /b %ERRORLEVEL%
)

echo Build completed successfully!
echo Binaries are in: %CD%\bin\Release\