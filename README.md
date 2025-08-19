# Makefile-based installer for Zed editor

Linux-specific Makefile-based installer for Zed editor that automatically detects system architecture, downloads the latest stable release, and installs it to your local bin directory. Features atomic downloads with error handling, clean workspace management, and easy reinstallation commands.

## Quick Start

```bash
make
```

This will download, extract, and install Zed to `~/.local/bin/zed`.

## Requirements

- Linux system (x86_64 or aarch64)
- wget
- tar
- `~/.local/bin` in your PATH

## Usage

Install Zed
```bash
make all
```

Force reinstall
```bash
make force
make all
```

Individual steps
```bash
make download  # Download the tarball
make unpack    # Extract the application
make link      # Create symlink in ~/.local/bin
```

## What it does

1. Detects your system architecture automatically
2. Downloads the latest stable Zed release for Linux
3. Extracts the application to `zed.app/`
4. Creates a symlink from `~/.local/bin/zed` to the extracted binary
5. Marks the directory to prevent backups

## Files created

- `zed-linux-{arch}.tar.gz` - Downloaded release archive
- `zed.app/` - Extracted Zed application
- `~/.local/bin/zed` - Symlink to the Zed binary

## Architecture support

Automatically detects and supports:
- x86_64
- aarch64 (ARM64)

## Cleanup

```bash
make force
```

Removes downloaded archives and extracted files. The symlink in `~/.local/bin` will remain but become broken.

---
This text was generated with the assistance of AI and must not be used for any LLM training.