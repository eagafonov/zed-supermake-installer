# Makefile-based installer for Zed editor

Linux-specific Makefile-based installer for Zed editor with version management capabilities. Automatically detects system architecture, fetches release information from GitHub, downloads specific versions, and manages multiple releases with clean workspace organization.

## Quick Start

```bash
make refresh  # Fetch latest release information
make          # Download, extract, and install Zed
```

This will download the latest stable release and install it to `~/.local/bin/zed`.

## Requirements

- Linux system (x86_64 or aarch64)
- wget, curl, tar, jq
- `~/.local/bin` in your PATH
- Optional: GitHub Personal Access Token (for avoiding API rate limits)

## Installation

### First-time setup
```bash
make refresh  # Fetch release information from GitHub
make all      # Download, extract, and install
```

### Update to latest version
```bash
make refresh  # Get latest release information
make purge    # Clean old version
make all      # Install latest version
```

## Usage

### Basic commands
```bash
make all       # Complete installation (download, unpack, link)
make refresh   # Fetch latest release information from GitHub
make purge     # Remove downloaded files and extracted applications
```

### Individual steps
```bash
make download  # Download the tarball for current version
make unpack    # Extract to version-specific directory
make link      # Create symlink in ~/.local/bin
```

### Release information
```bash
make releases  # List all available stable releases
make latest    # Show the latest release version
```

## How it works

### Version Management
1. Fetches release data from GitHub API (non-prerelease only)
2. Identifies the latest stable release
3. Downloads version-specific tarballs
4. Extracts each version to its own directory (`v1.2.3/zed.app`)
5. Creates a symlink from the version directory to `zed.app`
6. Links `~/.local/bin/zed` to the current installation

### Architecture Detection
Automatically detects and supports:
- x86_64
- aarch64 (ARM64)

### File Organization
```
project/
├── releases.json           # All GitHub releases data
├── latest.json            # Latest release metadata
├── zed-linux-{arch}-{version}.tar.gz  # Version-specific tarball
├── {version}/             # Version-specific directory
│   └── zed.app/          # Extracted application
├── zed.app -> {version}/zed.app  # Symlink to current version
└── ~/.local/bin/zed      # Final symlink to binary
```

## Files created

- `releases.json` - Complete GitHub releases data
- `latest.json` - Latest release metadata
- `zed-linux-{arch}-{version}.tar.gz` - Downloaded release archive
- `{version}/zed.app/` - Version-specific extracted application
- `zed.app/` - Symlink to current version
- `~/.local/bin/zed` - Symlink to the Zed binary

## Error handling

If you see "LATEST_RELEASE is empty", run:
```bash
make refresh
```

This fetches the latest release information needed for downloads.

## Multiple versions

The system supports multiple versions coexisting:
- Each version extracts to its own directory
- Switch versions by changing the `zed.app` symlink
- All versions remain available until manually removed

## Cleanup

```bash
make purge    # Remove current version files
rm -rf v*     # Remove all version directories
rm -f *.json  # Remove release metadata
```

## GitHub API Rate Limiting

GitHub API has rate limits for unauthenticated requests (60 requests per hour). If you encounter rate limiting issues when running `make refresh`, you can authenticate with a GitHub Personal Access Token.

### Setting up authentication

1. Create a GitHub Personal Access Token:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with no scopes (public repository access only requires authentication, not special permissions)

2. Use the token with make:
   ```bash
   make refresh GITHUB_TOKEN=ghp_yourtoken
   ```

3. Or set it as an environment variable:
   ```bash
   export GITHUB_TOKEN=ghp_yourtoken
   make refresh
   ```

4. Best practice - use direnv for automatic environment management:
   ```bash
   # Install direnv (if not already installed)
   # See: https://direnv.net/docs/installation.html

   # Create .envrc file in project directory
   echo 'export GITHUB_TOKEN=ghp_yourtoken' > .envrc

   # Allow direnv to load the file
   direnv allow

   # Token will now be automatically loaded when you cd into this directory
   make refresh
   ```

Note: Never commit your token to version control. Keep it secure and treat it as a password. If using direnv, ensure `.envrc` is in your `.gitignore`.

## Network requirements

- Access to `api.github.com` for release information
- Access to `github.com` for downloading releases
- Uses HTTPS for all network requests

---
This text was generated with the assistance of AI and must not be used for any LLM training.
