# Intel SYCL Configuration for whisper.cpp
# This file provides Intel SYCL-specific CMake configurations

# Set minimum CMake version
cmake_minimum_required(VERSION 3.25)

# Intel oneAPI and SYCL configuration
if(WHISPER_SYCL)
    message(STATUS "Configuring Intel SYCL support...")

    # Find Intel oneAPI installation
    if(NOT DEFINED ONEAPI_ROOT)
        if(WIN32)
            set(ONEAPI_ROOT "C:/Program Files (x86)/Intel/oneAPI")
        else()
            set(ONEAPI_ROOT "/opt/intel/oneapi")
        endif()
    endif()

    if(NOT EXISTS ${ONEAPI_ROOT})
        message(FATAL_ERROR "Intel oneAPI not found at ${ONEAPI_ROOT}. Please install Intel oneAPI Base Toolkit or set ONEAPI_ROOT.")
    endif()

    message(STATUS "Intel oneAPI found at: ${ONEAPI_ROOT}")

    # Set up Intel DPC++ compiler
    if(WIN32)
        # Find the latest compiler version
        file(GLOB COMPILER_DIRS "${ONEAPI_ROOT}/compiler/*/")
        list(SORT COMPILER_DIRS)
        list(REVERSE COMPILER_DIRS)
        list(GET COMPILER_DIRS 0 LATEST_COMPILER_DIR)

        set(INTEL_CXX_COMPILER "${LATEST_COMPILER_DIR}/bin/icpx.exe")
        set(INTEL_C_COMPILER "${LATEST_COMPILER_DIR}/bin/icx.exe")

        if(EXISTS ${INTEL_CXX_COMPILER})
            set(CMAKE_CXX_COMPILER ${INTEL_CXX_COMPILER})
            set(CMAKE_C_COMPILER ${INTEL_C_COMPILER})
            message(STATUS "Using Intel DPC++ compiler: ${INTEL_CXX_COMPILER}")
        else()
            message(WARNING "Intel DPC++ compiler not found, falling back to system compiler")
        endif()
    else()
        find_program(INTEL_CXX_COMPILER icpx)
        find_program(INTEL_C_COMPILER icx)

        if(INTEL_CXX_COMPILER)
            set(CMAKE_CXX_COMPILER ${INTEL_CXX_COMPILER})
            set(CMAKE_C_COMPILER ${INTEL_C_COMPILER})
            message(STATUS "Using Intel DPC++ compiler: ${INTEL_CXX_COMPILER}")
        endif()
    endif()
      # Set C++ standard to C++17 (required for SYCL)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)

    # Force Intel DPC++ compiler for SYCL files
    if(WIN32 AND EXISTS ${INTEL_CXX_COMPILER})
        # Override compiler for SYCL files specifically
        set_source_files_properties(
            ${CMAKE_SOURCE_DIR}/ggml/src/ggml-sycl/*.cpp
            PROPERTIES
            COMPILE_FLAGS "/std:c++17"
        )
    endif()

    # Intel SYCL compiler flags
    if(CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
        # Intel DPC++ compiler
        set(SYCL_FLAGS "-fsycl -fsycl-targets=spir64,spir64_gen")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SYCL_FLAGS}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SYCL_FLAGS}")

        # Additional optimization flags for Intel GPU
        if(CMAKE_BUILD_TYPE STREQUAL "Release")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -march=native")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -march=native")
        endif()

        message(STATUS "Applied Intel SYCL compiler flags: ${SYCL_FLAGS}")
    else()
        message(WARNING "Not using Intel DPC++ compiler, SYCL support may be limited")
    endif()

    # Set up Intel oneAPI environment variables
    set(ENV{ONEAPI_ROOT} ${ONEAPI_ROOT})

    # Find and set up Intel MKL
    file(GLOB MKL_DIRS "${ONEAPI_ROOT}/mkl/*/")
    if(MKL_DIRS)
        list(SORT MKL_DIRS)
        list(REVERSE MKL_DIRS)
        list(GET MKL_DIRS 0 LATEST_MKL_DIR)
        set(ENV{MKLROOT} ${LATEST_MKL_DIR})
        list(APPEND CMAKE_PREFIX_PATH ${LATEST_MKL_DIR})
        message(STATUS "Intel MKL found: ${LATEST_MKL_DIR}")
    endif()

    # Find and set up Intel TBB
    file(GLOB TBB_DIRS "${ONEAPI_ROOT}/tbb/*/")
    if(TBB_DIRS)
        list(SORT TBB_DIRS)
        list(REVERSE TBB_DIRS)
        list(GET TBB_DIRS 0 LATEST_TBB_DIR)
        set(ENV{TBBROOT} ${LATEST_TBB_DIR})
        list(APPEND CMAKE_PREFIX_PATH ${LATEST_TBB_DIR})
        message(STATUS "Intel TBB found: ${LATEST_TBB_DIR}")
    endif()

    # Find and set up Intel IPP
    file(GLOB IPP_DIRS "${ONEAPI_ROOT}/ipp/*/")
    if(IPP_DIRS)
        list(SORT IPP_DIRS)
        list(REVERSE IPP_DIRS)
        list(GET IPP_DIRS 0 LATEST_IPP_DIR)
        set(ENV{IPPROOT} ${LATEST_IPP_DIR})
        list(APPEND CMAKE_PREFIX_PATH ${LATEST_IPP_DIR})
        message(STATUS "Intel IPP found: ${LATEST_IPP_DIR}")
    endif()

    # Set up compiler root for older versions
    if(EXISTS ${LATEST_COMPILER_DIR})
        set(ENV{CMPLR_ROOT} ${LATEST_COMPILER_DIR})
    endif()

    # Enable SYCL-specific definitions
    add_compile_definitions(WHISPER_USE_SYCL)
    add_compile_definitions(GGML_USE_SYCL)

    message(STATUS "Intel SYCL configuration complete")
endif()

# Helper function to configure SYCL targets
function(configure_sycl_target target_name)
    if(WHISPER_SYCL AND CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
        target_compile_options(${target_name} PRIVATE
            $<$<COMPILE_LANGUAGE:CXX>:-fsycl>
            $<$<COMPILE_LANGUAGE:CXX>:-fsycl-targets=spir64,spir64_gen>
        )
        target_link_options(${target_name} PRIVATE
            -fsycl
            -fsycl-targets=spir64,spir64_gen
        )

        # Link Intel SYCL runtime
        if(WIN32)
            target_link_libraries(${target_name} PRIVATE sycl)
        else()
            target_link_libraries(${target_name} PRIVATE sycl OpenCL)
        endif()

        message(STATUS "Configured SYCL support for target: ${target_name}")
    endif()
endfunction()
