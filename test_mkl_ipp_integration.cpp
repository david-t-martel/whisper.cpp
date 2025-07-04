#include <iostream>
#include <vector>
#include <chrono>
#include "whisper.h"
#include "examples/common.h"

int main() {
    std::cout << "Testing Intel MKL/IPP Integration with whisper.cpp\n";
    std::cout << "================================================\n\n";

    // Initialize whisper context
    std::cout << "Loading model...\n";
    struct whisper_context_params cparams = whisper_context_default_params();
    cparams.use_gpu = false; // Use CPU with our optimizations
    
    struct whisper_context* ctx = whisper_init_from_file_with_params("models/ggml-base.en.bin", cparams);
    if (ctx == nullptr) {
        std::cerr << "Failed to load model!\n";
        return 1;
    }
    
    std::cout << "Model loaded successfully!\n";
    
    // Load audio file
    std::cout << "Loading audio file...\n";
    std::vector<float> pcmf32;
    std::vector<std::vector<float>> pcmf32s;
    if (!read_wav("samples/jfk.wav", pcmf32, pcmf32s, false)) {
        std::cerr << "Failed to load audio file!\n";
        whisper_free(ctx);
        return 1;
    }
    
    std::cout << "Audio loaded: " << pcmf32.size() << " samples\n";
    
    // Run transcription with timing
    std::cout << "Running transcription with Intel MKL/IPP optimizations...\n";
    
    struct whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
    wparams.language = "en";
    wparams.n_threads = 4;
    wparams.translate = false;
    wparams.print_progress = true;
    wparams.print_timestamps = true;
    
    auto start = std::chrono::high_resolution_clock::now();
    
    int result = whisper_full(ctx, wparams, pcmf32.data(), pcmf32.size());
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    
    if (result != 0) {
        std::cerr << "Transcription failed!\n";
        whisper_free(ctx);
        return 1;
    }
    
    std::cout << "\nTranscription completed in " << duration.count() << " ms\n";
    std::cout << "Results:\n";
    std::cout << "========\n";
    
    const int n_segments = whisper_full_n_segments(ctx);
    for (int i = 0; i < n_segments; ++i) {
        const char* text = whisper_full_get_segment_text(ctx, i);
        const int64_t t0 = whisper_full_get_segment_t0(ctx, i);
        const int64_t t1 = whisper_full_get_segment_t1(ctx, i);
        
        printf("[%6.3fs -> %6.3fs] %s\n", 
               t0 / 100.0, t1 / 100.0, text);
    }
    
    // Print timing statistics
    whisper_print_timings(ctx);
    
    whisper_free(ctx);
    std::cout << "\nTest completed successfully!\n";
    return 0;
}