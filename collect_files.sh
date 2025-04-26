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

mkdir -p "$OUTPUT_DIR"

process_files() {
    local source_dir="$1"
    local dest_dir="$2"
    local current_depth="$3"
    if [ "$MAX_DEPTH_ENABLED" = true ] && [ "$current_depth" -gt "$MAX_DEPTH" ]; then
        local rel_path="${source_dir#$INPUT_DIR/}"
        local new_dest="$OUTPUT_DIR/$rel_path"
        mkdir -p "$(dirname "$new_dest")"

        for file in "$source_dir"/*; do
            if [ -f "$file" ]; then
                cp "$file" "$new_dest/"
            fi
        done

        for dir in "$source_dir"/*; do
            if [ -d "$dir" ]; then
                local dir_name=$(basename "$dir")
                process_files "$dir" "$dest_dir" $((current_depth + 1))
            fi
        done
        return
    fi

    for file in "$source_dir"/*; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local dest_file="$dest_dir/$filename"

            if [ -f "$dest_file" ]; then
                local base="${filename%.*}"
                local ext="${filename##*.}"
                local counter=1

                if [ "$base" = "$ext" ]; then
                    while [ -f "$dest_dir/${base}${counter}" ]; do
                        ((counter++))
                    done
                    cp "$file" "$dest_dir/${base}${counter}"
                else
                    while [ -f "$dest_dir/${base}${counter}.${ext}" ]; do
                        ((counter++))
                    done
                    cp "$file" "$dest_dir/${base}${counter}.${ext}"
                fi
            else
                cp "$file" "$dest_file"
            fi
        elif [ -d "$file" ]; then
            if [ "$MAX_DEPTH_ENABLED" = true ]; then
                if [ "$current_depth" -lt "$MAX_DEPTH" ]; then
                    local dir_name=$(basename "$file")
                    local new_dest="$dest_dir/$dir_name"
                    mkdir -p "$new_dest"

                    process_files "$file" "$new_dest" $((current_depth + 1))
                else
                    local rel_path="${file#$INPUT_DIR/}"
                    local new_dest="$OUTPUT_DIR/$rel_path"
                    mkdir -p "$new_dest"

                    cp -r "$file"/* "$new_dest/" 2>/dev/null || true
                fi
            else
                process_files "$file" "$dest_dir" $((current_depth + 1))
            fi
        fi
    done
}

process_files "$INPUT_DIR" "$OUTPUT_DIR" 1

echo "копирование файлов завершено."
exit 0

