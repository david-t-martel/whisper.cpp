set(TARGET whisper-bench)
add_executable(${TARGET} bench.cpp)

include(${CMAKE_SOURCE_DIR}/cmake/DefaultTargetOptions.cmake)
set(TARGET ${TARGET})  # For legacy compatibility

target_link_libraries(${TARGET} PRIVATE whisper ${CMAKE_THREAD_LIBS_INIT})

install(TARGETS ${TARGET} RUNTIME)
