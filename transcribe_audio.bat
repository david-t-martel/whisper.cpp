@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: transcribe_audio.bat input.m4a [model]
    echo Models available: tiny.en, base.en, small.en, medium.en, large-v3
    exit /b 1
)

set "INPUT_FILE=%~1"
set "MODEL=%~2"
if "%MODEL%"=="" set "MODEL=base.en"

REM Check if model exists, if not download it
if not exist "models\ggml-%MODEL%.bin" (
    echo Model file not found. Downloading %MODEL%...
    if not exist "models" mkdir models
    call build\bin\Release\download-ggml-model.cmd %MODEL%
    if errorlevel 1 (
        echo Error downloading model
        exit /b 1
    )
)

echo Converting audio file...
call convert_audio.bat "%INPUT_FILE%"
if errorlevel 1 (
    echo Error converting audio file
    exit /b 1
)

set "WAV_FILE=%~dpn1.wav"
set "OUTPUT_BASE=%~dpn1"

echo Processing with whisper.cpp...
C:\codedev\whisper.cpp\build\bin\Release\whisper-cli.exe ^
    -m models\ggml-%MODEL%.bin ^
    -f "%WAV_FILE%" ^
    --output-json ^
    --output-txt ^
    --output-words ^
    -of "%OUTPUT_BASE%" ^
    --language auto ^
    --threads 8 ^
    --print-progress ^
    --print-special ^
    --max-len 2048 ^
    --best-of 5 ^
    --translate ^
    --ov-e-device CPU

if errorlevel 1 (
    echo Error: Transcription failed
    exit /b 1
)

echo Transcription complete!
echo Text output: %OUTPUT_BASE%.txt
echo JSON output: %OUTPUT_BASE%.json