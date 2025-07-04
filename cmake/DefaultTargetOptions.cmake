# Set the default compile features and properties for a target.
# Can be used in two ways:
# 1. Set TARGET variable then include this file
# 2. Use the apply_default_target_options function

# Function to apply default options to any target
function(apply_default_target_options target_name)
    target_compile_features(${target_name}
        PRIVATE
            cxx_std_17
    )

    set_target_properties(${target_name}
        PROPERTIES
            EXPORT_COMPILE_COMMANDS ON
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    )

    # Intel SYCL-specific options
    if(WHISPER_SYCL AND CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
        target_compile_options(${target_name} PRIVATE
            $<$<COMPILE_LANGUAGE:CXX>:-fsycl>
        )
        target_link_options(${target_name} PRIVATE
            -fsycl
        )

        # Add SYCL definitions
        target_compile_definitions(${target_name} PRIVATE
            WHISPER_USE_SYCL
            GGML_USE_SYCL
        )
    endif()
endfunction()

# Legacy support: if TARGET is set, apply options to it
if(DEFINED TARGET AND TARGET)
    apply_default_target_options(${TARGET})
endif()
