# Resume

A LaTeX-based resume maintained with Git and an automated tmux editing workflow.

## Overview

This repository contains the source files for a professional resume formatted in LaTeX. The project includes a custom tmux-based editing environment designed for efficient iteration: rapid text editing in `nvim` with instant PDF compilation and preview.

## Tools

- **LaTeX (texlive)**: The resume is written in LaTeX for high-quality typesetting. Compilation is handled by `latexmk`, which manages multiple compilation passes to ensure cross-references and bibliographies are correct.
- **nvim (Neovim)**: The primary text editor used for editing `Resume.tex`. It provides syntax highlighting, autocomplete, and a distraction-free coding experience.
- **tmux**: A terminal multiplexer used to orchestrate the editing environment. It manages multiple panes and windows within a single terminal session, allowing for simultaneous editing, AI assistance, and PDF generation.
- **pi**: An AI coding assistant used within the tmux environment for real-time editing suggestions, content generation, and LaTeX troubleshooting.
- **zathura / xdg-open**: Used to render and display the compiled PDF output.

## Automated Workflow

The project includes a custom tmux session orchestrator (`resume-edit.sh`) that sets up a complete editing environment with a single command.

### Prerequisites

- `latexmk` and `texlive` packages installed
- `nvim` (Neovim) installed
- A `pi` session running in tmux (optional, falls back to a standard shell)

### Usage

1. Run `resume-edit` from your terminal.
2. The script will create a new tmux session with the following layout:
   - **Left Pane**: `nvim` with `Resume.tex` open for editing.
   - **Right Pane**: An active `pi` session for AI-assisted editing.
   - **Bottom Pane**: An interactive control panel for compiling and previewing the resume.
3. Edit your resume in the left pane.
4. Use the control panel (bottom pane) to:
   - **1**: Compile the PDF and open it in your default viewer.
   - **2**: Compile the PDF without opening it.
   - **q**: Quit the control panel and close the tmux session.

### Manual Compilation

If you are not using the automated tmux stack, you can compile the document manually:

```bash
latexmk -pdf -interaction=nonstopmode Resume.tex
```

To open the resulting PDF:

```bash
xdg-open Resume.pdf
```

## Structure

| File | Description |
| :--- | :--- |
| `Resume.tex` | The main LaTeX source file for the resume. |
| `render_resume.sh` | Interactive control panel script for the tmux workflow. |
| `resume-edit.sh` | Tmux session orchestrator that sets up the editing environment. |
| `.gitignore` | Excludes LaTeX auxiliary files (`.aux`, `.log`, `.pdf`, etc.) from version control. |
| `README.md` | Project documentation and usage instructions. |

## Privacy Notice

This repository may contain personal information (phone number, email, address) within the `Resume.tex` file. If you are using this as a template, please ensure you update these fields with your own details before sharing or publishing.
