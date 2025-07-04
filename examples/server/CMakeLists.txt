set(TARGET whisper-server)
add_executable(${TARGET} server.cpp httplib.h)

include(${CMAKE_SOURCE_DIR}/cmake/DefaultTargetOptions.cmake)
set(TARGET ${TARGET})  # For legacy compatibility

target_link_libraries(${TARGET} PRIVATE common json_cpp whisper ${CMAKE_THREAD_LIBS_INIT})

if (WIN32)
    target_link_libraries(${TARGET} PRIVATE ws2_32)
endif()

install(TARGETS ${TARGET} RUNTIME)
