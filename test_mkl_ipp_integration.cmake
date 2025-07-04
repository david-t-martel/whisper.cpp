# Test program for Intel MKL/IPP integration
add_executable(test-mkl-ipp-integration test_mkl_ipp_integration.cpp)

target_link_libraries(test-mkl-ipp-integration PRIVATE whisper common)
target_include_directories(test-mkl-ipp-integration PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR})

# Set C++ standard
set_target_properties(test-mkl-ipp-integration PROPERTIES CXX_STANDARD 17)

# Install to bin directory
install(TARGETS test-mkl-ipp-integration DESTINATION bin)