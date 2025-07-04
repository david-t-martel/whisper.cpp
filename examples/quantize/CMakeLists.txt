set(TARGET whisper-quantize)
add_executable(${TARGET} quantize.cpp)

include(${CMAKE_SOURCE_DIR}/cmake/DefaultTargetOptions.cmake)
set(TARGET ${TARGET})  # For legacy compatibility

target_link_libraries(${TARGET} PRIVATE common whisper ${CMAKE_THREAD_LIBS_INIT})

install(TARGETS ${TARGET} RUNTIME)
