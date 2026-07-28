# Resume

A LaTeX-based resume maintained with Git and an automated herdr editing workflow.

## Overview

This repository contains the source files for a professional resume formatted in LaTeX. The project includes a custom herdr-based editing environment designed for efficient iteration: rapid text editing in `nvim` with instant PDF compilation and preview.

## Tools

- **LaTeX (texlive)**: The resume is written in LaTeX for high-quality typesetting. Compilation is handled by `latexmk`, which manages multiple compilation passes to ensure cross-references and bibliographies are correct.
- **nvim (Neovim)**: The primary text editor used for editing `Resume.tex`. It provides syntax highlighting, autocomplete, and a distraction-free coding experience.
- **herdr**: A terminal workspace manager for AI coding agents, used to orchestrate the editing environment. It manages multiple panes within a single tab, allowing for simultaneous editing, AI assistance, and PDF generation.
- **opencode**: An AI coding assistant used within the herdr environment for real-time editing suggestions, content generation, and LaTeX troubleshooting.
- **zathura / xdg-open**: Used to render and display the compiled PDF output.

## Automated Workflow

The project includes a custom herdr tab orchestrator (`resume-edit.sh`) that sets up a complete editing environment with a single command.

### Prerequisites

- `latexmk` and `texlive` packages installed
- `nvim` (Neovim) installed
- `herdr` and `jq` installed
- `opencode` installed (optional, the control panel still works without it)

#### NixOS

`latexmk`/`texlive` aren't installed system-wide by default. A `flake.nix` is included that provides a dev shell with a full TeX Live distribution and `zathura`:

```bash
nix develop
```

`render_resume.sh` also detects a missing `latexmk` automatically and falls back to `nix develop --command latexmk ...`, so the control panel works even without entering the dev shell manually.

### Usage

1. Run `./resume-edit.sh` from your terminal.
2. The script starts a dedicated `resume-edit` herdr session, separate from your default herdr session, creates a tab in it with the following layout, and attaches to it in the same terminal:
   - **Top-Left Pane**: `nvim` with `Resume.tex` open for editing.
   - **Right Pane**: An active `opencode` session for AI-assisted editing.
   - **Bottom-Left Pane**: An interactive control panel for compiling and previewing the resume.
   Running it again while that tab is still alive just attaches to the existing tab instead of creating a duplicate.
3. Edit your resume in the top-left pane.
4. Use the control panel (bottom-left pane) to:
   - **1**: Compile the PDF and open it in your default viewer.
   - **2**: Compile the PDF without opening it.
   - **q**: Quit the control panel and stop the `resume-edit` herdr session.

### Manual Compilation

If you are not using the automated herdr stack, you can compile the document manually:

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
| `render_resume.sh` | Interactive control panel script for the herdr workflow. |
| `resume-edit.sh` | Herdr session/tab orchestrator that sets up the editing environment. |
| `flake.nix` / `flake.lock` | Nix flake providing a dev shell (TeX Live, `zathura`) for NixOS/Nix users. |
| `.gitignore` | Excludes LaTeX auxiliary files (`.aux`, `.log`, `.pdf`, etc.) from version control. |
| `README.md` | Project documentation and usage instructions. |

## Privacy Notice

This repository may contain personal information (phone number, email, address) within the `Resume.tex` file. If you are using this as a template, please ensure you update these fields with your own details before sharing or publishing.
