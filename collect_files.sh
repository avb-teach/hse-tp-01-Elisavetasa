#!/bin/bash

usage() {
    echo "использование: $0 <входная_директория> <выходная_директория> [--max_depth <глубина>]"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH_ENABLED=false
MAX_DEPTH=0

if [ $# -gt 2 ]; then
    if [ "$3" == "--max_depth" ] && [ $# -eq 4 ]; then
        MAX_DEPTH_ENABLED=true
        MAX_DEPTH="$4"
        if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
            echo "ошибка: --max_depth должен быть положительным числом"
            exit 1
        fi
    else
        usage
    fi
fi

if [ ! -d "$INPUT_DIR" ]; then
    echo "ошибка: входная директория '$INPUT_DIR' не существует или это не директория"
    exit 1
fi

if [ "$MAX_DEPTH_ENABLED" = true ]; then
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR" --max_depth "$MAX_DEPTH"
else
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR"
fi