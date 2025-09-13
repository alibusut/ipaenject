#!/bin/bash

# 📋 Local Build Example Script
# This script demonstrates how to use the patcher locally

set -e

# Configuration - EDIT THESE VALUES
IPA_URL="https://your-file-hosting.com/your-app.ipa"
APP_TYPE="youtube"
BUNDLE_ID="com.yourname.youtube"
DISPLAY_NAME="YouTube++"
VERSION="1.0.0"
TWEAKS="youtube-reborn,sponsorblock,universal-adblock"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Local Build Example${NC}"
echo -e "${BLUE}=====================${NC}"
echo ""
echo "Configuration:"
echo "  📱 App Type: $APP_TYPE"
echo "  🧩 Tweaks: $TWEAKS"
echo "  📦 Bundle ID: $BUNDLE_ID"
echo "  📝 Display Name: $DISPLAY_NAME"
echo ""

# Check if in project root
if [ ! -f "scripts/patch.sh" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

# Run the patcher
echo -e "${GREEN}▶️ Starting patch process...${NC}"
./scripts/patch.sh \
    --ipa-url "$IPA_URL" \
    --app-type "$APP_TYPE" \
    --tweaks "$TWEAKS" \
    --bundle-id "$BUNDLE_ID" \
    --display-name "$DISPLAY_NAME" \
    --version "$VERSION"

# Check if successful
if [ -f "output/modified.ipa" ]; then
    echo ""
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo "📦 Output: output/modified.ipa"
    
    # Optionally re-sign
    echo ""
    read -p "🖊️ Do you want to re-sign the app? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}▶️ Re-signing app...${NC}"
        ./scripts/resign.sh output/modified.ipa
        echo -e "${GREEN}✅ Re-signing completed!${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}📱 Installation Instructions:${NC}"
    echo "1. Use AltStore, Sideloadly, or Xcode to install"
    echo "2. Install the IPA file: output/signed.ipa (if re-signed) or output/modified.ipa"
    echo "3. Trust the certificate in Settings → General → VPN & Device Management"
    echo ""
    echo -e "${GREEN}🎉 Happy sideloading!${NC}"
    
else
    echo ""
    echo "❌ Build failed. Check the logs above for errors."
    exit 1
fi
