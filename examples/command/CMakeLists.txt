if (WHISPER_SDL2)
    set(TARGET whisper-command)
    add_executable(${TARGET} command.cpp)

    include(${CMAKE_SOURCE_DIR}/cmake/DefaultTargetOptions.cmake)

    target_link_libraries(${TARGET} PRIVATE common common-sdl whisper ${CMAKE_THREAD_LIBS_INIT})

    install(TARGETS ${TARGET} RUNTIME)
endif ()
