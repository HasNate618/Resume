#!/bin/bash

DIR="/home/nate/Documents/Resume"
SESSION_NAME="$1"
cd "$DIR" || exit 1

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

render_and_open() {
    clear
    center_text "Compiling Resume.tex..."
    if latexmk -pdf -interaction=nonstopmode Resume.tex; then
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
    if latexmk -pdf -interaction=nonstopmode Resume.tex; then
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
            if [ -n "$SESSION_NAME" ]; then
                tmux kill-session -t "$SESSION_NAME"
            fi
            exit 0
            ;;
    esac
done
