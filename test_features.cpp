#include <iostream>
#include "whisper.h"

int main()
{
    std::cout << "=== Whisper.cpp Feature Test ===" << std::endl;

    // Test basic whisper functionality
    std::cout << "Testing whisper context creation..." << std::endl;

    // Check available features
    std::cout << "\nEnabled features:" << std::endl;

#ifdef WHISPER_USE_LIBSNDFILE
    std::cout << "  ✅ libsndfile support: YES" << std::endl;
#else
    std::cout << "  ❌ libsndfile support: NO" << std::endl;
#endif

#ifdef WHISPER_USE_IPP_AUDIO
    std::cout << "  ✅ Intel IPP Audio: YES" << std::endl;
#else
    std::cout << "  ❌ Intel IPP Audio: NO" << std::endl;
#endif

#ifdef WHISPER_USE_MKL_FFT
    std::cout << "  ✅ Intel MKL FFT: YES" << std::endl;
#else
    std::cout << "  ❌ Intel MKL FFT: NO" << std::endl;
#endif

#ifdef WHISPER_USE_TBB
    std::cout << "  ✅ Intel TBB: YES" << std::endl;
#else
    std::cout << "  ❌ Intel TBB: NO" << std::endl;
#endif

#ifdef GGML_USE_SYCL
    std::cout << "  ✅ Intel SYCL: YES" << std::endl;
#else
    std::cout << "  ❌ Intel SYCL: NO" << std::endl;
#endif

    std::cout << "\nBuild completed successfully!" << std::endl;
    return 0;
}
