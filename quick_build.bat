@echo off
setlocal enabledelayedexpansion

REM Environment setup
set "VCPKG_ROOT=C:\codedev\vcpkg"
set "CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8"
set "CUDA_ARCH=89"
set "OPENVINO_PATH=C:\Program Files (x86)\Intel\openvino_2024.6.0"

REM Set up Visual Studio environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

REM Set up OpenVINO environment
call "%OPENVINO_PATH%\setupvars.bat"

REM Clean build directory
if exist build rmdir /s /q build
mkdir build

REM Configure with CMake - use forward slashes in paths
cmake -G "Ninja" -B build ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake" ^
    -DVCPKG_TARGET_TRIPLET=x64-windows ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
    -DCMAKE_C_COMPILER=cl.exe ^
    -DCMAKE_CXX_COMPILER=cl.exe ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DWHISPER_OPENVINO=ON ^
    -DGGML_CUDA=ON ^
    -DGGML_OPENMP=ON ^
    -DWHISPER_SDL2=ON ^
    -DCUDA_TOOLKIT_ROOT_DIR="%CUDA_PATH%" ^
    -DCMAKE_CUDA_ARCHITECTURES=%CUDA_ARCH% ^
    -DInferenceEngine_DIR="%OPENVINO_PATH%/runtime/cmake"

REM Build
cmake --build build --config Release --parallel

REM Copy required DLLs
echo Copying OpenVINO and TBB DLLs...
xcopy /y "%OPENVINO_PATH%\runtime\bin\*.dll" "build\bin\Release\"
xcopy /y "%OPENVINO_PATH%\runtime\3rdparty\tbb\bin\*.dll" "build\bin\Release\"

REM Copy other dependencies from vcpkg
echo Copying vcpkg dependencies...
xcopy /y "%VCPKG_ROOT%\installed\x64-windows\bin\*.dll" "build\bin\Release\"