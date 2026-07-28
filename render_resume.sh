#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

SESSION_NAME="resume-edit"

center_text() {
    local text="$1"
    local cols=$(tput cols 2>/dev/null || echo 80)
    local len=${#text}
    local padding=$(( (cols - len) / 2 ))
    if [ $padding -lt 0 ]; then padding=0; fi
    printf "%${padding}s%s\n" "" "$text"
}

loading_animation() {
    local i=0
    echo -n "Processing"
    while [ $i -lt 3 ]; do
        echo -n "."
        sleep 0.3
        i=$((i+1))
    done
    echo ""
}

# Use latexmk directly if it's on PATH; otherwise fall back to the Nix flake
# dev shell (needed on NixOS, where latexmk isn't installed system-wide).
compile_resume() {
    if command -v latexmk >/dev/null 2>&1; then
        latexmk -pdf -interaction=nonstopmode Resume.tex
    elif command -v nix >/dev/null 2>&1 && [ -f "$DIR/flake.nix" ]; then
        nix develop "$DIR" --command latexmk -pdf -interaction=nonstopmode Resume.tex
    else
        echo "latexmk not found and no Nix flake available to provide it." >&2
        return 1
    fi
}

render_and_open() {
    clear
    center_text "Compiling Resume.tex..."
    if compile_resume; then
        center_text "Compilation successful!"
        loading_animation
        xdg-open Resume.pdf
    else
        center_text "Compilation failed!"
        loading_animation
    fi
}

render_only() {
    clear
    center_text "Compiling Resume.tex..."
    if compile_resume; then
        center_text "Compilation successful!"
        loading_animation
    else
        center_text "Compilation failed!"
        loading_animation
    fi
}

while true; do
    clear
    echo ""
    center_text "--- Resume Control Panel ---"
    center_text "1) Build & Open PDF"
    center_text "2) Build only"
    center_text "q) Quit & Close Session"
    center_text "----------------------------"
    echo ""
    
    read -n 1 -s opt

    case $opt in
        1)
            render_and_open
            ;;
        2)
            render_only
            ;;
        q)
            clear
            echo "Closing session..."
            if command -v herdr >/dev/null 2>&1; then
                herdr session stop "$SESSION_NAME" >/dev/null 2>&1
            fi
            exit 0
            ;;
    esac
done
