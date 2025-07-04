if (NOT _tmp_RE2C_EXE)
add_executable(re2c
    main.c
    code.c
    dfa.c
    parser.c
    actions.c
    scanner.c
    mbo_getopt.c
    substr.c
    translate.c
    )

install(TARGETS re2c RUNTIME DESTINATION bin)
endif()