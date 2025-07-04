# Summon

A powerful bootstrap script that automatically sets up a complete development environment on Linux VMs with minimal configuration. Supports both APT (Debian/Ubuntu) and Pacman (Arch) package managers with automatic detection.

## Features

- **Automatic Package Manager Detection**: Detects and uses either APT or Pacman
- **System Updates**: Updates system packages to latest versions
- **Core Development Tools**: Installs essential development packages
- **Node.js Environment**: Sets up NVM, Node.js LTS, and PM2
- **Python Development**: Installs Python 3 and pip
- **Go Programming**: Installs Go 1.22.4 with proper PATH configuration
- **Enhanced Shell**: Configures Zsh with Oh My Zsh and Powerlevel10k theme
- **Productivity Tools**: Includes modern CLI tools like btop, fzf, exa, and zoxide

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/Hrafngud/summon.git

# Copy to scripts directory
mkdir -p ~/scripts
cp summon/.summon.sh ~/scripts/
chmod +x ~/scripts/.summon.sh

# Add alias to your shell configuration
echo 'alias summon="~/scripts/.summon.sh"' >> ~/.zshrc
# OR for bash users:
echo 'alias summon="~/scripts/.summon.sh"' >> ~/.bashrc

# Reload shell configuration
source ~/.zshrc
# OR for bash:
source ~/.bashrc
```

### Manual Download

```bash
# Download directly
curl -o ~/scripts/.summon.sh https://raw.githubusercontent.com/Hrafngud/summon/main/.summon.sh
chmod +x ~/scripts/.summon.sh

# Add alias
echo 'alias summon="~/scripts/.summon.sh"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

Simply run the command after installation:

```bash
summon
```

The script will automatically:
1. Detect your package manager (APT or Pacman)
2. Update your system
3. Install all development tools and languages
4. Configure your shell environment
5. Display version information for installed tools

## Installed Packages

### System Tools
- **curl**: Command line tool for transferring data
- **git**: Version control system
- **build-essential/base-devel**: Essential build tools and compilers
- **zsh**: Advanced shell with better features than bash
- **btop**: Modern system monitor
- **nethogs**: Network bandwidth monitor
- **fzf**: Fuzzy finder for command line
- **exa**: Modern replacement for ls

### Development Languages
- **Node.js**: JavaScript runtime (LTS version via NVM)
- **Python 3**: Python programming language with pip
- **Go**: Go programming language (version 1.22.4)

### Additional Tools
- **NVM**: Node Version Manager for managing Node.js versions
- **PM2**: Process manager for Node.js applications
- **zoxide**: Smart directory navigation
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Powerlevel10k**: Advanced Zsh theme

## Post-Installation

After running summon, you'll have:

- **Enhanced Terminal**: Zsh with Powerlevel10k theme
- **Smart Navigation**: Use `z <directory>` for quick directory jumping
- **Interactive Directory Search**: Use `zi` to search and navigate directories
- **Better File Listing**: Use `ll` for detailed file listings with git status
- **Development Ready**: All major programming languages installed

## Shell Aliases Added

The script adds these helpful aliases to your `.zshrc`:

```bash
alias z="zoxide cd"              # Quick directory navigation
alias zi="zoxide query -l | fzf | xargs -r zoxide cd"  # Interactive directory search
alias ll="exa -lah --git"        # Enhanced file listing
```

## Requirements

- Linux distribution with either APT or Pacman package manager
- sudo privileges
- Internet connection for downloading packages and tools

## Supported Distributions

- **APT-based**: Ubuntu, Debian, Linux Mint, Elementary OS
- **Pacman-based**: Arch Linux, Manjaro, EndeavourOS, Artix

## Troubleshooting

If you encounter issues:

1. **Permission Denied**: Ensure the script has execute permissions with `chmod +x ~/scripts/.summon.sh`
2. **Package Manager Not Found**: Verify you're running on a supported distribution
3. **Network Issues**: Check your internet connection for downloading packages
4. **Sudo Requirements**: The script requires sudo privileges for package installation

## License

This project is open source and available under the MIT License.
