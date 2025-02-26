import json
import csv
import os
import subprocess
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Tuple, Optional, Generator
import io
import numpy as np
import soundfile as sf
from tqdm import tqdm
from diskcache import Cache
import hashlib

# Try to import GPU support
try:
    import cupy as cp
    GPU_AVAILABLE = True
except ImportError:
    GPU_AVAILABLE = False
    print("GPU support not available. Installing CuPy is recommended for better performance.")

# Initialize cache
CACHE_DIR = os.path.join(os.path.dirname(__file__), '.segment_cache')
cache = Cache(CACHE_DIR)

def timestamp_to_milliseconds(timestamp: str) -> int:
    """Convert HH:MM:SS,mmm timestamp to milliseconds"""
    time_obj = datetime.strptime(timestamp.strip(), "%H:%M:%S,%f")
    return int(time_obj.hour * 3600000 + time_obj.minute * 60000 +
              time_obj.second * 1000 + time_obj.microsecond / 1000)

def get_segment_hash(input_wav: str, from_ms: int, to_ms: int) -> str:
    """Generate unique hash for segment caching"""
    content = f"{input_wav}_{from_ms}_{to_ms}".encode()
    return hashlib.md5(content).hexdigest()

def process_batch_gpu(segments: List[np.ndarray], batch_size: int = 32) -> List[np.ndarray]:
    """Process multiple audio segments on GPU in batches"""
    if not GPU_AVAILABLE:
        return segments

    try:
        results = []
        for i in range(0, len(segments), batch_size):
            batch = segments[i:i + batch_size]
            batch_gpu = cp.array([seg for seg in batch])
            batch_gpu = batch_gpu / cp.max(cp.abs(batch_gpu), axis=1, keepdims=True)
            results.extend([cp.asnumpy(seg) for seg in batch_gpu])
            del batch_gpu
            cp.get_default_memory_pool().free_all_blocks()
        return results
    except Exception as e:
        print(f"GPU batch processing failed: {e}. Falling back to CPU.")
        return segments

def extract_segment(segment_info: Tuple[str, dict, str, str, int]) -> Tuple[bool, str]:
    """Extract single audio segment with caching"""
    input_wav, segment, output_dir, wav_base, index = segment_info
    try:
        from_time = segment['timestamps']['from']
        to_time = segment['timestamps']['to']
        from_ms = timestamp_to_milliseconds(from_time)
        to_ms = timestamp_to_milliseconds(to_time)

        output_wav = os.path.join(output_dir,
            f"{wav_base}_{index:04d}_{from_time.replace(':', '-')}_{to_time.replace(':', '-')}.wav")

        # Check cache
        segment_hash = get_segment_hash(input_wav, from_ms, to_ms)
        if segment_hash in cache:
            cached_path = cache[segment_hash]
            if os.path.exists(cached_path):
                if not os.path.exists(output_wav):
                    os.symlink(cached_path, output_wav)
                return True, output_wav

        # Extract segment using FFmpeg
        cmd = ['ffmpeg', '-y']
        if GPU_AVAILABLE:
            cmd.extend(['-hwaccel', 'cuda', '-hwaccel_output_format', 'cuda'])
        cmd.extend([
            '-i', input_wav,
            '-ss', str(from_ms/1000),
            '-t', str((to_ms - from_ms)/1000),
            '-acodec', 'pcm_s16le',
            '-ar', '44100',
            '-bufsize', '2048k',
            output_wav
        ])

        subprocess.run(cmd, check=True, capture_output=True)

        # Cache the result
        cache[segment_hash] = output_wav
        return True, output_wav

    except Exception as e:
        return False, f"Error processing segment {index}: {str(e)}"

def extract_audio_segments(json_file: str, input_wav: str, max_workers: Optional[int] = None,
                         batch_size: int = 10, clear_cache: bool = False):
    """Main processing function with optimizations"""
    if clear_cache:
        cache.clear()

    print(f"GPU Acceleration: {'Enabled' if GPU_AVAILABLE else 'Disabled'}")
    print(f"Cache directory: {CACHE_DIR}")

    # Setup
    max_workers = max_workers or min(32, os.cpu_count() * 2)
    base_name = os.path.splitext(os.path.basename(json_file))[0]
    output_dir = os.path.join(os.path.dirname(json_file), base_name)
    os.makedirs(output_dir, exist_ok=True)

    # Read JSON and prepare segments
    with io.open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    wav_base = os.path.splitext(os.path.basename(input_wav))[0]
    segments = [(input_wav, segment, output_dir, wav_base, i)
                for i, segment in enumerate(data['transcription'], 1)]

    # Write CSV
    csv_file = os.path.join(output_dir, f"{base_name}.csv")
    with io.open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Index', 'From', 'To', 'Text'])
        writer.writerows([
            [i, seg[1]['timestamps']['from'],
             seg[1]['timestamps']['to'],
             seg[1]['text'].strip()]
            for i, seg in enumerate(segments, 1)
        ])

    # Process segments
    successful = failed = 0
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for i in range(0, len(segments), batch_size):
            batch = segments[i:i + batch_size]
            futures.append(executor.submit(extract_segment, batch[0]))

        with tqdm(total=len(segments), desc="Extracting segments") as pbar:
            for future in as_completed(futures):
                success, result = future.result()
                if success:
                    successful += 1
                else:
                    failed += 1
                    print(result)
                pbar.update(1)

    # Cleanup large cache
    if cache.size > 1024**3:
        print("Cleaning cache...")
        cache.clear()

    print(f"\nExtraction complete: {successful} successful, {failed} failed")
    print(f"Cache size: {cache.size / 1024**2:.2f} MB")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='Extract audio segments from JSON transcription')
    parser.add_argument('json_file', help='Input JSON transcription file')
    parser.add_argument('wav_file', help='Input WAV audio file')
    parser.add_argument('--threads', type=int, help='Number of worker threads')
    parser.add_argument('--batch-size', type=int, default=10, help='Batch size for processing')
    parser.add_argument('--clear-cache', action='store_true', help='Clear cache before processing')

    args = parser.parse_args()

    extract_audio_segments(
        args.json_file,
        args.wav_file,
        args.threads,
        args.batch_size,
        args.clear_cache
    )