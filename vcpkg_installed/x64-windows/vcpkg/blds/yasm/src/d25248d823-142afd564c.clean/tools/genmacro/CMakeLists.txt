if (NOT _tmp_GENMACRO_EXE)
add_executable(genmacro
    genmacro.c
    )

install(TARGETS genmacro RUNTIME DESTINATION bin)
endif()