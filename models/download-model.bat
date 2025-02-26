@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: download-model.bat model_name
    echo Available models: tiny.en, base.en, small.en, medium.en, large-v3
    echo For diarization add -tdrz suffix
    exit /b 1
)

set "MODEL=%~1"
set "MODEL_URL=https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-%MODEL%.bin"
set "OUTPUT_FILE=models\ggml-%MODEL%.bin"

if not exist "models" mkdir models

echo Downloading %MODEL% from Hugging Face...
curl -L "%MODEL_URL%" -o "%OUTPUT_FILE%"

if errorlevel 1 (
    echo Error downloading model
    if exist "%OUTPUT_FILE%" del "%OUTPUT_FILE%"
    exit /b 1
)

echo Model downloaded successfully to: %OUTPUT_FILE%