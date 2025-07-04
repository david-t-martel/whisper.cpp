set(TARGET whisper-cli)
add_executable(${TARGET} cli.cpp)

include(${CMAKE_SOURCE_DIR}/cmake/DefaultTargetOptions.cmake)
set(TARGET ${TARGET})  # For legacy compatibility

target_link_libraries(${TARGET} PRIVATE common whisper ${FFMPEG_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

install(TARGETS ${TARGET} RUNTIME)
