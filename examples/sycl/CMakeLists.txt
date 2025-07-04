#  MIT license
#  Copyright (C) 2024 Intel Corporation
#  SPDX-License-Identifier: MIT

if(WHISPER_SYCL AND TARGET ggml-sycl)
    set(TARGET ls-sycl-device)
    add_executable(${TARGET} ls-sycl-device.cpp)

    target_link_libraries(${TARGET}
        PRIVATE
        common
        whisper
        ggml-sycl
        ${CMAKE_THREAD_LIBS_INIT}
    )

    target_include_directories(${TARGET}
        PRIVATE
        ${CMAKE_SOURCE_DIR}/ggml/include
        ${CMAKE_SOURCE_DIR}/ggml/src
    )

    target_compile_features(${TARGET} PRIVATE cxx_std_17)

    # Add SYCL-specific compile definitions
    target_compile_definitions(${TARGET} PRIVATE GGML_USE_SYCL)

    # Add SYCL compiler flags if using DPC++
    if(CMAKE_CXX_COMPILER MATCHES ".*dpcpp.*" OR CMAKE_CXX_COMPILER MATCHES ".*icpx.*")
        target_compile_options(${TARGET} PRIVATE -fsycl)
    endif()

    install(TARGETS ${TARGET} RUNTIME)

    message(STATUS "Building ls-sycl-device utility with SYCL support")
else()
    message(STATUS "SYCL not enabled or ggml-sycl target not found, skipping ls-sycl-device")
endif()
