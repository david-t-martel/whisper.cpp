@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: convert_audio.bat input.m4a
    exit /b 1
)

set "INPUT_FILE=%~1"
set "OUTPUT_FILE=%~dpn1.wav"

ffmpeg -i "%INPUT_FILE%" -ar 16000 -ac 1 -c:a pcm_s16le "%OUTPUT_FILE%"

echo Converted %INPUT_FILE% to %OUTPUT_FILE%