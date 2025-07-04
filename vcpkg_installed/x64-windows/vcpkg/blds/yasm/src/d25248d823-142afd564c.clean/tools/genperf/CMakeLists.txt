if (NOT _tmp_GENPERF_EXE)
add_executable(genperf
    genperf.c
    perfect.c
    ../../libyasm/phash.c
    ../../libyasm/xmalloc.c
    ../../libyasm/xstrdup.c
    )
set_target_properties(genperf PROPERTIES COMPILE_FLAGS -DYASM_LIB_DECL=)

install(TARGETS genperf RUNTIME DESTINATION bin)
endif()