#!/bin/bash

# 🖊️ IPAenject - Re-signing Script
# Author: IPAenject Team
# Description: Re-sign IPA files for iOS installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/output"

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

# Function: Check signing dependencies
check_signing_tools() {
    print_header "Checking Signing Tools"
    
    local missing_tools=()
    
    # Check for ldid (free signing)
    if ! command -v ldid &> /dev/null; then
        print_warning "ldid not found, attempting to install..."
        if command -v brew &> /dev/null; then
            brew install ldid
        else
            missing_tools+=("ldid")
        fi
    fi
    
    # Check for unzip/zip
    if ! command -v unzip &> /dev/null; then
        missing_tools+=("unzip")
    fi
    
    if ! command -v zip &> /dev/null; then
        missing_tools+=("zip")
    fi
    
    # Check for codesign (optional, for Apple Developer signing)
    if command -v codesign &> /dev/null; then
        print_status "codesign available for Developer signing"
    else
        print_status "codesign not available, will use free signing only"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    print_success "Signing tools ready"
}

# Function: Extract IPA for signing
extract_ipa() {
    local ipa_file="$1"
    local extract_dir="$2"
    
    print_status "Extracting IPA: $(basename "$ipa_file")"
    
    # Clean extract directory
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    
    # Extract IPA
    if unzip -q "$ipa_file" -d "$extract_dir"; then
        print_success "IPA extracted successfully"
    else
        print_error "Failed to extract IPA"
        exit 1
    fi
    
    # Find app bundle
    local app_path=$(find "$extract_dir/Payload" -name "*.app" -type d | head -n1)
    
    if [ -z "$app_path" ]; then
        print_error "No .app bundle found in extracted IPA"
        exit 1
    fi
    
    echo "$app_path"
}

# Function: Free signing with ldid
free_sign() {
    local app_path="$1"
    
    print_header "Applying Free Signature"
    print_status "App Bundle: $(basename "$app_path")"
    
    # Create entitlements file
    local entitlements_file="$OUTPUT_DIR/entitlements.plist"
    cat > "$entitlements_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>application-identifier</key>
    <string>*</string>
    <key>get-task-allow</key>
    <true/>
    <key>task_for_pid-allow</key>
    <true/>
</dict>
</plist>
EOF
    
    # Sign main executable
    local app_name=$(basename "$app_path" .app)
    local main_executable="$app_path/$app_name"
    
    if [ -f "$main_executable" ]; then
        print_status "Signing main executable..."
        ldid -S"$entitlements_file" "$main_executable"
        print_success "Main executable signed"
    else
        print_warning "Main executable not found: $main_executable"
    fi
    
    # Sign all embedded frameworks and dylibs
    print_status "Signing embedded libraries..."
    
    # Find and sign frameworks
    if [ -d "$app_path/Frameworks" ]; then
        find "$app_path/Frameworks" -name "*.framework" -type d | while read framework; do
            local framework_name=$(basename "$framework" .framework)
            local framework_exec="$framework/$framework_name"
            
            if [ -f "$framework_exec" ]; then
                print_status "  Signing framework: $framework_name"
                ldid -S "$framework_exec" 2>/dev/null || true
            fi
        done
    fi
    
    # Find and sign dylibs
    find "$app_path" -name "*.dylib" -type f | while read dylib; do
        print_status "  Signing dylib: $(basename "$dylib")"
        ldid -S "$dylib" 2>/dev/null || true
    done
    
    # Sign app bundle itself
    print_status "Signing app bundle..."
    ldid -S"$entitlements_file" "$app_path"
    
    # Clean up entitlements file
    rm -f "$entitlements_file"
    
    print_success "Free signing completed"
}

# Function: Developer signing with codesign
developer_sign() {
    local app_path="$1"
    local identity="$2"
    local provisioning_profile="$3"
    
    print_header "Applying Developer Signature"
    print_status "Identity: $identity"
    
    # Install provisioning profile if provided
    if [ -n "$provisioning_profile" ] && [ -f "$provisioning_profile" ]; then
        print_status "Installing provisioning profile..."
        cp "$provisioning_profile" "$app_path/embedded.mobileprovision"
    fi
    
    # Sign embedded frameworks first
    if [ -d "$app_path/Frameworks" ]; then
        print_status "Signing frameworks..."
        find "$app_path/Frameworks" -name "*.framework" -type d | while read framework; do
            local framework_name=$(basename "$framework" .framework)
            print_status "  Signing: $framework_name"
            codesign --force --sign "$identity" "$framework"
        done
    fi
    
    # Sign dylibs
    find "$app_path" -name "*.dylib" -type f | while read dylib; do
        print_status "  Signing dylib: $(basename "$dylib")"
        codesign --force --sign "$identity" "$dylib"
    done
    
    # Sign main app bundle
    print_status "Signing main app bundle..."
    codesign --force --sign "$identity" --entitlements <(echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>application-identifier</key>
    <string>*</string>
    <key>get-task-allow</key>
    <true/>
</dict>
</plist>') "$app_path"
    
    print_success "Developer signing completed"
}

# Function: Repackage signed app
repackage_ipa() {
    local extract_dir="$1"
    local output_file="$2"
    
    print_header "Repackaging IPA"
    
    cd "$extract_dir"
    
    # Remove existing output file
    rm -f "$output_file"
    
    # Create new IPA
    if zip -r "$output_file" Payload/ > /dev/null 2>&1; then
        print_success "IPA repackaged successfully"
        
        # Display file info
        local file_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)
        local file_size_mb=$((file_size / 1024 / 1024))
        print_status "Output file: $(basename "$output_file") (${file_size_mb}MB)"
    else
        print_error "Failed to repackage IPA"
        exit 1
    fi
    
    # Clean up extraction directory
    cd - > /dev/null
    rm -rf "$extract_dir"
}

# Function: Verify signature
verify_signature() {
    local ipa_file="$1"
    
    print_header "Verifying Signature"
    
    # Extract and check if app is signed
    local temp_dir="$OUTPUT_DIR/verify_temp"
    local app_path=$(extract_ipa "$ipa_file" "$temp_dir")
    
    # Check signature with codesign (if available)
    if command -v codesign &> /dev/null; then
        if codesign -v "$app_path" 2>/dev/null; then
            print_success "Signature verification passed"
        else
            print_warning "Signature verification failed (this is normal for free signing)"
        fi
    else
        print_status "codesign not available, skipping verification"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
}

# Function: Display usage information
show_usage() {
    cat << EOF
🖊️ IPAenject - Re-signing Script

Usage: $0 [OPTIONS] INPUT_IPA

Options:
    --method METHOD         Signing method: free, developer (default: free)
    --identity IDENTITY     Developer identity for codesign (required for developer method)
    --profile PROFILE       Path to provisioning profile (.mobileprovision)
    --output OUTPUT         Output file path (default: signed.ipa)
    --help                  Show this help message

Signing Methods:
    free        - Use ldid for free signing (works with AltStore, Sideloadly)
    developer   - Use codesign with Apple Developer certificate

Examples:
    $0 modified.ipa
    $0 --method free --output my_signed_app.ipa modified.ipa
    $0 --method developer --identity "iPhone Developer" --profile app.mobileprovision modified.ipa

EOF
}

# Main function
main() {
    # Parse command line arguments
    METHOD="free"
    IDENTITY=""
    PROFILE=""
    OUTPUT="signed.ipa"
    INPUT=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --method)
                METHOD="$2"
                shift 2
                ;;
            --identity)
                IDENTITY="$2"
                shift 2
                ;;
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --output)
                OUTPUT="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$INPUT" ]; then
                    INPUT="$1"
                else
                    print_error "Multiple input files specified"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate input
    if [ -z "$INPUT" ]; then
        print_error "No input IPA file specified"
        show_usage
        exit 1
    fi
    
    if [ ! -f "$INPUT" ]; then
        print_error "Input file not found: $INPUT"
        exit 1
    fi
    
    # Validate signing method
    if [ "$METHOD" != "free" ] && [ "$METHOD" != "developer" ]; then
        print_error "Invalid signing method: $METHOD"
        print_error "Supported methods: free, developer"
        exit 1
    fi
    
    # Validate developer signing requirements
    if [ "$METHOD" = "developer" ]; then
        if [ -z "$IDENTITY" ]; then
            print_error "Developer identity required for developer signing"
            exit 1
        fi
        
        if ! command -v codesign &> /dev/null; then
            print_error "codesign not available for developer signing"
            exit 1
        fi
    fi
    
    # Setup output path
    if [[ "$OUTPUT" != /* ]]; then
        OUTPUT="$OUTPUT_DIR/$OUTPUT"
    fi
    
    # Print configuration
    print_header "IPAenject - Re-signing"
    print_status "Input: $INPUT"
    print_status "Output: $OUTPUT"
    print_status "Method: $METHOD"
    if [ -n "$IDENTITY" ]; then
        print_status "Identity: $IDENTITY"
    fi
    if [ -n "$PROFILE" ]; then
        print_status "Profile: $PROFILE"
    fi
    
    # Create output directory
    mkdir -p "$(dirname "$OUTPUT")"
    
    # Execute signing pipeline
    check_signing_tools
    
    # Extract IPA
    local extract_dir="$OUTPUT_DIR/extract_temp"
    local app_path=$(extract_ipa "$INPUT" "$extract_dir")
    
    # Apply signature based on method
    case "$METHOD" in
        free)
            free_sign "$app_path"
            ;;
        developer)
            developer_sign "$app_path" "$IDENTITY" "$PROFILE"
            ;;
    esac
    
    # Repackage IPA
    repackage_ipa "$extract_dir" "$OUTPUT"
    
    # Verify signature
    verify_signature "$OUTPUT"
    
    print_header "Re-signing Complete"
    print_success "Signed IPA available at: $OUTPUT"
    print_success "🖊️ Re-signing completed successfully!"
    
    # Installation instructions
    print_header "Installation Instructions"
    case "$METHOD" in
        free)
            echo -e "${CYAN}Free Signing - Use with:${NC}"
            echo "  • AltStore (recommended)"
            echo "  • Sideloadly"  
            echo "  • Xcode (for development devices)"
            echo ""
            echo -e "${YELLOW}Note: Signature expires in 7 days${NC}"
            ;;
        developer)
            echo -e "${CYAN}Developer Signing - Use with:${NC}"
            echo "  • Direct installation on registered devices"
            echo "  • TestFlight (if uploaded to App Store Connect)"
            echo "  • Enterprise distribution (if enterprise cert)"
            echo ""
            echo -e "${YELLOW}Note: Signature validity depends on certificate type${NC}"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
