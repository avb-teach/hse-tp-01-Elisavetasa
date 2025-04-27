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

if [ $# -eq 4 ]; then
    if [ "$3" = "--max_depth" ] && [[ "$4" =~ ^[0-9]+$ ]]; then
        MAX_DEPTH_ENABLED=true
        MAX_DEPTH="$4"
    else
        usage
    fi
elif [ $# -gt 2 ]; then
    usage
fi

if [ ! -d "$INPUT_DIR" ]; then
    echo "ошибка: входная директория '$INPUT_DIR' не существует или это не директория"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

find "$INPUT_DIR" -type f | while IFS= read -r file; do
    rel_path="${file#"$INPUT_DIR"/}"
    IFS='/' read -r -a seg <<< "$rel_path"
    k=${#seg[@]}

    if $MAX_DEPTH_ENABLED && [ "$k" -gt "$MAX_DEPTH" ]; then
        start_idx=$((k - MAX_DEPTH))
        target_rel=""
        for ((i = start_idx; i < k; i++)); do
            target_rel="$target_rel/${seg[i]}"
        done
        target_rel="${target_rel#/}"
    else
        target_rel="$rel_path"
    fi

    dest="$OUTPUT_DIR/$target_rel"
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir"

    if [ -e "$dest" ]; then
        filename=$(basename "$dest")
        if [[ "$filename" == *.* ]]; then
            name="${filename%.*}"
            ext=".${filename##*.}"
        else
            name="$filename"
            ext=""
        fi
        counter=1
        while [ -e "$dest_dir/${name}${counter}${ext}" ]; do
            ((counter++))
        done
        dest="$dest_dir/${name}${counter}${ext}"
    fi

    cp "$file" "$dest"
done

echo "копирование завершено."
