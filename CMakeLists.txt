cmake_minimum_required(VERSION 3.10...3.31) # for add_link_options and implicit target directories.
project("whisper.cpp" VERSION 1.7.4 LANGUAGES C CXX)

# Ensure VCPKG_ROOT is set correctly at the top of your file
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED VCPKG_ROOT)
    set(VCPKG_ROOT "$ENV{VCPKG_ROOT}" CACHE STRING "vcpkg root directory")
    message(STATUS "Setting VCPKG_ROOT to ${VCPKG_ROOT}")
endif()

# Make sure the toolchain file is explicitly set
if(DEFINED VCPKG_ROOT AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "")
    message(STATUS "Using vcpkg toolchain file: ${CMAKE_TOOLCHAIN_FILE}")
endif()

# Make sure VCPKG_TARGET_TRIPLET is set if not defined
if(NOT DEFINED VCPKG_TARGET_TRIPLET AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    if(WIN32)
        set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "")
    elseif(APPLE)
        set(VCPKG_TARGET_TRIPLET "x64-osx" CACHE STRING "")
    else()
        set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "")
    endif()

    message(STATUS "Setting VCPKG_TARGET_TRIPLET to ${VCPKG_TARGET_TRIPLET}")
endif()

set(SOVERSION 1)

# Include Intel SYCL configuration if enabled
if(WHISPER_SYCL)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/intel-sycl-config.cmake)
endif()

# Available options
#

# general
option(WHISPER_CCACHE "whisper: use ccache if available" ON)

# debug
option(WHISPER_ALL_WARNINGS "whisper: enable all compiler warnings" ON)
option(WHISPER_ALL_WARNINGS_3RD_PARTY "whisper: enable all compiler warnings in 3rd party libs" OFF)

# build
option(WHISPER_FATAL_WARNINGS "whisper: enable -Werror flag" OFF)

# sanitizers
option(WHISPER_SANITIZE_THREAD "whisper: enable thread sanitizer" OFF)
option(WHISPER_SANITIZE_ADDRESS "whisper: enable address sanitizer" OFF)
option(WHISPER_SANITIZE_UNDEFINED "whisper: enable undefined sanitizer" OFF)

# extra artifacts
option(WHISPER_BUILD_TESTS "whisper: build tests" ${WHISPER_STANDALONE})
option(WHISPER_BUILD_EXAMPLES "whisper: build examples" ${WHISPER_STANDALONE})
option(WHISPER_BUILD_SERVER "whisper: build server example" ${WHISPER_STANDALONE})

# 3rd party libs
option(WHISPER_CURL "whisper: use libcurl to download model from an URL" OFF)
option(WHISPER_CPPRESTSDK "whisper: use C++ REST SDK for HTTP operations" OFF)
option(WHISPER_SDL2 "whisper: support for libSDL2" OFF)
option(WHISPER_LIBSNDFILE "whisper: support for libsndfile for audio I/O" OFF)

if(CMAKE_SYSTEM_NAME MATCHES "Linux")
    option(WHISPER_FFMPEG "whisper: support building and linking with ffmpeg libs (avcodec, swresample, ...)" OFF)
endif()

option(WHISPER_COREML "whisper: enable Core ML framework" OFF)
option(WHISPER_COREML_ALLOW_FALLBACK "whisper: allow non-CoreML fallback" OFF)
option(WHISPER_OPENVINO "whisper: support for OpenVINO" OFF)

# GPU acceleration options
option(WHISPER_CUDA "whisper: support for CUDA GPU acceleration" OFF)
option(WHISPER_SYCL "whisper: support for Intel SYCL GPU acceleration" OFF)

# CUDA Configuration
if(WHISPER_CUDA)
    # Set CUDA toolkit search paths for newer versions
    set(CUDA_TOOLKIT_ROOT_DIR_CANDIDATES
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.9"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.8"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.6"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.5"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.4"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.3"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.2"
        "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.1"
        "/usr/local/cuda-12.9"
        "/usr/local/cuda-12.8"
        "/usr/local/cuda-12.6"
        "/usr/local/cuda"
    )

    # Try to find the newest CUDA version
    foreach(cuda_path ${CUDA_TOOLKIT_ROOT_DIR_CANDIDATES})
        if(EXISTS "${cuda_path}")
            set(CMAKE_CUDA_COMPILER "${cuda_path}/bin/nvcc")
            set(CUDA_TOOLKIT_ROOT_DIR "${cuda_path}")
            message(STATUS "Found CUDA toolkit at: ${cuda_path}")
            break()
        endif()
    endforeach()

    # Require minimum CUDA version that supports modern Visual Studio
    find_package(CUDAToolkit 12.2 REQUIRED)
      if(CUDAToolkit_FOUND)
        message(STATUS "CUDA Toolkit ${CUDAToolkit_VERSION} found at ${CUDAToolkit_ROOT}")

        # Enable CUDA language support
        enable_language(CUDA)

        # Set CUDA compiler flags to allow unsupported compiler if needed
        if(MSVC AND CUDAToolkit_VERSION VERSION_LESS "12.6")
            set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --allow-unsupported-compiler")
            message(STATUS "Added --allow-unsupported-compiler flag for CUDA ${CUDAToolkit_VERSION}")
        endif()
          # Set CUDA architectures for RTX A2000 (compute capability 8.9)
        if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
            set(CMAKE_CUDA_ARCHITECTURES "89")
            message(STATUS "Using CUDA architectures: ${CMAKE_CUDA_ARCHITECTURES} (RTX A2000 optimized)")
        endif()

        # Enable CUDA in ggml
        set(GGML_CUDA ON CACHE BOOL "Enable CUDA backend in ggml" FORCE)

        # Add CUDA definitions
        add_compile_definitions(GGML_USE_CUDA)

        message(STATUS "CUDA support enabled for whisper.cpp")
    else()
        message(FATAL_ERROR "CUDA Toolkit not found. Please install CUDA 12.2 or later.")
    endif()
endif()

# SYCL Configuration
if(WHISPER_SYCL)
    # Intel oneAPI SYCL Configuration
    if(WIN32)
        set(ONEAPI_HINTS
            "C:/Program Files (x86)/Intel/oneAPI"
            "C:/Program Files/Intel/oneAPI"
            "$ENV{ONEAPI_ROOT}"
            "$ENV{INTEL_ONEAPI_ROOT}")
    else()
        set(ONEAPI_HINTS
            "/opt/intel/oneapi"
            "$ENV{ONEAPI_ROOT}"
            "$ENV{INTEL_ONEAPI_ROOT}")
    endif()

    # Find Intel oneAPI DPC++ compiler
    find_program(SYCL_COMPILER
        NAMES icpx dpcpp
        HINTS ${ONEAPI_HINTS}
        PATH_SUFFIXES compiler/latest/bin compiler/latest/windows/bin compiler/latest/linux/bin
        REQUIRED)

    if(SYCL_COMPILER)
        message(STATUS "Found Intel DPC++ compiler: ${SYCL_COMPILER}")

        # Find SYCL library and headers
        find_path(SYCL_INCLUDE_DIR
            NAMES CL/sycl.hpp sycl/sycl.hpp
            HINTS ${ONEAPI_HINTS}
            PATH_SUFFIXES compiler/latest/include compiler/latest/windows/include compiler/latest/linux/include
            REQUIRED)

        if(WIN32)
            find_library(SYCL_LIBRARY
                NAMES sycl sycl7
                HINTS ${ONEAPI_HINTS}
                PATH_SUFFIXES compiler/latest/lib compiler/latest/windows/lib
                REQUIRED)
        else()
            find_library(SYCL_LIBRARY
                NAMES sycl
                HINTS ${ONEAPI_HINTS}
                PATH_SUFFIXES compiler/latest/linux/lib
                REQUIRED)
        endif()

        if(SYCL_INCLUDE_DIR AND SYCL_LIBRARY)
            message(STATUS "Found SYCL include dir: ${SYCL_INCLUDE_DIR}")
            message(STATUS "Found SYCL library: ${SYCL_LIBRARY}")

            # Enable SYCL in ggml
            set(GGML_SYCL ON CACHE BOOL "Enable SYCL backend in ggml" FORCE)

            # Add SYCL definitions
            add_compile_definitions(GGML_USE_SYCL)
            add_compile_definitions(WHISPER_USE_SYCL)

            # Link with Intel oneAPI libraries
            if(TARGET TBB::tbb)
                message(STATUS "Linking SYCL build with TBB")
            endif()

            if(TARGET MKL::MKL)
                message(STATUS "Linking SYCL build with MKL")
            endif()

            message(STATUS "Intel SYCL support enabled for whisper.cpp")
        else()
            message(WARNING "SYCL headers or library not found, disabling SYCL support")
            set(WHISPER_SYCL OFF)
        endif()
    else()
        message(WARNING "Intel DPC++ compiler not found, disabling SYCL support")
        set(WHISPER_SYCL OFF)
    endif()
endif()

# Add new options for additional libraries
option(WHISPER_MIMALLOC "whisper: use mimalloc allocator" OFF)
option(WHISPER_TBB "whisper: use Intel TBB" OFF)
option(WHISPER_MKL "whisper: use Intel MKL" OFF)
option(WHISPER_MKL_FFT "whisper: use Intel MKL for FFT operations" OFF)
option(WHISPER_MKL_BLAS "whisper: use Intel MKL for BLAS operations" OFF)
option(WHISPER_MKL_VML "whisper: use Intel MKL Vector Math Library" OFF)
option(WHISPER_IPP "whisper: use Intel IPP for signal processing" OFF)
option(WHISPER_IPP_AUDIO "whisper: use Intel IPP audio processing functions" OFF)
option(WHISPER_BOOST_STACKTRACE "whisper: use boost stacktrace for error reporting" OFF)
option(WHISPER_CUDA_API_WRAPPERS "whisper: use CUDA API wrappers" OFF)
option(WHISPER_TASKFLOW "whisper: use Taskflow library" OFF)

# Required for relocatable CMake package
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/build-info.cmake)

# override ggml options
set(GGML_CCACHE ${WHISPER_CCACHE})
set(GGML_SANITIZE_THREAD ${WHISPER_SANITIZE_THREAD})
set(GGML_SANITIZE_ADDRESS ${WHISPER_SANITIZE_ADDRESS})
set(GGML_SANITIZE_UNDEFINED ${WHISPER_SANITIZE_UNDEFINED})
set(GGML_ALL_WARNINGS ${WHISPER_ALL_WARNINGS})
set(GGML_FATAL_WARNINGS ${WHISPER_FATAL_WARNINGS})

# Pass CUDA and SYCL options to ggml
set(GGML_CUDA ${WHISPER_CUDA})
set(GGML_SYCL ${WHISPER_SYCL})

#
# build the library
#
if(NOT TARGET ggml)
    add_subdirectory(ggml)

    # ... otherwise assume ggml is added by a parent CMakeLists.txt
endif()

add_subdirectory(src)

# Find required packages
if(WHISPER_MIMALLOC)
    # Attempt to find mimalloc using multiple methods

    # Method 1: Find using traditional CONFIG mode
    find_package(mimalloc CONFIG QUIET PATHS "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/share/mimalloc" NO_DEFAULT_PATH)

    if(NOT mimalloc_FOUND)
        # Method 2: Find using pkg-config
        find_package(PkgConfig QUIET)

        if(PKG_CONFIG_FOUND)
            pkg_check_modules(MIMALLOC QUIET mimalloc)
        endif()
    endif()

    if(NOT mimalloc_FOUND AND NOT MIMALLOC_FOUND)
        # Method 3: Find library and headers directly
        find_library(MIMALLOC_LIBRARY
            NAMES mimalloc mimalloc-static
            PATHS
            "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/lib"
            "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
        )

        find_path(MIMALLOC_INCLUDE_DIR
            NAMES mimalloc.h
            PATHS
            "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/include"
            "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        )

        if(MIMALLOC_LIBRARY AND MIMALLOC_INCLUDE_DIR)
            set(MIMALLOC_FOUND TRUE)
            message(STATUS "Found mimalloc manually: ${MIMALLOC_LIBRARY}")

            # Create a custom imported target if needed
            if(NOT TARGET mimalloc::mimalloc)
                add_library(mimalloc::mimalloc UNKNOWN IMPORTED)
                set_target_properties(mimalloc::mimalloc PROPERTIES
                    IMPORTED_LOCATION "${MIMALLOC_LIBRARY}"
                    INTERFACE_INCLUDE_DIRECTORIES "${MIMALLOC_INCLUDE_DIR}")
            endif()
        else()
            message(WARNING "Could not find mimalloc, will fall back to system allocator")
            set(WHISPER_MIMALLOC OFF)
        endif()
    endif()

    # Define the mimalloc path for DLLs if found
    if(mimalloc_FOUND OR MIMALLOC_FOUND)
        message(STATUS "Using mimalloc allocator")
        add_definitions(-DWHISPER_USE_MIMALLOC)

        if(WIN32)
            # Set the path to mimalloc DLLs
            if(NOT DEFINED MIMALLOC_BIN_DIR)
                if(DEFINED VCPKG_INSTALLED_DIR)
                    set(MIMALLOC_BIN_DIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin"
                        CACHE PATH "Path to mimalloc DLLs")
                elseif(DEFINED VCPKG_ROOT)
                    set(MIMALLOC_BIN_DIR "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/bin"
                        CACHE PATH "Path to mimalloc DLLs")
                endif()
            endif()            # Move DLL handling to after add_subdirectory(src)
            # This will be handled after the whisper target is defined
        endif()
    endif()
endif()

if(WHISPER_TBB)
    # First try to find TBB using the CONFIG mode
    find_package(TBB CONFIG QUIET)

    if(NOT TBB_FOUND)
        # Try to find TBB in Intel oneAPI installation
        if(WIN32)
            set(TBB_HINTS
                "C:/Program Files (x86)/Intel/oneAPI/tbb/latest"
                "C:/Program Files/Intel/oneAPI/tbb/latest"
                "C:/Program Files (x86)/Intel/oneAPI/tbb/2022.1"
                "C:/Program Files/Intel/oneAPI/tbb/2022.1"
                "$ENV{TBBROOT}"
                "$ENV{TBB_ROOT}"
                "$ENV{ONEAPI_ROOT}/tbb/latest")
        else()
            set(TBB_HINTS
                "/opt/intel/oneapi/tbb/latest"
                "$ENV{TBBROOT}"
                "$ENV{TBB_ROOT}")
        endif()

        # Find TBB library (prefer release, then debug)
        find_library(TBB_LIBRARY_RELEASE
            NAMES tbb tbb12
            HINTS ${TBB_HINTS}
            PATH_SUFFIXES lib lib/intel64/vc14 lib/intel64/vc_mt
            QUIET)
        find_library(TBB_LIBRARY_DEBUG
            NAMES tbb_debug tbb12_debug
            HINTS ${TBB_HINTS}
            PATH_SUFFIXES lib lib/intel64/vc14 lib/intel64/vc_mt
            QUIET)

        find_path(TBB_INCLUDE_DIR
            NAMES tbb/tbb.h
            HINTS ${TBB_HINTS}
            PATH_SUFFIXES include
            QUIET)

        if((TBB_LIBRARY_RELEASE OR TBB_LIBRARY_DEBUG) AND TBB_INCLUDE_DIR)
            add_library(TBB::tbb UNKNOWN IMPORTED)

            # Set properties based on available libraries
            if(TBB_LIBRARY_RELEASE)
                set_target_properties(TBB::tbb PROPERTIES
                    IMPORTED_LOCATION_RELEASE "${TBB_LIBRARY_RELEASE}"
                    IMPORTED_LOCATION "${TBB_LIBRARY_RELEASE}")
                message(STATUS "Found TBB Release: ${TBB_LIBRARY_RELEASE}")
            endif()

            if(TBB_LIBRARY_DEBUG)
                set_target_properties(TBB::tbb PROPERTIES
                    IMPORTED_LOCATION_DEBUG "${TBB_LIBRARY_DEBUG}")
                message(STATUS "Found TBB Debug: ${TBB_LIBRARY_DEBUG}")
            endif()

            set_target_properties(TBB::tbb PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${TBB_INCLUDE_DIR}")
            message(STATUS "TBB include: ${TBB_INCLUDE_DIR}")            # Set TBB_FOUND for rest of the script
            set(TBB_FOUND TRUE)
        else()
            message(WARNING "TBB not found in expected locations. Checked:")
            foreach(hint ${TBB_HINTS})
                message(WARNING "  - ${hint}")
            endforeach()
            message(WARNING "TBB not found, disabling WHISPER_TBB")
            set(WHISPER_TBB OFF)
        endif()
    else()
        message(STATUS "Found TBB using CONFIG mode")
    endif()

    if(WHISPER_TBB AND TBB_FOUND)
        add_definitions(-DWHISPER_USE_TBB)
        message(STATUS "TBB integration enabled")
    endif()
endif()

# Intel MKL integration
if(WHISPER_MKL OR WHISPER_MKL_FFT OR WHISPER_MKL_BLAS OR WHISPER_MKL_VML)
    # First try to find MKL using the CONFIG mode
    find_package(MKL CONFIG QUIET)

    if(NOT MKL_FOUND)
        # Try to find MKL in Intel oneAPI installation
        if(WIN32)
            set(MKL_HINTS
                "C:/Program Files (x86)/Intel/oneAPI/mkl/latest"
                "C:/Program Files/Intel/oneAPI/mkl/latest"
                "$ENV{MKLROOT}"
                "$ENV{MKL_ROOT}"
                "$ENV{ONEAPI_ROOT}/mkl/latest")
        else()
            set(MKL_HINTS
                "/opt/intel/oneapi/mkl/latest"
                "$ENV{MKLROOT}"
                "$ENV{MKL_ROOT}")
        endif()

        # Find MKL libraries
        find_library(MKL_CORE_LIBRARY
            NAMES mkl_core
            HINTS ${MKL_HINTS}
            PATH_SUFFIXES lib lib/intel64
            QUIET)
        find_library(MKL_INTEL_LP64_LIBRARY
            NAMES mkl_intel_lp64
            HINTS ${MKL_HINTS}
            PATH_SUFFIXES lib lib/intel64
            QUIET)
        find_library(MKL_TBB_THREAD_LIBRARY
            NAMES mkl_tbb_thread
            HINTS ${MKL_HINTS}
            PATH_SUFFIXES lib lib/intel64
            QUIET)

        find_path(MKL_INCLUDE_DIR
            NAMES mkl.h
            HINTS ${MKL_HINTS}
            PATH_SUFFIXES include
            QUIET)

        if(MKL_CORE_LIBRARY AND MKL_INTEL_LP64_LIBRARY AND MKL_TBB_THREAD_LIBRARY AND MKL_INCLUDE_DIR)
            add_library(MKL::MKL INTERFACE IMPORTED GLOBAL)
            set_target_properties(MKL::MKL PROPERTIES
                INTERFACE_LINK_LIBRARIES "${MKL_INTEL_LP64_LIBRARY};${MKL_CORE_LIBRARY};${MKL_TBB_THREAD_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${MKL_INCLUDE_DIR}")
            message(STATUS "Found MKL libraries:")
            message(STATUS "  Core: ${MKL_CORE_LIBRARY}")
            message(STATUS "  LP64: ${MKL_INTEL_LP64_LIBRARY}")
            message(STATUS "  Threading: ${MKL_TBB_THREAD_LIBRARY}")
            message(STATUS "  Include: ${MKL_INCLUDE_DIR}")
            message(STATUS "Created MKL::MKL target successfully")
            set(MKL_FOUND TRUE)
        else()
            message(WARNING "MKL not found in expected locations. Checked:")
            foreach(hint ${MKL_HINTS})
                message(WARNING "  - ${hint}")
            endforeach()
            message(WARNING "MKL not found, disabling MKL options")
            set(WHISPER_MKL OFF)
            set(WHISPER_MKL_FFT OFF)
            set(WHISPER_MKL_BLAS OFF)
            set(WHISPER_MKL_VML OFF)
        endif()
    else()
        message(STATUS "Found MKL using CONFIG mode")
        # Create a unified MKL::MKL target that matches what we expect
        if(NOT TARGET MKL::MKL)
            # Intel MKL CONFIG mode may provide different target patterns
            # Try to create a unified interface
            set(MKL_TARGETS_FOUND FALSE)
              # Pattern 1: MKL::mkl_* targets
            if(TARGET MKL::mkl_intel_lp64 AND TARGET MKL::mkl_core)
                add_library(MKL::MKL INTERFACE IMPORTED GLOBAL)
                if(TARGET MKL::mkl_tbb_thread)
                    set_target_properties(MKL::MKL PROPERTIES
                        INTERFACE_LINK_LIBRARIES "MKL::mkl_intel_lp64;MKL::mkl_core;MKL::mkl_tbb_thread")
                else()
                    set_target_properties(MKL::MKL PROPERTIES
                        INTERFACE_LINK_LIBRARIES "MKL::mkl_intel_lp64;MKL::mkl_core;MKL::mkl_sequential")
                endif()
                set(MKL_TARGETS_FOUND TRUE)
                message(STATUS "Created MKL::MKL target using MKL::mkl_* targets")
            endif()

            # Pattern 2: Plain mkl_* targets (fallback)
            if(NOT MKL_TARGETS_FOUND AND TARGET mkl_intel_lp64 AND TARGET mkl_core)
                add_library(MKL::MKL INTERFACE IMPORTED GLOBAL)
                if(TARGET mkl_tbb_thread)
                    set_target_properties(MKL::MKL PROPERTIES
                        INTERFACE_LINK_LIBRARIES "mkl_intel_lp64;mkl_core;mkl_tbb_thread")
                else()
                    set_target_properties(MKL::MKL PROPERTIES
                        INTERFACE_LINK_LIBRARIES "mkl_intel_lp64;mkl_core;mkl_sequential")
                endif()
                set(MKL_TARGETS_FOUND TRUE)
                message(STATUS "Created MKL::MKL target using mkl_* targets")
            endif()

            # Pattern 3: Try to use variables set by find_package
            if(NOT MKL_TARGETS_FOUND AND DEFINED MKL_LIBRARIES)
                add_library(MKL::MKL INTERFACE IMPORTED GLOBAL)
                set_target_properties(MKL::MKL PROPERTIES
                    INTERFACE_LINK_LIBRARIES "${MKL_LIBRARIES}")
                if(DEFINED MKL_INCLUDE_DIRS)
                    set_target_properties(MKL::MKL PROPERTIES
                        INTERFACE_INCLUDE_DIRECTORIES "${MKL_INCLUDE_DIRS}")
                endif()
                set(MKL_TARGETS_FOUND TRUE)
                message(STATUS "Created MKL::MKL target using MKL_LIBRARIES")
            endif()

            if(NOT MKL_TARGETS_FOUND)
                message(WARNING "Could not create MKL::MKL target from CONFIG mode. Available targets:")
                get_property(all_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY IMPORTED_TARGETS)
                foreach(target ${all_targets})
                    if(${target} MATCHES ".*[Mm][Kk][Ll].*")
                        message(WARNING "  - ${target}")
                    endif()
                endforeach()
            endif()
        endif()
    endif()

    if(MKL_FOUND)
        if(WHISPER_MKL OR WHISPER_MKL_FFT)
            add_definitions(-DWHISPER_USE_MKL_FFT)
            message(STATUS "Intel MKL FFT integration enabled")
        endif()
        if(WHISPER_MKL OR WHISPER_MKL_BLAS)
            add_definitions(-DWHISPER_USE_MKL_BLAS)
            message(STATUS "Intel MKL BLAS integration enabled")
        endif()
        if(WHISPER_MKL OR WHISPER_MKL_VML)
            add_definitions(-DWHISPER_USE_MKL_VML)
            message(STATUS "Intel MKL Vector Math Library integration enabled")
        endif()
        if(WHISPER_MKL)
            add_definitions(-DWHISPER_USE_MKL)
            message(STATUS "Intel MKL full integration enabled")
        endif()
    endif()
endif()

# Intel IPP integration
if(WHISPER_IPP OR WHISPER_IPP_AUDIO)
    # Try to find IPP in Intel oneAPI installation
    if(WIN32)
        set(IPP_HINTS
            "C:/Program Files (x86)/Intel/oneAPI/ipp/latest"
            "C:/Program Files/Intel/oneAPI/ipp/latest"
            "$ENV{IPPROOT}"
            "$ENV{IPP_ROOT}"
            "$ENV{ONEAPI_ROOT}/ipp/latest")
    else()
        set(IPP_HINTS
            "/opt/intel/oneapi/ipp/latest"
            "$ENV{IPPROOT}"
            "$ENV{IPP_ROOT}")
    endif()

    # Find IPP libraries
    find_library(IPP_CORE_LIBRARY
        NAMES ippcore
        HINTS ${IPP_HINTS}
        PATH_SUFFIXES lib lib/intel64
        QUIET)
    find_library(IPP_S_LIBRARY
        NAMES ipps
        HINTS ${IPP_HINTS}
        PATH_SUFFIXES lib lib/intel64
        QUIET)

    find_path(IPP_INCLUDE_DIR
        NAMES ipp.h
        HINTS ${IPP_HINTS}
        PATH_SUFFIXES include
        QUIET)

    if(IPP_CORE_LIBRARY AND IPP_S_LIBRARY AND IPP_INCLUDE_DIR)
        add_library(IPP::IPP INTERFACE IMPORTED)
        set_target_properties(IPP::IPP PROPERTIES
            INTERFACE_LINK_LIBRARIES "${IPP_CORE_LIBRARY};${IPP_S_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${IPP_INCLUDE_DIR}")
        message(STATUS "Found IPP libraries:")
        message(STATUS "  Core: ${IPP_CORE_LIBRARY}")
        message(STATUS "  Signal Processing: ${IPP_S_LIBRARY}")
        message(STATUS "  Include: ${IPP_INCLUDE_DIR}")
        set(IPP_FOUND TRUE)

        if(WHISPER_IPP OR WHISPER_IPP_AUDIO)
            add_definitions(-DWHISPER_USE_IPP)
            message(STATUS "Intel IPP integration enabled")
        endif()
        if(WHISPER_IPP_AUDIO)
            add_definitions(-DWHISPER_USE_IPP_AUDIO)
            message(STATUS "Intel IPP audio processing enabled")
        endif()
    else()
        message(WARNING "IPP not found in expected locations. Checked:")
        foreach(hint ${IPP_HINTS})
            message(WARNING "  - ${hint}")
        endforeach()
        message(WARNING "IPP not found, disabling IPP options")
        set(WHISPER_IPP OFF)
        set(WHISPER_IPP_AUDIO OFF)
    endif()
endif()

# CUDA Support
if(WHISPER_CUDA)
    # CUDA Toolkit detection is handled by ggml
    # The GGML_CUDA option will enable CUDA support in the ggml backend
    if(GGML_CUDA)
        message(STATUS "CUDA support enabled for whisper.cpp via ggml backend")
        add_definitions(-DWHISPER_USE_CUDA)
    else()
        message(WARNING "CUDA requested but ggml CUDA backend not available")
        set(WHISPER_CUDA OFF)
    endif()
endif()

if(WHISPER_BOOST_STACKTRACE)
    find_path(BOOST_STACKTRACE_INCLUDE_DIR boost/stacktrace.hpp QUIET)
    if(BOOST_STACKTRACE_INCLUDE_DIR)
        include_directories(${BOOST_STACKTRACE_INCLUDE_DIR})
        find_package(Boost QUIET COMPONENTS stacktrace_basic)
        if(Boost_FOUND)
            add_definitions(-DWHISPER_USE_BOOST_STACKTRACE)
        else()
            message(WARNING "Boost stacktrace component not found, disabling WHISPER_BOOST_STACKTRACE")
            set(WHISPER_BOOST_STACKTRACE OFF)
        endif()
    else()
        message(WARNING "Boost stacktrace headers not found, disabling WHISPER_BOOST_STACKTRACE")
        set(WHISPER_BOOST_STACKTRACE OFF)
    endif()
endif()

if(WHISPER_TASKFLOW)
    find_path(TASKFLOW_INCLUDE_DIR taskflow/taskflow.hpp QUIET)
    if(TASKFLOW_INCLUDE_DIR)
        include_directories(${TASKFLOW_INCLUDE_DIR})
        add_definitions(-DWHISPER_USE_TASKFLOW)
    else()
        message(WARNING "Taskflow headers not found, disabling WHISPER_TASKFLOW")
        set(WHISPER_TASKFLOW OFF)
    endif()
endif()

# libsndfile configuration
if(WHISPER_LIBSNDFILE)
    # Try to find libsndfile via vcpkg first (preferred method)
    find_package(SndFile CONFIG QUIET)

    if(SndFile_FOUND)
        message(STATUS "Found libsndfile via vcpkg: ${SndFile_VERSION}")
        set(SNDFILE_FOUND TRUE)
        set(SNDFILE_LIBRARY SndFile::sndfile)
        set(SNDFILE_LIBRARIES SndFile::sndfile)
    else()
        # Fallback to pkg-config
        find_package(PkgConfig QUIET)
        if(PkgConfig_FOUND)
            pkg_check_modules(SNDFILE QUIET sndfile)
        endif()

        if(NOT SNDFILE_FOUND)
            # Manual search for libsndfile
            find_path(SNDFILE_INCLUDE_DIR sndfile.h
                PATHS
                    /usr/include
                    /usr/local/include
                    /opt/homebrew/include
                    "C:/Program Files (x86)/libsndfile/include"
                    "C:/Program Files/libsndfile/include"
                    "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/include"
                PATH_SUFFIXES sndfile
            )

            find_library(SNDFILE_LIBRARY
                NAMES sndfile libsndfile sndfile-1
                PATHS
                    /usr/lib
                    /usr/local/lib
                    /opt/homebrew/lib
                    "C:/Program Files (x86)/libsndfile/lib"
                    "C:/Program Files/libsndfile/lib"
                    "${VCPKG_ROOT}/installed/${VCPKG_TARGET_TRIPLET}/lib"
            )

            if(SNDFILE_INCLUDE_DIR AND SNDFILE_LIBRARY)
                set(SNDFILE_FOUND TRUE)
                message(STATUS "Found libsndfile:")
                message(STATUS "  Include: ${SNDFILE_INCLUDE_DIR}")
                message(STATUS "  Library: ${SNDFILE_LIBRARY}")
            endif()
        endif()
    endif()

    if(SNDFILE_FOUND)
        add_definitions(-DWHISPER_USE_LIBSNDFILE)
        message(STATUS "libsndfile audio I/O support enabled")

        # Also enable IPP audio processing if IPP is available
        if(WHISPER_IPP AND WHISPER_IPP_AUDIO)
            message(STATUS "Intel IPP audio processing will be enabled with libsndfile")
        endif()
    else()
        message(WARNING "libsndfile not found, disabling WHISPER_LIBSNDFILE")
        message(STATUS "To install libsndfile: vcpkg install libsndfile")
        set(WHISPER_LIBSNDFILE OFF)
    endif()
endif()

# curl configuration
if(WHISPER_CURL)
    find_package(CURL CONFIG QUIET)

    if(CURL_FOUND)
        message(STATUS "Found curl via vcpkg: ${CURL_VERSION}")
        add_definitions(-DWHISPER_USE_CURL)
        message(STATUS "curl HTTP support enabled")
    else()
        # Fallback to system curl
        find_package(CURL REQUIRED)
        if(CURL_FOUND)
            message(STATUS "Found system curl: ${CURL_VERSION_STRING}")
            add_definitions(-DWHISPER_USE_CURL)
            message(STATUS "curl HTTP support enabled")
        else()
            message(WARNING "curl not found, disabling WHISPER_CURL")
            message(STATUS "To install curl: vcpkg install curl")
            set(WHISPER_CURL OFF)
        endif()
    endif()
endif()

# cpprestsdk configuration
if(WHISPER_CPPRESTSDK)
    find_package(cpprestsdk CONFIG QUIET)

    if(cpprestsdk_FOUND)
        message(STATUS "Found C++ REST SDK via vcpkg: ${cpprestsdk_VERSION}")
        add_definitions(-DWHISPER_USE_CPPRESTSDK)
        message(STATUS "C++ REST SDK HTTP support enabled")
    else()
        message(WARNING "C++ REST SDK not found, disabling WHISPER_CPPRESTSDK")
        message(STATUS "To install C++ REST SDK: vcpkg install cpprestsdk")
        set(WHISPER_CPPRESTSDK OFF)
    endif()
endif()

if(GGML_CUDA)
    find_package(cuda-api-wrappers CONFIG QUIET)
    # Note: CUDA API wrappers support is optional
endif()

#
# programs, examples and tests
#
if(WHISPER_BUILD_TESTS AND NOT CMAKE_JS_VERSION)
    # include(CTest)
    # add_subdirectory(tests)
endif()

if(WHISPER_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Configure whisper target after it's been defined
if(TARGET whisper)    # Fixed: consolidated target_link_libraries for whisper
    target_link_libraries(whisper
        PRIVATE
        ${CMAKE_DL_LIBS}

        PUBLIC
        # Use the correct mimalloc target (check both FOUND variables)
        $<$<AND:$<BOOL:${WHISPER_MIMALLOC}>,$<OR:$<BOOL:${mimalloc_FOUND}>,$<BOOL:${MIMALLOC_FOUND}>>,$<TARGET_EXISTS:mimalloc::mimalloc>>:mimalloc::mimalloc>
        $<$<AND:$<BOOL:${WHISPER_MIMALLOC}>,$<OR:$<BOOL:${mimalloc_FOUND}>,$<BOOL:${MIMALLOC_FOUND}>>,$<TARGET_EXISTS:mimalloc>,$<NOT:$<TARGET_EXISTS:mimalloc::mimalloc>>>:mimalloc>
        $<$<AND:$<BOOL:${WHISPER_MIMALLOC}>,$<OR:$<BOOL:${mimalloc_FOUND}>,$<BOOL:${MIMALLOC_FOUND}>>,$<TARGET_EXISTS:mimalloc-static>,$<NOT:$<TARGET_EXISTS:mimalloc::mimalloc>>,$<NOT:$<TARGET_EXISTS:mimalloc>>>:mimalloc-static>
        $<$<AND:$<BOOL:${WHISPER_MIMALLOC}>,$<TARGET_EXISTS:mimalloc>>:mimalloc>
        $<$<AND:$<BOOL:${WHISPER_MIMALLOC}>,$<TARGET_EXISTS:mimalloc-static>>:mimalloc-static>

        # TBB
        $<$<BOOL:${WHISPER_TBB}>:$<IF:$<TARGET_EXISTS:TBB::tbb>,TBB::tbb,${TBB_LIBRARY}>>

        # Intel MKL
        $<$<AND:$<OR:$<BOOL:${WHISPER_MKL}>,$<BOOL:${WHISPER_MKL_FFT}>,$<BOOL:${WHISPER_MKL_BLAS}>,$<BOOL:${WHISPER_MKL_VML}>>,$<BOOL:${MKL_FOUND}>>:$<IF:$<TARGET_EXISTS:MKL::MKL>,MKL::MKL,${MKL_INTEL_LP64_LIBRARY} ${MKL_CORE_LIBRARY} ${MKL_TBB_THREAD_LIBRARY}>>

        # Intel IPP
        $<$<AND:$<OR:$<BOOL:${WHISPER_IPP}>,$<BOOL:${WHISPER_IPP_AUDIO}>>,$<BOOL:${IPP_FOUND}>>:$<IF:$<TARGET_EXISTS:IPP::IPP>,IPP::IPP,${IPP_CORE_LIBRARY} ${IPP_S_LIBRARY}>>

        # libsndfile
        $<$<AND:$<BOOL:${WHISPER_LIBSNDFILE}>,$<BOOL:${SNDFILE_FOUND}>>:${SNDFILE_LIBRARY}>

        # curl
        $<$<AND:$<BOOL:${WHISPER_CURL}>,$<BOOL:${CURL_FOUND}>>:CURL::libcurl>

        # cpprestsdk
        $<$<AND:$<BOOL:${WHISPER_CPPRESTSDK}>,$<BOOL:${cpprestsdk_FOUND}>>:cpprestsdk::cpprest>

        # Boost Stacktrace
        $<$<BOOL:${WHISPER_BOOST_STACKTRACE}>:Boost::stacktrace_basic>
    )

    # Make sure target_include_directories are set properly
    target_include_directories(whisper
        PUBLIC
        $<$<BOOL:${WHISPER_BOOST_STACKTRACE}>:${BOOST_STACKTRACE_INCLUDE_DIR}>
        $<$<BOOL:${WHISPER_TASKFLOW}>:${TASKFLOW_INCLUDE_DIR}>

        # Add Intel MKL include directories
        $<$<AND:$<OR:$<BOOL:${WHISPER_MKL}>,$<BOOL:${WHISPER_MKL_FFT}>,$<BOOL:${WHISPER_MKL_BLAS}>,$<BOOL:${WHISPER_MKL_VML}>>,$<BOOL:${MKL_FOUND}>,$<NOT:$<TARGET_EXISTS:MKL::MKL>>>:${MKL_INCLUDE_DIR}>

        # Add Intel IPP include directories
        $<$<AND:$<OR:$<BOOL:${WHISPER_IPP}>,$<BOOL:${WHISPER_IPP_AUDIO}>>,$<BOOL:${IPP_FOUND}>,$<NOT:$<TARGET_EXISTS:IPP::IPP>>>:${IPP_INCLUDE_DIR}>

        # Add libsndfile include directories
        $<$<AND:$<BOOL:${WHISPER_LIBSNDFILE}>,$<BOOL:${SNDFILE_FOUND}>>:${SNDFILE_INCLUDE_DIR}>
        # Add curl include directories
        $<$<AND:$<BOOL:${WHISPER_CURL}>,$<BOOL:${CURL_FOUND}>,$<NOT:$<TARGET_EXISTS:CURL::libcurl>>>:${CURL_INCLUDE_DIRS}>
        # cpprestsdk include directories are handled by the target
        # Add mimalloc include directories if needed and not handled by the target
        $<$<AND:$<BOOL:${WHISPER_MIMALLOC}>,$<NOT:$<TARGET_EXISTS:mimalloc::mimalloc>>,$<NOT:$<TARGET_EXISTS:mimalloc>>,$<NOT:$<TARGET_EXISTS:mimalloc-static>>>:${MIMALLOC_INCLUDE_DIR}>
    )
endif()

#
# install
#
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(WHISPER_BUILD_NUMBER ${BUILD_NUMBER})
set(WHISPER_BUILD_COMMIT ${BUILD_COMMIT})
set(WHISPER_INSTALL_VERSION ${CMAKE_PROJECT_VERSION})

set(WHISPER_INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE PATH "Location of header  files")
set(WHISPER_LIB_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR} CACHE PATH "Location of library files")
set(WHISPER_BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR} CACHE PATH "Location of binary  files")

get_directory_property(WHISPER_TRANSIENT_DEFINES COMPILE_DEFINITIONS)

set_target_properties(whisper PROPERTIES PUBLIC_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/include/whisper.h)
install(TARGETS whisper LIBRARY PUBLIC_HEADER)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/whisper-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/whisper-config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/whisper
    PATH_VARS
    WHISPER_INCLUDE_INSTALL_DIR
    WHISPER_LIB_INSTALL_DIR
    WHISPER_BIN_INSTALL_DIR)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/whisper-version.cmake
    VERSION ${WHISPER_INSTALL_VERSION}
    COMPATIBILITY SameMajorVersion)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/whisper-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/whisper-version.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/whisper)

configure_file(cmake/whisper.pc.in
    "${CMAKE_CURRENT_BINARY_DIR}/whisper.pc"
    @ONLY)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/whisper.pc"    DESTINATION lib/pkgconfig)

# Add test program for Intel MKL/IPP integration (only if Intel features are enabled and examples are built)
if(WHISPER_BUILD_EXAMPLES AND (WHISPER_MKL OR WHISPER_IPP))
    include(test_mkl_ipp_integration.cmake)
endif()
