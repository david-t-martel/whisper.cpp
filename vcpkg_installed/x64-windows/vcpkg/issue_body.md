Package: yasm[core,tools]:x64-windows@1.3.0#6

**Host Environment**

- Host: x64-windows
- Compiler: MSVC 19.44.35211.0
-    vcpkg-tool version: 2025-04-01-9c604254140797833b6f76908435c9fcbf09920e
    vcpkg-readonly: true
    vcpkg-scripts version: 4f8fe05871555c1798dbcb1957d0d595e94f7b57

**To Reproduce**

`vcpkg install `

**Failure logs**

```
-- Using cached yasm-yasm-009450c7ad4d425fa5a10ac4bd6efbd25248d823.tar.gz
-- Cleaning sources at T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean. Use --editable to skip cleaning for the packages you specify.
-- Extracting source C:/Users/david/AppData/Local/vcpkg/downloads/yasm-yasm-009450c7ad4d425fa5a10ac4bd6efbd25248d823.tar.gz
-- Applying patch add-feature-tools.patch
-- Applying patch fix-arm-cross-build.patch
-- Applying patch fix-overlay-pdb.patch
-- Using source at T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean
-- Found external ninja('1.12.1').
-- Configuring x64-windows
CMake Error at scripts/cmake/vcpkg_execute_required_process.cmake:127 (message):
    Command failed: "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" -v
    Working Directory: T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/vcpkg-parallel-configure
    Error code: 1
    See logs for more information:
      T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-dbg-CMakeCache.txt.log
      T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-rel-CMakeCache.txt.log
      T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-dbg-CMakeConfigureLog.yaml.log
      T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-rel-CMakeConfigureLog.yaml.log
      T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-out.log

Call Stack (most recent call first):
  T:/projects/whisper.cpp/vcpkg_installed/x64-windows/x64-windows/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:269 (vcpkg_execute_required_process)
  C:/Users/david/AppData/Local/vcpkg/registries/git-trees/cd30518fa90953d3fa7cc1c0096bf628d2b457be/portfile.cmake:32 (vcpkg_cmake_configure)
  scripts/ports.cmake:203 (include)



```

<details><summary>T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-out.log</summary>

```
[1/2] "C:/Program Files/CMake/bin/cmake.exe" -E chdir "../../x64-windows-dbg" "C:/Program Files/CMake/bin/cmake.exe" "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_INSTALL_PREFIX=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/pkgs/yasm_x64-windows/debug" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBUILD_TOOLS=ON" "-DPYTHON_EXECUTABLE=C:/Users/david/AppData/Local/vcpkg/downloads/tools/python/python-3.12.7-x64-1/python.exe" "-DENABLE_NLS=OFF" "-DYASM_BUILD_TESTS=OFF" "-DCMAKE_MAKE_PROGRAM=C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v143" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/" "-D_VCPKG_INSTALLED_DIR=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/" "-DVCPKG_MANIFEST_INSTALL=OFF"
FAILED: ../../x64-windows-dbg/CMakeCache.txt 
"C:/Program Files/CMake/bin/cmake.exe" -E chdir "../../x64-windows-dbg" "C:/Program Files/CMake/bin/cmake.exe" "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_INSTALL_PREFIX=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/pkgs/yasm_x64-windows/debug" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBUILD_TOOLS=ON" "-DPYTHON_EXECUTABLE=C:/Users/david/AppData/Local/vcpkg/downloads/tools/python/python-3.12.7-x64-1/python.exe" "-DENABLE_NLS=OFF" "-DYASM_BUILD_TESTS=OFF" "-DCMAKE_MAKE_PROGRAM=C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v143" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/" "-D_VCPKG_INSTALLED_DIR=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/" "-DVCPKG_MANIFEST_INSTALL=OFF"
CMake Warning (dev) at CMakeLists.txt:1 (PROJECT):
  cmake_minimum_required() should be called prior to this top-level project()
  call.  Please see the cmake-commands(7) manual for usage documentation of
  both commands.
This warning is for project developers.  Use -Wno-dev to suppress it.

-- The C compiler identification is MSVC 19.44.35211.0
-- The CXX compiler identification is MSVC 19.44.35211.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
CMake Error at CMakeLists.txt:2 (CMAKE_MINIMUM_REQUIRED):
  Compatibility with CMake < 3.5 has been removed from CMake.

  Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
  to tell CMake that the project requires at least <min> but has been updated
  to work with policies introduced by <max> or earlier.

  Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.


-- Configuring incomplete, errors occurred!
[2/2] "C:/Program Files/CMake/bin/cmake.exe" -E chdir ".." "C:/Program Files/CMake/bin/cmake.exe" "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/pkgs/yasm_x64-windows" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBUILD_TOOLS=ON" "-DPYTHON_EXECUTABLE=C:/Users/david/AppData/Local/vcpkg/downloads/tools/python/python-3.12.7-x64-1/python.exe" "-DENABLE_NLS=OFF" "-DYASM_BUILD_TESTS=OFF" "-DCMAKE_MAKE_PROGRAM=C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v143" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/" "-D_VCPKG_INSTALLED_DIR=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/" "-DVCPKG_MANIFEST_INSTALL=OFF"
FAILED: ../CMakeCache.txt 
"C:/Program Files/CMake/bin/cmake.exe" -E chdir ".." "C:/Program Files/CMake/bin/cmake.exe" "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/pkgs/yasm_x64-windows" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBUILD_TOOLS=ON" "-DPYTHON_EXECUTABLE=C:/Users/david/AppData/Local/vcpkg/downloads/tools/python/python-3.12.7-x64-1/python.exe" "-DENABLE_NLS=OFF" "-DYASM_BUILD_TESTS=OFF" "-DCMAKE_MAKE_PROGRAM=C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" "-DBUILD_SHARED_LIBS=ON" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/toolchains/windows.cmake" "-DVCPKG_TARGET_TRIPLET=x64-windows" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=v143" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCMAKE_TOOLCHAIN_FILE=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/buildsystems/vcpkg.cmake" "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON" "-DVCPKG_CXX_FLAGS=" "-DVCPKG_CXX_FLAGS_RELEASE=" "-DVCPKG_CXX_FLAGS_DEBUG=" "-DVCPKG_C_FLAGS=" "-DVCPKG_C_FLAGS_RELEASE=" "-DVCPKG_C_FLAGS_DEBUG=" "-DVCPKG_CRT_LINKAGE=dynamic" "-DVCPKG_LINKER_FLAGS=" "-DVCPKG_LINKER_FLAGS_RELEASE=" "-DVCPKG_LINKER_FLAGS_DEBUG=" "-DVCPKG_TARGET_ARCHITECTURE=x64" "-DCMAKE_INSTALL_LIBDIR:STRING=lib" "-DCMAKE_INSTALL_BINDIR:STRING=bin" "-D_VCPKG_ROOT_DIR=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/" "-D_VCPKG_INSTALLED_DIR=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/" "-DVCPKG_MANIFEST_INSTALL=OFF"
CMake Warning (dev) at CMakeLists.txt:1 (PROJECT):
  cmake_minimum_required() should be called prior to this top-level project()
  call.  Please see the cmake-commands(7) manual for usage documentation of
  both commands.
This warning is for project developers.  Use -Wno-dev to suppress it.

-- The C compiler identification is MSVC 19.44.35211.0
-- The CXX compiler identification is MSVC 19.44.35211.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
CMake Error at CMakeLists.txt:2 (CMAKE_MINIMUM_REQUIRED):
  Compatibility with CMake < 3.5 has been removed from CMake.

  Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
  to tell CMake that the project requires at least <min> but has been updated
  to work with policies introduced by <max> or earlier.

  Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.


-- Configuring incomplete, errors occurred!
ninja: build stopped: subcommand failed.
```
</details>

<details><summary>T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-dbg-CMakeConfigureLog.yaml.log</summary>

```

---
events:
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineSystem.cmake:205 (message)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      The system is: Windows - 10.0.26100 - AMD64
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:17 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:64 (__determine_compiler_id_test)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCCompiler.cmake:123 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Compiling the C compiler identification source file "CMakeCCompilerId.c" succeeded.
      Compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe 
      Build flags: /nologo;/DWIN32;/D_WINDOWS;/utf-8;/MP
      Id flags:  
      
      The output was:
      0
      CMakeCCompilerId.c
      
      
      Compilation of the C compiler identification source "CMakeCCompilerId.c" produced "CMakeCCompilerId.exe"
      
      Compilation of the C compiler identification source "CMakeCCompilerId.c" produced "CMakeCCompilerId.obj"
      
      The C compiler identification is MSVC, found in:
        T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg/CMakeFiles/4.0.3/CompilerIdC/CMakeCCompilerId.exe
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:1322 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:250 (CMAKE_DETERMINE_MSVC_SHOWINCLUDES_PREFIX)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCCompiler.cmake:123 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Detecting C compiler /showIncludes prefix:
        main.c
        Note: including file: T:\\projects\\whisper.cpp\\vcpkg_installed\\x64-windows\\vcpkg\\blds\\yasm\\x64-windows-dbg\\CMakeFiles\\ShowIncludes\\foo.h
        
      Found prefix "Note: including file: "
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:17 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:64 (__determine_compiler_id_test)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCXXCompiler.cmake:126 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Compiling the CXX compiler identification source file "CMakeCXXCompilerId.cpp" succeeded.
      Compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe 
      Build flags: /nologo;/DWIN32;/D_WINDOWS;/utf-8;/GR;/EHsc;/MP
      Id flags:  
      
      The output was:
      0
      CMakeCXXCompilerId.cpp
      
      
      Compilation of the CXX compiler identification source "CMakeCXXCompilerId.cpp" produced "CMakeCXXCompilerId.exe"
      
      Compilation of the CXX compiler identification source "CMakeCXXCompilerId.cpp" produced "CMakeCXXCompilerId.obj"
      
      The CXX compiler identification is MSVC, found in:
        T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg/CMakeFiles/4.0.3/CompilerIdCXX/CMakeCXXCompilerId.exe
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:1322 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:250 (CMAKE_DETERMINE_MSVC_SHOWINCLUDES_PREFIX)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCXXCompiler.cmake:126 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Detecting CXX compiler /showIncludes prefix:
        main.c
        Note: including file: T:\\projects\\whisper.cpp\\vcpkg_installed\\x64-windows\\vcpkg\\blds\\yasm\\x64-windows-dbg\\CMakeFiles\\ShowIncludes\\foo.h
        
      Found prefix "Note: including file: "
  -
    kind: "try_compile-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:83 (try_compile)"
...
Skipped 13 lines
...
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v143"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg"
    buildResult:
      variable: "CMAKE_C_ABI_COMPILED"
      cached: true
      stdout: |
        Change Dir: 'T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-a2ines'
        
        Run Build Command(s): "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" -v cmTC_52f21
        [1/2] C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\cl.exe  /nologo   /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1 /showIncludes /FoCMakeFiles\\cmTC_52f21.dir\\CMakeCCompilerABI.c.obj /FdCMakeFiles\\cmTC_52f21.dir\\ /FS -c "C:\\Program Files\\CMake\\share\\cmake-4.0\\Modules\\CMakeCCompilerABI.c"
        [2/2] C:\\WINDOWS\\system32\\cmd.exe /C "cd . && "C:\\Program Files\\CMake\\bin\\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\\cmTC_52f21.dir --rc=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\rc.exe --mt=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\mt.exe --manifests  -- C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\link.exe /nologo CMakeFiles\\cmTC_52f21.dir\\CMakeCCompilerABI.c.obj  /out:cmTC_52f21.exe /implib:cmTC_52f21.lib /pdb:cmTC_52f21.pdb /version:0.0 /machine:x64 /nologo /debug /INCREMENTAL /subsystem:console  kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib && cd ."
        
      exitCode: 0
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:227 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Parsed C implicit link information:
        link line regex: [^( *|.*[/\\])(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?|CMAKE_LINK_STARTFILE-NOTFOUND|([^/\\]+-)?ld|collect2)[^/\\]*( |$)]
        linker tool regex: [^[ 	]*(->|")?[ 	]*(([^"]*[/\\])?(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?))("|,| |$)]
        linker tool for 'C': C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe
        implicit libs: []
        implicit objs: []
        implicit dirs: []
        implicit fwks: []
      
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/Internal/CMakeDetermineLinkerId.cmake:36 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:270 (cmake_determine_linker_id)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Running the C compiler's linker: "C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe" "-v"
      Microsoft (R) Incremental Linker Version 14.44.35211.0
      Copyright (C) Microsoft Corporation.  All rights reserved.
  -
    kind: "try_compile-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:83 (try_compile)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCXXCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    checks:
      - "Detecting CXX compiler ABI info"
    directories:
      source: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-za2zyg"
      binary: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-za2zyg"
    cmakeVariables:
      CMAKE_CXX_FLAGS: " /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP "
      CMAKE_CXX_SCAN_FOR_MODULES: "OFF"
      CMAKE_EXE_LINKER_FLAGS: "/machine:x64"
      CMAKE_MSVC_DEBUG_INFORMATION_FORMAT: ""
      CMAKE_MSVC_RUNTIME_LIBRARY: "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:dynamic,dynamic>:DLL>"
      VCPKG_CHAINLOAD_TOOLCHAIN_FILE: "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/toolchains/windows.cmake"
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v143"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg"
    buildResult:
      variable: "CMAKE_CXX_ABI_COMPILED"
      cached: true
      stdout: |
        Change Dir: 'T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg/CMakeFiles/CMakeScratch/TryCompile-za2zyg'
        
        Run Build Command(s): "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" -v cmTC_2d8a4
        [1/2] C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\cl.exe  /nologo /TP   /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP   /MDd /Z7 /Ob0 /Od /RTC1 /showIncludes /FoCMakeFiles\\cmTC_2d8a4.dir\\CMakeCXXCompilerABI.cpp.obj /FdCMakeFiles\\cmTC_2d8a4.dir\\ /FS -c "C:\\Program Files\\CMake\\share\\cmake-4.0\\Modules\\CMakeCXXCompilerABI.cpp"
        [2/2] C:\\WINDOWS\\system32\\cmd.exe /C "cd . && "C:\\Program Files\\CMake\\bin\\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\\cmTC_2d8a4.dir --rc=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\rc.exe --mt=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\mt.exe --manifests  -- C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\link.exe /nologo CMakeFiles\\cmTC_2d8a4.dir\\CMakeCXXCompilerABI.cpp.obj  /out:cmTC_2d8a4.exe /implib:cmTC_2d8a4.lib /pdb:cmTC_2d8a4.pdb /version:0.0 /machine:x64 /nologo /debug /INCREMENTAL /subsystem:console  kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib && cd ."
        
      exitCode: 0
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:227 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCXXCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Parsed CXX implicit link information:
        link line regex: [^( *|.*[/\\])(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?|CMAKE_LINK_STARTFILE-NOTFOUND|([^/\\]+-)?ld|collect2)[^/\\]*( |$)]
        linker tool regex: [^[ 	]*(->|")?[ 	]*(([^"]*[/\\])?(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?))("|,| |$)]
        linker tool for 'CXX': C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe
        implicit libs: []
        implicit objs: []
        implicit dirs: []
        implicit fwks: []
      
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/Internal/CMakeDetermineLinkerId.cmake:36 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:270 (cmake_determine_linker_id)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCXXCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Running the CXX compiler's linker: "C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe" "-v"
      Microsoft (R) Incremental Linker Version 14.44.35211.0
      Copyright (C) Microsoft Corporation.  All rights reserved.
...
```
</details>

<details><summary>T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-rel-CMakeConfigureLog.yaml.log</summary>

```

---
events:
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineSystem.cmake:205 (message)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      The system is: Windows - 10.0.26100 - AMD64
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:17 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:64 (__determine_compiler_id_test)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCCompiler.cmake:123 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Compiling the C compiler identification source file "CMakeCCompilerId.c" succeeded.
      Compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe 
      Build flags: /nologo;/DWIN32;/D_WINDOWS;/utf-8;/MP
      Id flags:  
      
      The output was:
      0
      CMakeCCompilerId.c
      
      
      Compilation of the C compiler identification source "CMakeCCompilerId.c" produced "CMakeCCompilerId.exe"
      
      Compilation of the C compiler identification source "CMakeCCompilerId.c" produced "CMakeCCompilerId.obj"
      
      The C compiler identification is MSVC, found in:
        T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/CMakeFiles/4.0.3/CompilerIdC/CMakeCCompilerId.exe
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:1322 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:250 (CMAKE_DETERMINE_MSVC_SHOWINCLUDES_PREFIX)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCCompiler.cmake:123 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Detecting C compiler /showIncludes prefix:
        main.c
        Note: including file: T:\\projects\\whisper.cpp\\vcpkg_installed\\x64-windows\\vcpkg\\blds\\yasm\\x64-windows-rel\\CMakeFiles\\ShowIncludes\\foo.h
        
      Found prefix "Note: including file: "
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:17 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:64 (__determine_compiler_id_test)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCXXCompiler.cmake:126 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Compiling the CXX compiler identification source file "CMakeCXXCompilerId.cpp" succeeded.
      Compiler: C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe 
      Build flags: /nologo;/DWIN32;/D_WINDOWS;/utf-8;/GR;/EHsc;/MP
      Id flags:  
      
      The output was:
      0
      CMakeCXXCompilerId.cpp
      
      
      Compilation of the CXX compiler identification source "CMakeCXXCompilerId.cpp" produced "CMakeCXXCompilerId.exe"
      
      Compilation of the CXX compiler identification source "CMakeCXXCompilerId.cpp" produced "CMakeCXXCompilerId.obj"
      
      The CXX compiler identification is MSVC, found in:
        T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/CMakeFiles/4.0.3/CompilerIdCXX/CMakeCXXCompilerId.exe
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:1322 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerId.cmake:250 (CMAKE_DETERMINE_MSVC_SHOWINCLUDES_PREFIX)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCXXCompiler.cmake:126 (CMAKE_DETERMINE_COMPILER_ID)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Detecting CXX compiler /showIncludes prefix:
        main.c
...
Skipped 38 lines
...
      variable: "CMAKE_C_ABI_COMPILED"
      cached: true
      stdout: |
        Change Dir: 'T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-ozr83h'
        
        Run Build Command(s): "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" -v cmTC_13b7c
        [1/2] C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\cl.exe  /nologo   /nologo /DWIN32 /D_WINDOWS /utf-8 /MP   /MDd /Z7 /Ob0 /Od /RTC1 /showIncludes /FoCMakeFiles\\cmTC_13b7c.dir\\CMakeCCompilerABI.c.obj /FdCMakeFiles\\cmTC_13b7c.dir\\ /FS -c "C:\\Program Files\\CMake\\share\\cmake-4.0\\Modules\\CMakeCCompilerABI.c"
        [2/2] C:\\WINDOWS\\system32\\cmd.exe /C "cd . && "C:\\Program Files\\CMake\\bin\\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\\cmTC_13b7c.dir --rc=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\rc.exe --mt=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\mt.exe --manifests  -- C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\link.exe /nologo CMakeFiles\\cmTC_13b7c.dir\\CMakeCCompilerABI.c.obj  /out:cmTC_13b7c.exe /implib:cmTC_13b7c.lib /pdb:cmTC_13b7c.pdb /version:0.0 /machine:x64 /nologo /debug /INCREMENTAL /subsystem:console  kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib && cd ."
        
      exitCode: 0
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:227 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Parsed C implicit link information:
        link line regex: [^( *|.*[/\\])(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?|CMAKE_LINK_STARTFILE-NOTFOUND|([^/\\]+-)?ld|collect2)[^/\\]*( |$)]
        linker tool regex: [^[ 	]*(->|")?[ 	]*(([^"]*[/\\])?(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?))("|,| |$)]
        linker tool for 'C': C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe
        implicit libs: []
        implicit objs: []
        implicit dirs: []
        implicit fwks: []
      
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/Internal/CMakeDetermineLinkerId.cmake:36 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:270 (cmake_determine_linker_id)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Running the C compiler's linker: "C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe" "-v"
      Microsoft (R) Incremental Linker Version 14.44.35211.0
      Copyright (C) Microsoft Corporation.  All rights reserved.
  -
    kind: "try_compile-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:83 (try_compile)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCXXCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    checks:
      - "Detecting CXX compiler ABI info"
    directories:
      source: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-nq6r1k"
      binary: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-nq6r1k"
    cmakeVariables:
      CMAKE_CXX_FLAGS: " /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP "
      CMAKE_CXX_SCAN_FOR_MODULES: "OFF"
      CMAKE_EXE_LINKER_FLAGS: "/machine:x64"
      CMAKE_MSVC_DEBUG_INFORMATION_FORMAT: ""
      CMAKE_MSVC_RUNTIME_LIBRARY: "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:dynamic,dynamic>:DLL>"
      VCPKG_CHAINLOAD_TOOLCHAIN_FILE: "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg/scripts/toolchains/windows.cmake"
      VCPKG_CRT_LINKAGE: "dynamic"
      VCPKG_CXX_FLAGS: ""
      VCPKG_CXX_FLAGS_DEBUG: ""
      VCPKG_CXX_FLAGS_RELEASE: ""
      VCPKG_C_FLAGS: ""
      VCPKG_C_FLAGS_DEBUG: ""
      VCPKG_C_FLAGS_RELEASE: ""
      VCPKG_INSTALLED_DIR: "T:/projects/whisper.cpp/vcpkg_installed/x64-windows"
      VCPKG_LINKER_FLAGS: ""
      VCPKG_LINKER_FLAGS_DEBUG: ""
      VCPKG_LINKER_FLAGS_RELEASE: ""
      VCPKG_PLATFORM_TOOLSET: "v143"
      VCPKG_PREFER_SYSTEM_LIBS: "OFF"
      VCPKG_SET_CHARSET_FLAG: "ON"
      VCPKG_TARGET_ARCHITECTURE: "x64"
      VCPKG_TARGET_TRIPLET: "x64-windows"
      Z_VCPKG_ROOT_DIR: "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg"
    buildResult:
      variable: "CMAKE_CXX_ABI_COMPILED"
      cached: true
      stdout: |
        Change Dir: 'T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel/CMakeFiles/CMakeScratch/TryCompile-nq6r1k'
        
        Run Build Command(s): "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/Ninja/ninja.exe" -v cmTC_9fcc4
        [1/2] C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\cl.exe  /nologo /TP   /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP   /MDd /Z7 /Ob0 /Od /RTC1 /showIncludes /FoCMakeFiles\\cmTC_9fcc4.dir\\CMakeCXXCompilerABI.cpp.obj /FdCMakeFiles\\cmTC_9fcc4.dir\\ /FS -c "C:\\Program Files\\CMake\\share\\cmake-4.0\\Modules\\CMakeCXXCompilerABI.cpp"
        [2/2] C:\\WINDOWS\\system32\\cmd.exe /C "cd . && "C:\\Program Files\\CMake\\bin\\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\\cmTC_9fcc4.dir --rc=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\rc.exe --mt=C:\\PROGRA~2\\WI3CF2~1\\10\\bin\\100261~1.0\\x64\\mt.exe --manifests  -- C:\\PROGRA~1\\MICROS~4\\2022\\COMMUN~1\\VC\\Tools\\MSVC\\1444~1.352\\bin\\Hostx64\\x64\\link.exe /nologo CMakeFiles\\cmTC_9fcc4.dir\\CMakeCXXCompilerABI.cpp.obj  /out:cmTC_9fcc4.exe /implib:cmTC_9fcc4.lib /pdb:cmTC_9fcc4.pdb /version:0.0 /machine:x64 /nologo /debug /INCREMENTAL /subsystem:console  kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib && cd ."
        
      exitCode: 0
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:227 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCXXCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Parsed CXX implicit link information:
        link line regex: [^( *|.*[/\\])(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?|CMAKE_LINK_STARTFILE-NOTFOUND|([^/\\]+-)?ld|collect2)[^/\\]*( |$)]
        linker tool regex: [^[ 	]*(->|")?[ 	]*(([^"]*[/\\])?(ld[0-9]*(|\\.[a-rt-z][a-z]*|\\.s[a-np-z][a-z]*|\\.so[a-z]+)|link\\.exe|lld-link(\\.exe)?))("|,| |$)]
        linker tool for 'CXX': C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe
        implicit libs: []
        implicit objs: []
        implicit dirs: []
        implicit fwks: []
      
      
  -
    kind: "message-v1"
    backtrace:
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/Internal/CMakeDetermineLinkerId.cmake:36 (message)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeDetermineCompilerABI.cmake:270 (cmake_determine_linker_id)"
      - "C:/Program Files/CMake/share/cmake-4.0/Modules/CMakeTestCXXCompiler.cmake:26 (CMAKE_DETERMINE_COMPILER_ABI)"
      - "CMakeLists.txt:1 (PROJECT)"
    message: |
      Running the CXX compiler's linker: "C:/PROGRA~1/MICROS~4/2022/COMMUN~1/VC/Tools/MSVC/1444~1.352/bin/Hostx64/x64/link.exe" "-v"
      Microsoft (R) Incremental Linker Version 14.44.35211.0
      Copyright (C) Microsoft Corporation.  All rights reserved.
...
```
</details>

<details><summary>T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-rel-CMakeCache.txt.log</summary>

```
# This is the CMakeCache file.
# For build in directory: t:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel
# It was generated by CMake: C:/Program Files/CMake/bin/cmake.exe
# You can edit this file to change values found and used by cmake.
# If you do not want to change any of the values, simply exit the editor.
# If you do want to change a value, simply edit, save, and exit the editor.
# The syntax for the file is as follows:
# KEY:TYPE=VALUE
# KEY is the name of a variable in the cache.
# TYPE is a hint to GUIs for the type of VALUE, DO NOT EDIT TYPE!.
# VALUE is the current value for the KEY.

########################
# EXTERNAL cache entries
########################

//No help, variable specified on the command line.
BUILD_SHARED_LIBS:UNINITIALIZED=ON

//No help, variable specified on the command line.
BUILD_TOOLS:UNINITIALIZED=ON

//Path to a program.
CMAKE_AR:FILEPATH=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/lib.exe

//Choose the type of build, options are: None Debug Release RelWithDebInfo
// MinSizeRel ...
CMAKE_BUILD_TYPE:STRING=Release

CMAKE_CROSSCOMPILING:STRING=OFF

//CXX compiler
CMAKE_CXX_COMPILER:FILEPATH=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe

CMAKE_CXX_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP '

CMAKE_CXX_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

//Flags used by the CXX compiler during MINSIZEREL builds.
CMAKE_CXX_FLAGS_MINSIZEREL:STRING=/MD /O1 /Ob1 /DNDEBUG

CMAKE_CXX_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//Flags used by the CXX compiler during RELWITHDEBINFO builds.
CMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING=/MD /Zi /O2 /Ob1 /DNDEBUG

//Libraries linked by default with all C++ applications.
CMAKE_CXX_STANDARD_LIBRARIES:STRING=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib

//C compiler
CMAKE_C_COMPILER:FILEPATH=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe

CMAKE_C_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /MP '

CMAKE_C_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

//Flags used by the C compiler during MINSIZEREL builds.
CMAKE_C_FLAGS_MINSIZEREL:STRING=/MD /O1 /Ob1 /DNDEBUG

CMAKE_C_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//Flags used by the C compiler during RELWITHDEBINFO builds.
CMAKE_C_FLAGS_RELWITHDEBINFO:STRING=/MD /Zi /O2 /Ob1 /DNDEBUG

//Libraries linked by default with all C applications.
CMAKE_C_STANDARD_LIBRARIES:STRING=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib

//No help, variable specified on the command line.
CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION:UNINITIALIZED=ON

//Flags used by the linker during all build types.
CMAKE_EXE_LINKER_FLAGS:STRING=/machine:x64

//Flags used by the linker during DEBUG builds.
CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING=/nologo    /debug /INCREMENTAL

//Flags used by the linker during MINSIZEREL builds.
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING=/INCREMENTAL:NO

CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING='/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF  '

//Flags used by the linker during RELWITHDEBINFO builds.
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING=/debug /INCREMENTAL

//Enable/Disable output of build database during the build.
CMAKE_EXPORT_BUILD_DATABASE:BOOL=

//Enable/Disable output of compile commands during generation.
CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=

//No help, variable specified on the command line.
CMAKE_EXPORT_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//No help, variable specified on the command line.
CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//No help, variable specified on the command line.
CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY:UNINITIALIZED=ON

//Value Computed by CMake.
...
Skipped 231 lines
...

//Value Computed by CMake
yasm_IS_TOP_LEVEL:STATIC=ON

//Value Computed by CMake
yasm_SOURCE_DIR:STATIC=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean


########################
# INTERNAL cache entries
########################

//ADVANCED property for variable: CMAKE_AR
CMAKE_AR-ADVANCED:INTERNAL=1
//This is the directory where this CMakeCache.txt was created
CMAKE_CACHEFILE_DIR:INTERNAL=t:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-rel
//Major version of cmake used to create the current loaded cache
CMAKE_CACHE_MAJOR_VERSION:INTERNAL=4
//Minor version of cmake used to create the current loaded cache
CMAKE_CACHE_MINOR_VERSION:INTERNAL=0
//Patch version of cmake used to create the current loaded cache
CMAKE_CACHE_PATCH_VERSION:INTERNAL=3
//Path to CMake executable.
CMAKE_COMMAND:INTERNAL=C:/Program Files/CMake/bin/cmake.exe
//Path to cpack program executable.
CMAKE_CPACK_COMMAND:INTERNAL=C:/Program Files/CMake/bin/cpack.exe
//Path to ctest program executable.
CMAKE_CTEST_COMMAND:INTERNAL=C:/Program Files/CMake/bin/ctest.exe
//ADVANCED property for variable: CMAKE_CXX_COMPILER
CMAKE_CXX_COMPILER-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS
CMAKE_CXX_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_DEBUG
CMAKE_CXX_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_MINSIZEREL
CMAKE_CXX_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_RELEASE
CMAKE_CXX_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_RELWITHDEBINFO
CMAKE_CXX_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_STANDARD_LIBRARIES
CMAKE_CXX_STANDARD_LIBRARIES-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_COMPILER
CMAKE_C_COMPILER-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS
CMAKE_C_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_DEBUG
CMAKE_C_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_MINSIZEREL
CMAKE_C_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELEASE
CMAKE_C_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELWITHDEBINFO
CMAKE_C_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_STANDARD_LIBRARIES
CMAKE_C_STANDARD_LIBRARIES-ADVANCED:INTERNAL=1
//Path to cache edit program executable.
CMAKE_EDIT_COMMAND:INTERNAL=C:/Program Files/CMake/bin/cmake-gui.exe
//Executable file format
CMAKE_EXECUTABLE_FORMAT:INTERNAL=Unknown
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS
CMAKE_EXE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_DEBUG
CMAKE_EXE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELEASE
CMAKE_EXE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_BUILD_DATABASE
CMAKE_EXPORT_BUILD_DATABASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_COMPILE_COMMANDS
CMAKE_EXPORT_COMPILE_COMMANDS-ADVANCED:INTERNAL=1
//Name of external makefile project generator.
CMAKE_EXTRA_GENERATOR:INTERNAL=
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Ninja
//Generator instance identifier.
CMAKE_GENERATOR_INSTANCE:INTERNAL=
//Name of generator platform.
CMAKE_GENERATOR_PLATFORM:INTERNAL=
//Name of generator toolset.
CMAKE_GENERATOR_TOOLSET:INTERNAL=
//Source directory with the top level CMakeLists.txt file for this
// project
CMAKE_HOME_DIRECTORY:INTERNAL=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean
//ADVANCED property for variable: CMAKE_LINKER
CMAKE_LINKER-ADVANCED:INTERNAL=1
//Name of CMakeLists files to read
CMAKE_LIST_FILE_NAME:INTERNAL=CMakeLists.txt
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS
CMAKE_MODULE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_DEBUG
CMAKE_MODULE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELEASE
CMAKE_MODULE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MT
CMAKE_MT-ADVANCED:INTERNAL=1
//number of local generators
CMAKE_NUMBER_OF_MAKEFILES:INTERNAL=1
//Platform information initialized
CMAKE_PLATFORM_INFO_INITIALIZED:INTERNAL=1
//noop for ranlib
CMAKE_RANLIB:INTERNAL=:
//ADVANCED property for variable: CMAKE_RC_COMPILER
CMAKE_RC_COMPILER-ADVANCED:INTERNAL=1
CMAKE_RC_COMPILER_WORKS:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS
CMAKE_RC_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_DEBUG
CMAKE_RC_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_MINSIZEREL
CMAKE_RC_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELEASE
CMAKE_RC_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELWITHDEBINFO
CMAKE_RC_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//Path to CMake installation.
CMAKE_ROOT:INTERNAL=C:/Program Files/CMake/share/cmake-4.0
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS
CMAKE_SHARED_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_DEBUG
CMAKE_SHARED_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELEASE
CMAKE_SHARED_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_INSTALL_RPATH
CMAKE_SKIP_INSTALL_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_RPATH
CMAKE_SKIP_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS
CMAKE_STATIC_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_DEBUG
CMAKE_STATIC_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL
CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELEASE
CMAKE_STATIC_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_TOOLCHAIN_FILE
CMAKE_TOOLCHAIN_FILE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_VERBOSE_MAKEFILE
CMAKE_VERBOSE_MAKEFILE-ADVANCED:INTERNAL=1
//Install the dependencies listed in your manifest:
//\n    If this is off, you will have to manually install your dependencies.
//\n    See https://github.com/microsoft/vcpkg/tree/master/docs/specifications/manifests.md
// for more info.
//\n
VCPKG_MANIFEST_INSTALL:INTERNAL=OFF
//ADVANCED property for variable: VCPKG_VERBOSE
VCPKG_VERBOSE-ADVANCED:INTERNAL=1
//Making sure VCPKG_MANIFEST_MODE doesn't change
Z_VCPKG_CHECK_MANIFEST_MODE:INTERNAL=OFF
//Vcpkg root directory
Z_VCPKG_ROOT_DIR:INTERNAL=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg

```
</details>

<details><summary>T:\projects\whisper.cpp\vcpkg_installed\x64-windows\vcpkg\blds\yasm\config-x64-windows-dbg-CMakeCache.txt.log</summary>

```
# This is the CMakeCache file.
# For build in directory: t:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg
# It was generated by CMake: C:/Program Files/CMake/bin/cmake.exe
# You can edit this file to change values found and used by cmake.
# If you do not want to change any of the values, simply exit the editor.
# If you do want to change a value, simply edit, save, and exit the editor.
# The syntax for the file is as follows:
# KEY:TYPE=VALUE
# KEY is the name of a variable in the cache.
# TYPE is a hint to GUIs for the type of VALUE, DO NOT EDIT TYPE!.
# VALUE is the current value for the KEY.

########################
# EXTERNAL cache entries
########################

//No help, variable specified on the command line.
BUILD_SHARED_LIBS:UNINITIALIZED=ON

//No help, variable specified on the command line.
BUILD_TOOLS:UNINITIALIZED=ON

//Path to a program.
CMAKE_AR:FILEPATH=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/lib.exe

//Choose the type of build, options are: None Debug Release RelWithDebInfo
// MinSizeRel ...
CMAKE_BUILD_TYPE:STRING=Debug

CMAKE_CROSSCOMPILING:STRING=OFF

//CXX compiler
CMAKE_CXX_COMPILER:FILEPATH=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe

CMAKE_CXX_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc /MP '

CMAKE_CXX_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

//Flags used by the CXX compiler during MINSIZEREL builds.
CMAKE_CXX_FLAGS_MINSIZEREL:STRING=/MD /O1 /Ob1 /DNDEBUG

CMAKE_CXX_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//Flags used by the CXX compiler during RELWITHDEBINFO builds.
CMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING=/MD /Zi /O2 /Ob1 /DNDEBUG

//Libraries linked by default with all C++ applications.
CMAKE_CXX_STANDARD_LIBRARIES:STRING=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib

//C compiler
CMAKE_C_COMPILER:FILEPATH=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/cl.exe

CMAKE_C_FLAGS:STRING=' /nologo /DWIN32 /D_WINDOWS /utf-8 /MP '

CMAKE_C_FLAGS_DEBUG:STRING='/MDd /Z7 /Ob0 /Od /RTC1 '

//Flags used by the C compiler during MINSIZEREL builds.
CMAKE_C_FLAGS_MINSIZEREL:STRING=/MD /O1 /Ob1 /DNDEBUG

CMAKE_C_FLAGS_RELEASE:STRING='/MD /O2 /Oi /Gy /DNDEBUG /Z7 '

//Flags used by the C compiler during RELWITHDEBINFO builds.
CMAKE_C_FLAGS_RELWITHDEBINFO:STRING=/MD /Zi /O2 /Ob1 /DNDEBUG

//Libraries linked by default with all C applications.
CMAKE_C_STANDARD_LIBRARIES:STRING=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib

//No help, variable specified on the command line.
CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION:UNINITIALIZED=ON

//Flags used by the linker during all build types.
CMAKE_EXE_LINKER_FLAGS:STRING=/machine:x64

//Flags used by the linker during DEBUG builds.
CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING=/nologo    /debug /INCREMENTAL

//Flags used by the linker during MINSIZEREL builds.
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING=/INCREMENTAL:NO

CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING='/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF  '

//Flags used by the linker during RELWITHDEBINFO builds.
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING=/debug /INCREMENTAL

//Enable/Disable output of build database during the build.
CMAKE_EXPORT_BUILD_DATABASE:BOOL=

//Enable/Disable output of compile commands during generation.
CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=

//No help, variable specified on the command line.
CMAKE_EXPORT_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//No help, variable specified on the command line.
CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON

//No help, variable specified on the command line.
CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY:UNINITIALIZED=ON

//Value Computed by CMake.
...
Skipped 228 lines
...

//Value Computed by CMake
yasm_BINARY_DIR:STATIC=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg

//Value Computed by CMake
yasm_IS_TOP_LEVEL:STATIC=ON

//Value Computed by CMake
yasm_SOURCE_DIR:STATIC=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean


########################
# INTERNAL cache entries
########################

//ADVANCED property for variable: CMAKE_AR
CMAKE_AR-ADVANCED:INTERNAL=1
//This is the directory where this CMakeCache.txt was created
CMAKE_CACHEFILE_DIR:INTERNAL=t:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/x64-windows-dbg
//Major version of cmake used to create the current loaded cache
CMAKE_CACHE_MAJOR_VERSION:INTERNAL=4
//Minor version of cmake used to create the current loaded cache
CMAKE_CACHE_MINOR_VERSION:INTERNAL=0
//Patch version of cmake used to create the current loaded cache
CMAKE_CACHE_PATCH_VERSION:INTERNAL=3
//Path to CMake executable.
CMAKE_COMMAND:INTERNAL=C:/Program Files/CMake/bin/cmake.exe
//Path to cpack program executable.
CMAKE_CPACK_COMMAND:INTERNAL=C:/Program Files/CMake/bin/cpack.exe
//Path to ctest program executable.
CMAKE_CTEST_COMMAND:INTERNAL=C:/Program Files/CMake/bin/ctest.exe
//ADVANCED property for variable: CMAKE_CXX_COMPILER
CMAKE_CXX_COMPILER-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS
CMAKE_CXX_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_DEBUG
CMAKE_CXX_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_MINSIZEREL
CMAKE_CXX_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_RELEASE
CMAKE_CXX_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_FLAGS_RELWITHDEBINFO
CMAKE_CXX_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_CXX_STANDARD_LIBRARIES
CMAKE_CXX_STANDARD_LIBRARIES-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_COMPILER
CMAKE_C_COMPILER-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS
CMAKE_C_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_DEBUG
CMAKE_C_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_MINSIZEREL
CMAKE_C_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELEASE
CMAKE_C_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_FLAGS_RELWITHDEBINFO
CMAKE_C_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_C_STANDARD_LIBRARIES
CMAKE_C_STANDARD_LIBRARIES-ADVANCED:INTERNAL=1
//Path to cache edit program executable.
CMAKE_EDIT_COMMAND:INTERNAL=C:/Program Files/CMake/bin/cmake-gui.exe
//Executable file format
CMAKE_EXECUTABLE_FORMAT:INTERNAL=Unknown
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS
CMAKE_EXE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_DEBUG
CMAKE_EXE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
CMAKE_EXE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELEASE
CMAKE_EXE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_BUILD_DATABASE
CMAKE_EXPORT_BUILD_DATABASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_EXPORT_COMPILE_COMMANDS
CMAKE_EXPORT_COMPILE_COMMANDS-ADVANCED:INTERNAL=1
//Name of external makefile project generator.
CMAKE_EXTRA_GENERATOR:INTERNAL=
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Ninja
//Generator instance identifier.
CMAKE_GENERATOR_INSTANCE:INTERNAL=
//Name of generator platform.
CMAKE_GENERATOR_PLATFORM:INTERNAL=
//Name of generator toolset.
CMAKE_GENERATOR_TOOLSET:INTERNAL=
//Source directory with the top level CMakeLists.txt file for this
// project
CMAKE_HOME_DIRECTORY:INTERNAL=T:/projects/whisper.cpp/vcpkg_installed/x64-windows/vcpkg/blds/yasm/src/d25248d823-142afd564c.clean
//ADVANCED property for variable: CMAKE_LINKER
CMAKE_LINKER-ADVANCED:INTERNAL=1
//Name of CMakeLists files to read
CMAKE_LIST_FILE_NAME:INTERNAL=CMakeLists.txt
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS
CMAKE_MODULE_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_DEBUG
CMAKE_MODULE_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELEASE
CMAKE_MODULE_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_MT
CMAKE_MT-ADVANCED:INTERNAL=1
//number of local generators
CMAKE_NUMBER_OF_MAKEFILES:INTERNAL=1
//Platform information initialized
CMAKE_PLATFORM_INFO_INITIALIZED:INTERNAL=1
//noop for ranlib
CMAKE_RANLIB:INTERNAL=:
//ADVANCED property for variable: CMAKE_RC_COMPILER
CMAKE_RC_COMPILER-ADVANCED:INTERNAL=1
CMAKE_RC_COMPILER_WORKS:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS
CMAKE_RC_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_DEBUG
CMAKE_RC_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_MINSIZEREL
CMAKE_RC_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELEASE
CMAKE_RC_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_RC_FLAGS_RELWITHDEBINFO
CMAKE_RC_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//Path to CMake installation.
CMAKE_ROOT:INTERNAL=C:/Program Files/CMake/share/cmake-4.0
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS
CMAKE_SHARED_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_DEBUG
CMAKE_SHARED_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELEASE
CMAKE_SHARED_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_INSTALL_RPATH
CMAKE_SKIP_INSTALL_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_SKIP_RPATH
CMAKE_SKIP_RPATH-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS
CMAKE_STATIC_LINKER_FLAGS-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_DEBUG
CMAKE_STATIC_LINKER_FLAGS_DEBUG-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL
CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELEASE
CMAKE_STATIC_LINKER_FLAGS_RELEASE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO
CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_TOOLCHAIN_FILE
CMAKE_TOOLCHAIN_FILE-ADVANCED:INTERNAL=1
//ADVANCED property for variable: CMAKE_VERBOSE_MAKEFILE
CMAKE_VERBOSE_MAKEFILE-ADVANCED:INTERNAL=1
//Install the dependencies listed in your manifest:
//\n    If this is off, you will have to manually install your dependencies.
//\n    See https://github.com/microsoft/vcpkg/tree/master/docs/specifications/manifests.md
// for more info.
//\n
VCPKG_MANIFEST_INSTALL:INTERNAL=OFF
//ADVANCED property for variable: VCPKG_VERBOSE
VCPKG_VERBOSE-ADVANCED:INTERNAL=1
//Making sure VCPKG_MANIFEST_MODE doesn't change
Z_VCPKG_CHECK_MANIFEST_MODE:INTERNAL=OFF
//Vcpkg root directory
Z_VCPKG_ROOT_DIR:INTERNAL=C:/Program Files/Microsoft Visual Studio/2022/Community/VC/vcpkg

```
</details>

**Additional context**

<details><summary>vcpkg.json</summary>

```
{
  "$schema": "https://raw.githubusercontent.com/microsoft/vcpkg-tool/main/docs/vcpkg.schema.json",
  "name": "whisper-cpp",
  "version": "1.7.4",
  "description": "High-performance inference of OpenAI's Whisper automatic speech recognition (ASR) model",
  "homepage": "https://github.com/ggerganov/whisper.cpp",
  "builtin-baseline": "d5ec528843d29e3a52d745a64b469f810b2cedbf",
  "dependencies": [
    {
      "name": "vcpkg-cmake",
      "host": true
    },
    {
      "name": "vcpkg-cmake-config",
      "host": true
    },
    "mimalloc",
    "tbb",
    "boost-stacktrace",
    "taskflow",
    "libsndfile",
    "sdl2",
    "curl",
    "cpprestsdk"
  ],
  "features": {
    "opencl": {
      "description": "Enable OpenCL support"
    }
  },
  "overrides": [
    {
      "name": "cpprestsdk",
      "version": "2.10.18#4"
    }
  ]
}

```
</details>
