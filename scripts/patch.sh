#!/bin/bash

# 🔨 IPAenject - Main Patching Script
# Author: IPAenject Team
# Description: Advanced IPA patching with tweak injection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
OUTPUT_DIR="$PROJECT_ROOT/output"
TWEAKS_DIR="$PROJECT_ROOT/tweaks"

# Function: Print colored output
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

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function: Check if required tools are installed
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_tools=()
    
    # Check for required tools
    if ! command -v unzip &> /dev/null; then
        missing_tools+=("unzip")
    fi
    
    if ! command -v zip &> /dev/null; then
        missing_tools+=("zip")  
    fi
    
    if ! command -v ldid &> /dev/null; then
        print_warning "ldid not found, attempting to install..."
        if command -v brew &> /dev/null; then
            brew install ldid
        else
            missing_tools+=("ldid")
        fi
    fi
    
    if ! command -v azule &> /dev/null; then
        print_warning "Azule not found, will install during build"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_status "Please install missing tools and retry"
        exit 1
    fi
    
    print_success "All dependencies satisfied"
}

# Function: Setup build environment
setup_build_env() {
    print_header "Setting Up Build Environment"
    
    # Create necessary directories
    mkdir -p "$BUILD_DIR"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$BUILD_DIR/tweaks"
    mkdir -p "$BUILD_DIR/temp"
    
    # Clean previous build artifacts
    if [ -d "$BUILD_DIR/Payload" ]; then
        print_status "Cleaning previous build..."
        rm -rf "$BUILD_DIR/Payload"
    fi
    
    if [ -f "$BUILD_DIR/original.ipa" ]; then
        rm -f "$BUILD_DIR/original.ipa"
    fi
    
    if [ -f "$BUILD_DIR/modified.ipa" ]; then
        rm -f "$BUILD_DIR/modified.ipa"
    fi
    
    print_success "Build environment ready"
}

# Function: Install Azule if not present
install_azule() {
    if ! command -v azule &> /dev/null; then
        print_header "Installing Azule"
        
        # Download and install Azule
        curl -sSL https://raw.githubusercontent.com/Al4ise/Azule/main/azule.sh | bash
        
        if command -v azule &> /dev/null; then
            print_success "Azule installed successfully"
        else
            print_error "Failed to install Azule"
            exit 1
        fi
    else
        print_status "Azule already installed"
    fi
}

# Function: Download IPA file
download_ipa() {
    local ipa_url="$1"
    
    print_header "Downloading IPA"
    print_status "URL: $ipa_url"
    
    if curl -L --fail --max-time 300 -o "$BUILD_DIR/original.ipa" "$ipa_url"; then
        # Verify download
        if [ ! -f "$BUILD_DIR/original.ipa" ]; then
            print_error "Download failed - file not found"
            exit 1
        fi
        
        # Check file size
        local file_size=$(stat -f%z "$BUILD_DIR/original.ipa" 2>/dev/null || stat -c%s "$BUILD_DIR/original.ipa" 2>/dev/null)
        local file_size_mb=$((file_size / 1024 / 1024))
        
        if [ $file_size -lt 1048576 ]; then # Less than 1MB
            print_error "Downloaded file seems too small (${file_size_mb}MB)"
            print_error "This might not be a valid IPA file"
            exit 1
        fi
        
        print_success "IPA downloaded successfully (${file_size_mb}MB)"
    else
        print_error "Failed to download IPA from: $ipa_url"
        exit 1
    fi
}

# Function: Validate IPA file
validate_ipa() {
    print_header "Validating IPA File"
    
    local ipa_file="$BUILD_DIR/original.ipa"
    
    # Check if file exists
    if [ ! -f "$ipa_file" ]; then
        print_error "IPA file not found: $ipa_file"
        exit 1
    fi
    
    # Check if it's a valid zip file
    if ! unzip -t "$ipa_file" &> /dev/null; then
        print_error "IPA file is corrupted or not a valid zip archive"
        exit 1
    fi
    
    # Extract and check for Payload directory
    unzip -q "$ipa_file" -d "$BUILD_DIR/temp/"
    
    if [ ! -d "$BUILD_DIR/temp/Payload" ]; then
        print_error "Invalid IPA structure - Payload directory not found"
        exit 1
    fi
    
    # Find app bundle
    local app_bundle=$(find "$BUILD_DIR/temp/Payload" -name "*.app" -type d | head -n1)
    
    if [ -z "$app_bundle" ]; then
        print_error "No .app bundle found in IPA"
        exit 1
    fi
    
    # Extract app info
    local app_name=$(basename "$app_bundle" .app)
    local info_plist="$app_bundle/Info.plist"
    
    if [ -f "$info_plist" ]; then
        print_success "Found app bundle: $app_name"
        
        # Try to read bundle info (if plutil is available)
        if command -v plutil &> /dev/null; then
            local bundle_id=$(plutil -extract CFBundleIdentifier xml1 -o - "$info_plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' || echo "Unknown")
            local version=$(plutil -extract CFBundleShortVersionString xml1 -o - "$info_plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' || echo "Unknown")
            
            print_status "Bundle ID: $bundle_id"
            print_status "Version: $version"
        fi
    fi
    
    # Clean up temp extraction
    rm -rf "$BUILD_DIR/temp/"
    
    print_success "IPA validation completed"
}

# Function: Collect tweaks based on app type and selection
collect_tweaks() {
    local app_type="$1"
    local tweak_selection="$2"
    
    print_header "Collecting Tweaks"
    print_status "App Type: $app_type"
    print_status "Selection: $tweak_selection"
    
    # Clear existing tweaks
    rm -f "$BUILD_DIR/tweaks/"*
    
    # Function to copy tweaks from a directory
    copy_tweaks_from() {
        local source_dir="$1"
        if [ -d "$source_dir" ]; then
            find "$source_dir" -name "*.dylib" -exec cp {} "$BUILD_DIR/tweaks/" \; 2>/dev/null || true
            find "$source_dir" -name "*.deb" -exec cp {} "$BUILD_DIR/tweaks/" \; 2>/dev/null || true
        fi
    }
    
    # Always include universal tweaks
    print_status "Adding universal tweaks..."
    copy_tweaks_from "$TWEAKS_DIR/universal/adblock"
    copy_tweaks_from "$TWEAKS_DIR/universal/jailbreak-detection"
    copy_tweaks_from "$TWEAKS_DIR/universal/flex-patches"
    
    # Add app-specific tweaks
    case "$app_type" in
        youtube)
            print_status "Adding YouTube tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/media/youtube"
            ;;
        instagram)
            print_status "Adding Instagram tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/social/instagram"
            ;;
        tiktok)
            print_status "Adding TikTok tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/media/tiktok"
            ;;
        whatsapp)
            print_status "Adding WhatsApp tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/social/whatsapp"
            ;;
        telegram)
            print_status "Adding Telegram tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/social/telegram"
            ;;
        spotify)
            print_status "Adding Spotify tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/media/spotify"
            ;;
        snapchat)
            print_status "Adding Snapchat tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/social/snapchat"
            ;;
        discord)
            print_status "Adding Discord tweaks..."
            copy_tweaks_from "$TWEAKS_DIR/social/discord"
            ;;
        custom)
            print_status "Custom app - using universal tweaks only"
            ;;
        *)
            print_warning "Unknown app type: $app_type, using universal tweaks only"
            ;;
    esac
    
    # Handle custom tweak selection
    if [ "$tweak_selection" != "all" ] && [ -n "$tweak_selection" ]; then
        print_status "Processing custom tweak selection..."
        
        # Create temp directory for selected tweaks
        mkdir -p "$BUILD_DIR/selected_tweaks"
        
        # Parse comma-separated tweak list
        IFS=',' read -ra TWEAKS <<< "$tweak_selection"
        for tweak in "${TWEAKS[@]}"; do
            tweak=$(echo "$tweak" | xargs) # trim whitespace
            print_status "Looking for tweak: $tweak"
            
            # Find and copy the specified tweak
            find "$TWEAKS_DIR" -name "$tweak*.dylib" -exec cp {} "$BUILD_DIR/selected_tweaks/" \; 2>/dev/null || true
            find "$TWEAKS_DIR" -name "$tweak*.deb" -exec cp {} "$BUILD_DIR/selected_tweaks/" \; 2>/dev/null || true
        done
        
        # Replace tweaks directory with selected ones
        rm -f "$BUILD_DIR/tweaks/"*
        cp "$BUILD_DIR/selected_tweaks/"* "$BUILD_DIR/tweaks/" 2>/dev/null || true
        rm -rf "$BUILD_DIR/selected_tweaks"
    fi
    
    # Count and list collected tweaks
    local tweak_count=$(find "$BUILD_DIR/tweaks" -name "*.dylib" -o -name "*.deb" | wc -l | xargs)
    
    if [ "$tweak_count" -eq 0 ]; then
        print_warning "No tweaks collected"
    else
        print_success "Collected $tweak_count tweak(s):"
        ls -la "$BUILD_DIR/tweaks/" | grep -E '\.(dylib|deb)$' | awk '{print "  - " $9}'
    fi
}

# Function: Apply patches using Azule
apply_patches() {
    local bundle_id="$1"
    local display_name="$2"
    local version="$3"
    
    print_header "Applying Patches"
    
    cd "$BUILD_DIR"
    
    # Check if we have tweaks to inject
    local tweak_count=$(find tweaks -name "*.dylib" -o -name "*.deb" | wc -l | xargs)
    
    if [ "$tweak_count" -eq 0 ]; then
        print_warning "No tweaks to inject, copying original IPA..."
        cp original.ipa "$OUTPUT_DIR/modified.ipa"
        return 0
    fi
    
    # Prepare Azule command
    local azule_cmd="azule -i original.ipa -o modified.ipa"
    
    # Add display name
    if [ -n "$display_name" ]; then
        azule_cmd="$azule_cmd -n '$display_name'"
    fi
    
    # Add bundle ID
    if [ -n "$bundle_id" ]; then
        azule_cmd="$azule_cmd -b '$bundle_id'"
    fi
    
    # Add version
    if [ -n "$version" ]; then
        azule_cmd="$azule_cmd -v '$version'"
    fi
    
    # Add all tweaks
    for tweak in tweaks/*.{dylib,deb}; do
        if [ -f "$tweak" ]; then
            azule_cmd="$azule_cmd -f '$tweak'"
        fi
    done
    
    print_status "Executing: $azule_cmd"
    
    # Execute Azule command
    if eval "$azule_cmd"; then
        if [ -f "modified.ipa" ]; then
            # Move to output directory
            mv modified.ipa "$OUTPUT_DIR/"
            print_success "Patching completed successfully"
        else
            print_error "Azule completed but no output file found"
            exit 1
        fi
    else
        print_error "Azule patching failed"
        exit 1
    fi
}

# Function: Display usage information
show_usage() {
    cat << EOF
🔨 IPAenject - Patching Script

Usage: $0 [OPTIONS]

Required Options:
    --ipa-url URL           Direct download URL for the IPA file
    --app-type TYPE         Type of app (youtube, instagram, tiktok, etc.)

Optional Options:
    --tweaks TWEAKS         Comma-separated list of specific tweaks (default: all)
    --bundle-id ID          Custom bundle identifier
    --display-name NAME     Custom display name for the app
    --version VERSION       Custom version number
    --help                  Show this help message

Supported App Types:
    youtube, instagram, tiktok, whatsapp, telegram, spotify, snapchat, discord, custom

Examples:
    $0 --ipa-url "https://example.com/app.ipa" --app-type youtube
    $0 --ipa-url "https://example.com/app.ipa" --app-type instagram --bundle-id com.custom.instagram
    $0 --ipa-url "https://example.com/app.ipa" --app-type youtube --tweaks "youtube-reborn,sponsorblock"

EOF
}

# Main function
main() {
    # Parse command line arguments
    IPA_URL=""
    APP_TYPE=""
    TWEAKS="all"
    BUNDLE_ID=""
    DISPLAY_NAME=""
    VERSION="1.0.0"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ipa-url)
                IPA_URL="$2"
                shift 2
                ;;
            --app-type)
                APP_TYPE="$2"
                shift 2
                ;;
            --tweaks)
                TWEAKS="$2"
                shift 2
                ;;
            --bundle-id)
                BUNDLE_ID="$2"
                shift 2
                ;;
            --display-name)
                DISPLAY_NAME="$2"
                shift 2
                ;;
            --version)
                VERSION="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [ -z "$IPA_URL" ] || [ -z "$APP_TYPE" ]; then
        print_error "Missing required arguments"
        show_usage
        exit 1
    fi
    
    # Print configuration
    print_header "IPAenject - iOS App Patcher"
    print_status "IPA URL: $IPA_URL"
    print_status "App Type: $APP_TYPE"
    print_status "Tweaks: $TWEAKS"
    print_status "Bundle ID: ${BUNDLE_ID:-Default}"
    print_status "Display Name: ${DISPLAY_NAME:-Default}"
    print_status "Version: $VERSION"
    
    # Execute patching pipeline
    check_dependencies
    setup_build_env
    install_azule
    download_ipa "$IPA_URL"
    validate_ipa
    collect_tweaks "$APP_TYPE" "$TWEAKS"
    apply_patches "$BUNDLE_ID" "$DISPLAY_NAME" "$VERSION"
    
    print_header "Patching Complete"
    print_success "Modified IPA available at: $OUTPUT_DIR/modified.ipa"
    
    # Display file info
    if [ -f "$OUTPUT_DIR/modified.ipa" ]; then
        local file_size=$(stat -f%z "$OUTPUT_DIR/modified.ipa" 2>/dev/null || stat -c%s "$OUTPUT_DIR/modified.ipa" 2>/dev/null)
        local file_size_mb=$((file_size / 1024 / 1024))
        print_status "File Size: ${file_size_mb}MB"
    fi
    
    print_success "🎉 Build completed successfully!"
}

# Execute main function with all arguments
main "$@"
