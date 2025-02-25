@echo off
setlocal enabledelayedexpansion

REM Setup environments
call "C:/Program Files (x86)/Intel/openvino_2024.6.0/setupvars.bat"
set "PATH=%VCPKG_ROOT%;%PATH%"
set "PATH=C:\msys64\mingw64\bin;%PATH%"

REM Set CUDA cache directory
set "CUDA_CACHE_PATH=%LOCALAPPDATA%\CUDA\Cache"
if not exist "%CUDA_CACHE_PATH%" mkdir "%CUDA_CACHE_PATH%"
set "CUDA_CACHE_MAXSIZE=1024"

if exist build\ rmdir /s /q build

cmake -G "MinGW Makefiles" -B build ^
    -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
    -DCMAKE_C_COMPILER=gcc ^
    -DCMAKE_CXX_COMPILER=g++ ^
    -DWHISPER_OPENVINO=ON ^
    -DGGML_CUDA=ON ^
    -DGGML_OPENMP=ON ^
    -DWHISPER_SDL2=ON ^
    -DWHISPER_CURL=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCUDA_TOOLKIT_ROOT_DIR="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8" ^
    -DInferenceEngine_DIR="C:/Program Files (x86)/Intel/openvino_2024.6.0/runtime/cmake" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CUDA_FLAGS="--use-fast-math --cache-path %CUDA_CACHE_PATH% --keep"

cmake --build build --config Release -- -j8

REM Copy dependencies
echo Copying OpenVINO DLLs...
xcopy /y "%INTEL_OPENVINO_DIR%\runtime\bin\*.dll" "build\bin\"

echo Copying TBB DLLs...
xcopy /y "%INTEL_OPENVINO_DIR%\runtime\3rdparty\tbb\bin\*.dll" "build\bin\"

echo Copying MinGW dependencies...
for %%x in (libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll) do (
    xcopy /y "C:\msys64\mingw64\bin\%%x" "build\bin\"
)

echo Copying other dependencies...
xcopy /y "%INTEL_OPENVINO_DIR%\runtime\3rdparty\*.dll" "build\bin\"