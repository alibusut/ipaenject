#!/bin/bash

# 🛠️ IPAenject - Utility Functions
# Author: IPAenject Team
# Description: Common utility functions used across scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Global configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Function: Print colored output with timestamps
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[$timestamp INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[$timestamp ERROR]${NC} $message"
            ;;
        "DEBUG")
            if [ "${DEBUG:-false}" = "true" ]; then
                echo -e "${PURPLE}[$timestamp DEBUG]${NC} $message"
            fi
            ;;
    esac
}

# Function: Print section header
print_header() {
    echo ""
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# Function: Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function: Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    local description="${3:-file}"
    
    log "INFO" "Downloading $description..."
    log "DEBUG" "URL: $url"
    log "DEBUG" "Output: $output"
    
    if command_exists curl; then
        if curl -L --fail --progress-bar -o "$output" "$url"; then
            log "SUCCESS" "Downloaded $description successfully"
            return 0
        else
            log "ERROR" "Failed to download $description using curl"
            return 1
        fi
    elif command_exists wget; then
        if wget --progress=bar:force:noscroll -O "$output" "$url"; then
            log "SUCCESS" "Downloaded $description successfully"
            return 0
        else
            log "ERROR" "Failed to download $description using wget"
            return 1
        fi
    else
        log "ERROR" "Neither curl nor wget is available"
        return 1
    fi
}

# Function: Get file size in human readable format
get_file_size() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "0B"
        return
    fi
    
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    
    if [ $size -gt 1073741824 ]; then
        echo "$(($size / 1024 / 1024 / 1024))GB"
    elif [ $size -gt 1048576 ]; then
        echo "$(($size / 1024 / 1024))MB"
    elif [ $size -gt 1024 ]; then
        echo "$(($size / 1024))KB"
    else
        echo "${size}B"
    fi
}

# Function: Validate URL
validate_url() {
    local url="$1"
    
    if [[ ! "$url" =~ ^https?:// ]]; then
        log "ERROR" "Invalid URL format: $url"
        return 1
    fi
    
    # Test URL accessibility
    if command_exists curl; then
        if curl --output /dev/null --silent --head --fail --max-time 10 "$url"; then
            return 0
        else
            log "ERROR" "URL is not accessible: $url"
            return 1
        fi
    else
        log "WARNING" "Cannot validate URL accessibility (curl not available)"
        return 0
    fi
}

# Function: Create directory with logging
create_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        if mkdir -p "$dir"; then
            log "DEBUG" "Created directory: $dir"
        else
            log "ERROR" "Failed to create directory: $dir"
            return 1
        fi
    else
        log "DEBUG" "Directory already exists: $dir"
    fi
}

# Function: Clean up temporary files
cleanup_temp() {
    local temp_pattern="$1"
    
    if [ -z "$temp_pattern" ]; then
        temp_pattern="*temp*"
    fi
    
    log "INFO" "Cleaning up temporary files..."
    
    find "${TMPDIR:-/tmp}" -name "$temp_pattern" -type f -mtime +1 -delete 2>/dev/null || true
    find "${PROJECT_ROOT}/build" -name "$temp_pattern" -type f -delete 2>/dev/null || true
    
    log "SUCCESS" "Temporary files cleaned"
}

# Function: Verify IPA file structure
verify_ipa_structure() {
    local ipa_file="$1"
    local temp_dir="${2:-$(mktemp -d)}"
    
    log "INFO" "Verifying IPA structure..."
    
    # Extract IPA to temp directory
    if ! unzip -q "$ipa_file" -d "$temp_dir"; then
        log "ERROR" "Failed to extract IPA file"
        return 1
    fi
    
    # Check for Payload directory
    if [ ! -d "$temp_dir/Payload" ]; then
        log "ERROR" "IPA missing Payload directory"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Check for app bundle
    local app_bundle=$(find "$temp_dir/Payload" -name "*.app" -type d | head -n1)
    if [ -z "$app_bundle" ]; then
        log "ERROR" "No .app bundle found in IPA"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Check for Info.plist
    if [ ! -f "$app_bundle/Info.plist" ]; then
        log "ERROR" "Info.plist missing from app bundle"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract app information
    local app_name=$(basename "$app_bundle" .app)
    log "SUCCESS" "Valid IPA structure found"
    log "INFO" "App bundle: $app_name"
    
    # Clean up if temp directory was created by us
    if [ "$temp_dir" = "$(mktemp -d)" ]; then
        rm -rf "$temp_dir"
    fi
    
    return 0
}

# Function: Get app bundle identifier
get_bundle_id() {
    local app_path="$1"
    local info_plist="$app_path/Info.plist"
    
    if [ ! -f "$info_plist" ]; then
        echo "unknown"
        return 1
    fi
    
    if command_exists plutil; then
        plutil -extract CFBundleIdentifier xml1 -o - "$info_plist" 2>/dev/null | \
        sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' || echo "unknown"
    elif command_exists defaults; then
        defaults read "$info_plist" CFBundleIdentifier 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# Function: Get app version
get_app_version() {
    local app_path="$1"
    local info_plist="$app_path/Info.plist"
    
    if [ ! -f "$info_plist" ]; then
        echo "unknown"
        return 1
    fi
    
    if command_exists plutil; then
        plutil -extract CFBundleShortVersionString xml1 -o - "$info_plist" 2>/dev/null | \
        sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' || echo "unknown"
    elif command_exists defaults; then
        defaults read "$info_plist" CFBundleShortVersionString 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# Function: Check disk space
check_disk_space() {
    local required_mb="$1"
    local path="${2:-.}"
    
    if [ -z "$required_mb" ]; then
        required_mb=500 # Default 500MB
    fi
    
    local available_kb=$(df "$path" | tail -1 | awk '{print $4}')
    local available_mb=$((available_kb / 1024))
    
    if [ $available_mb -lt $required_mb ]; then
        log "ERROR" "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
        return 1
    else
        log "INFO" "Disk space check passed. Available: ${available_mb}MB"
        return 0
    fi
}

# Function: Install tool via Homebrew
install_via_brew() {
    local tool="$1"
    
    if ! command_exists brew; then
        log "ERROR" "Homebrew is not installed"
        return 1
    fi
    
    log "INFO" "Installing $tool via Homebrew..."
    
    if brew install "$tool"; then
        log "SUCCESS" "$tool installed successfully"
        return 0
    else
        log "ERROR" "Failed to install $tool"
        return 1
    fi
}

# Function: Generate build info
generate_build_info() {
    local output_file="$1"
    local app_type="$2"
    local tweaks="$3"
    
    cat > "$output_file" << EOF
🚀 IPAenject - Build Information
===============================================

📅 Build Date: $(date '+%Y-%m-%d %H:%M:%S %Z')
📱 App Type: $app_type
🧩 Tweaks Applied: $tweaks
🔧 Builder Version: $(cat "$PROJECT_ROOT/VERSION" 2>/dev/null || echo "dev")
🖥️  Build Host: $(uname -s) $(uname -r)
📂 Project: $(basename "$PROJECT_ROOT")

🔗 Repository: https://github.com/username/ipaenject
📖 Documentation: https://github.com/username/ipaenject/wiki

⚠️ IMPORTANT NOTES:
• This modified app is for personal use only
• Ensure you own the original application
• Use proper sideloading tools for installation
• Signature may expire based on certificate type

📱 Installation Methods:
• AltStore (Free signing - 7 days)
• Sideloadly (Free signing - 7 days)  
• Xcode (Development - 7 days)
• Enterprise Certificate (1 year)
• Developer Certificate (1 year)

🛠️ Troubleshooting:
• If app doesn't install: Check certificate trust
• If app crashes: Check iOS compatibility
• If features missing: Verify tweak compatibility

EOF
}

# Function: Progress bar
show_progress() {
    local current="$1"
    local total="$2" 
    local description="${3:-Progress}"
    
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${BLUE}$description:${NC} ["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] %d%%" $percent
    
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Function: Confirm action
confirm_action() {
    local message="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        printf "${YELLOW}$message [Y/n]:${NC} "
    else
        printf "${YELLOW}$message [y/N]:${NC} "
    fi
    
    read -r response
    
    case $response in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        [nN][oO]|[nN])
            return 1
            ;;
        "")
            if [ "$default" = "y" ]; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Function: Parse semantic version
parse_version() {
    local version="$1"
    
    if [[ $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
        return 0
    else
        echo "0 0 0"
        return 1
    fi
}

# Function: Compare versions  
version_compare() {
    local version1="$1"
    local version2="$2"
    
    read -r v1_major v1_minor v1_patch <<< $(parse_version "$version1")
    read -r v2_major v2_minor v2_patch <<< $(parse_version "$version2")
    
    if [ $v1_major -gt $v2_major ]; then
        echo 1
    elif [ $v1_major -lt $v2_major ]; then
        echo -1
    elif [ $v1_minor -gt $v2_minor ]; then
        echo 1
    elif [ $v1_minor -lt $v2_minor ]; then
        echo -1
    elif [ $v1_patch -gt $v2_patch ]; then
        echo 1
    elif [ $v1_patch -lt $v2_patch ]; then
        echo -1
    else
        echo 0
    fi
}

# Function: Setup environment
setup_environment() {
    log "INFO" "Setting up build environment..."
    
    # Create necessary directories
    create_directory "$PROJECT_ROOT/build"
    create_directory "$PROJECT_ROOT/output"
    create_directory "$PROJECT_ROOT/logs"
    
    # Check disk space (500MB minimum)
    check_disk_space 500 "$PROJECT_ROOT"
    
    # Set up logging
    exec > >(tee -a "$PROJECT_ROOT/logs/build.log")
    exec 2>&1
    
    log "SUCCESS" "Environment setup complete"
}

# Export functions for use in other scripts
export -f log print_header command_exists download_file get_file_size
export -f validate_url create_directory cleanup_temp verify_ipa_structure
export -f get_bundle_id get_app_version check_disk_space install_via_brew
export -f generate_build_info show_progress confirm_action setup_environment
