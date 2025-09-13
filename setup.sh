#!/bin/bash

# 🚀 IPAenject - Setup Script
# Author: IPAenject Team
# Description: Quick setup script for new installations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

print_header() {
    echo ""
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function: Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function: Install Homebrew (macOS)
install_homebrew() {
    if ! command_exists brew; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        print_success "Homebrew installed successfully"
    else
        print_status "Homebrew already installed"
    fi
}

# Function: Install required tools
install_dependencies() {
    print_header "Installing Dependencies"
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        print_status "Detected macOS"
        
        # Install Homebrew if needed
        install_homebrew
        
        # Install tools
        print_status "Installing required tools..."
        brew install ldid
        brew install wget
        brew install curl
        brew install unzip
        brew install zip
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        print_status "Detected Linux"
        
        # Check package manager
        if command_exists apt-get; then
            # Debian/Ubuntu
            sudo apt-get update
            sudo apt-get install -y wget curl unzip zip build-essential
        elif command_exists yum; then
            # RHEL/CentOS
            sudo yum install -y wget curl unzip zip gcc
        elif command_exists pacman; then
            # Arch Linux
            sudo pacman -S wget curl unzip zip gcc
        else
            print_warning "Unknown Linux distribution. Please install dependencies manually."
        fi
        
        # Install ldid (need to compile from source on Linux)
        if ! command_exists ldid; then
            print_status "Installing ldid from source..."
            git clone https://github.com/ProcursusTeam/ldid.git /tmp/ldid
            cd /tmp/ldid
            make
            sudo cp ldid /usr/local/bin/
            cd "$PROJECT_ROOT"
            rm -rf /tmp/ldid
        fi
        
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    print_success "Dependencies installed"
}

# Function: Setup project directories
setup_directories() {
    print_header "Setting Up Project Structure"
    
    # Create necessary directories
    mkdir -p "$PROJECT_ROOT/build"
    mkdir -p "$PROJECT_ROOT/output" 
    mkdir -p "$PROJECT_ROOT/logs"
    
    # Create tweak directories if they don't exist
    mkdir -p "$PROJECT_ROOT/tweaks/media/youtube"
    mkdir -p "$PROJECT_ROOT/tweaks/media/tiktok"
    mkdir -p "$PROJECT_ROOT/tweaks/media/instagram"
    mkdir -p "$PROJECT_ROOT/tweaks/media/spotify"
    mkdir -p "$PROJECT_ROOT/tweaks/social/whatsapp"
    mkdir -p "$PROJECT_ROOT/tweaks/social/telegram"
    mkdir -p "$PROJECT_ROOT/tweaks/social/discord"
    mkdir -p "$PROJECT_ROOT/tweaks/social/snapchat"
    mkdir -p "$PROJECT_ROOT/tweaks/universal/adblock"
    mkdir -p "$PROJECT_ROOT/tweaks/universal/jailbreak-detection"
    mkdir -p "$PROJECT_ROOT/tweaks/universal/flex-patches"
    
    # Make scripts executable
    chmod +x "$PROJECT_ROOT/scripts/"*.sh
    
    print_success "Project directories created"
}

# Function: Install Azule
install_azule() {
    print_header "Installing Azule"
    
    if ! command_exists azule; then
        print_status "Installing Azule iOS app patcher..."
        curl -sSL https://raw.githubusercontent.com/Al4ise/Azule/main/azule.sh | bash
        
        if command_exists azule; then
            print_success "Azule installed successfully"
        else
            print_warning "Azule installation may have failed. You can install it manually later."
        fi
    else
        print_status "Azule already installed"
    fi
}

# Function: Validate installation
validate_installation() {
    print_header "Validating Installation"
    
    local missing_tools=()
    
    # Check required tools
    if ! command_exists unzip; then
        missing_tools+=("unzip")
    fi
    
    if ! command_exists zip; then
        missing_tools+=("zip")
    fi
    
    if ! command_exists curl; then
        missing_tools+=("curl")
    fi
    
    if ! command_exists ldid; then
        missing_tools+=("ldid")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing tools: ${missing_tools[*]}"
        print_error "Please install missing tools manually"
        return 1
    fi
    
    # Check project structure
    if [ ! -d "$PROJECT_ROOT/tweaks" ]; then
        print_error "Tweaks directory not found"
        return 1
    fi
    
    if [ ! -f "$PROJECT_ROOT/scripts/patch.sh" ]; then
        print_error "Patch script not found"
        return 1
    fi
    
    print_success "Installation validation passed"
    return 0
}

# Function: Display usage instructions
show_usage_instructions() {
    print_header "Usage Instructions"
    
    cat << EOF
🎉 IPAenject is now set up and ready to use!

📋 Next Steps:

1. 📁 Add Your Tweaks:
   • Place .dylib files in appropriate directories under tweaks/
   • Update configs/tweak-manifest.json with tweak information

2. 🔧 Configure Apps:
   • Edit configs/app-configs.json to add support for new apps
   • Update .github/workflows/build-app.yml for new app types

3. 🚀 Build Modified Apps:
   • Use GitHub Actions (recommended)
     - Go to your forked repository
     - Navigate to Actions tab
     - Run "Build Modified iOS App" workflow
   
   • Use local scripts (advanced)
     - ./scripts/patch.sh --ipa-url "URL" --app-type youtube
     - ./scripts/resign.sh output/modified.ipa

4. 📱 Install on Device:
   • Use AltStore, Sideloadly, or Xcode
   • See docs/INSTALLATION.md for detailed instructions

📚 Documentation:
   • README.md - Project overview
   • CONTRIBUTING.md - How to contribute
   • docs/INSTALLATION.md - Installation guide

🔗 Useful Commands:
   • Test patch script: ./scripts/patch.sh --help
   • Test resign script: ./scripts/resign.sh --help
   • View logs: tail -f logs/build.log

🆘 Need Help?
   • Check GitHub Issues
   • Read documentation
   • Join community discussions

EOF
    
    print_success "Setup completed successfully! 🎉"
}

# Function: Quick test
run_quick_test() {
    print_header "Running Quick Test"
    
    # Test patch script
    if "$PROJECT_ROOT/scripts/patch.sh" --help > /dev/null 2>&1; then
        print_success "Patch script working"
    else
        print_error "Patch script test failed"
    fi
    
    # Test resign script  
    if "$PROJECT_ROOT/scripts/resign.sh" --help > /dev/null 2>&1; then
        print_success "Resign script working"
    else
        print_error "Resign script test failed"  
    fi
    
    print_success "Quick test completed"
}

# Main function
main() {
    print_header "IPAenject Setup"
    print_status "Starting setup process..."
    
    # Setup steps
    install_dependencies
    setup_directories
    install_azule
    
    if validate_installation; then
        run_quick_test
        show_usage_instructions
    else
        print_error "Setup validation failed. Please check the errors above."
        exit 1
    fi
}

# Parse command line options
SKIP_DEPS=false
QUICK_SETUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --quick)
            QUICK_SETUP=true
            shift
            ;;
        --help)
            cat << EOF
🚀 IPAenject Setup Script

Usage: $0 [OPTIONS]

Options:
    --skip-deps    Skip dependency installation
    --quick        Quick setup (minimal output)
    --help         Show this help message

Examples:
    $0                    # Full setup
    $0 --skip-deps        # Setup without installing dependencies
    $0 --quick            # Quick setup with minimal output

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Execute setup
if [ "$SKIP_DEPS" = true ]; then
    print_warning "Skipping dependency installation"
    setup_directories
    validate_installation
    show_usage_instructions
else
    main
fi
