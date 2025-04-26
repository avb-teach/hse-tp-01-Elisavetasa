#!/usr/bin/env python3

import os
import shutil
import sys
import argparse
from pathlib import Path


def collect_files(input_dir: str, output_dir: str, max_depth: int = None) -> None:
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    
    output_path.mkdir(parents=True, exist_ok=True)
    
    def process_directory(current_dir: Path, current_depth: int = 1) -> None:
        for item in current_dir.iterdir():
            if item.is_file():
                target_dir = output_path
                if max_depth is not None:
                    rel_path = item.relative_to(input_path)
                    target_dir = output_path / rel_path.parent
                    target_dir.mkdir(parents=True, exist_ok=True)
                
                dest_file = target_dir / item.name
                if dest_file.exists():
                    base = dest_file.stem
                    ext = dest_file.suffix
                    counter = 1
                    
                    while True:
                        if ext:
                            new_name = f"{base}{counter}{ext}"
                        else:
                            new_name = f"{base}{counter}"
                        
                        if not (target_dir / new_name).exists():
                            dest_file = target_dir / new_name
                            break
                        counter += 1
                
                shutil.copy2(item, dest_file)
            
            elif item.is_dir() and (max_depth is None or current_depth < max_depth):
                process_directory(item, current_depth + 1)
            elif item.is_dir() and max_depth is not None and current_depth >= max_depth:
                rel_path = item.relative_to(input_path)
                target_dir = output_path / rel_path
                target_dir.mkdir(parents=True, exist_ok=True)
                shutil.copytree(item, target_dir, dirs_exist_ok=True)
    
    process_directory(input_path)


def main():
    parser = argparse.ArgumentParser(description="собирает файлы из входной директории в выходную директорию.")
    parser.add_argument("input_dir", help="входная директория для сбора файлов")
    parser.add_argument("output_dir", help="выходная директория для копирования файлов")
    parser.add_argument("--max_depth", type=int, help="максимальная глубина обхода", required=False)
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.input_dir):
        print(f"ошибка: входная директория '{args.input_dir}' не существует или это не директория")
        sys.exit(1)
    
    collect_files(args.input_dir, args.output_dir, args.max_depth)
    print("копирование файлов завершено.")


if __name__ == "__main__":
    main()
