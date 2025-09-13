# 🔧 Advanced Usage Guide

This guide covers advanced topics for power users and developers who want to customize and extend Universal iOS App Patcher.

## 📋 Table of Contents

- [Advanced Workflow Configuration](#advanced-workflow-configuration)
- [Custom Signing Certificates](#custom-signing-certificates)
- [Local Development Setup](#local-development-setup)
- [Creating Custom Tweaks](#creating-custom-tweaks)
- [Batch Processing](#batch-processing)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## 🔄 Advanced Workflow Configuration

### Custom Workflow Triggers

Create scheduled builds or trigger builds based on repository events:

```yaml
# .github/workflows/scheduled-build.yml
name: Scheduled YouTube Build

on:
  schedule:
    # Build every Sunday at 2 AM UTC
    - cron: '0 2 * * 0'
  
  # Manual trigger with custom parameters
  workflow_dispatch:
    inputs:
      force_update:
        description: 'Force update all tweaks'
        required: false
        default: 'false'
        type: boolean

jobs:
  scheduled_build:
    runs-on: macos-latest
    steps:
      # Your build steps here
```

### Matrix Builds

Build multiple app configurations simultaneously:

```yaml
strategy:
  matrix:
    app_config:
      - { type: 'youtube', tweaks: 'youtube-reborn,sponsorblock' }
      - { type: 'instagram', tweaks: 'instagram-plus,instasave' }
      - { type: 'tiktok', tweaks: 'tiktok-plus' }

steps:
  - name: Build ${{ matrix.app_config.type }}
    run: |
      ./scripts/patch.sh \
        --app-type ${{ matrix.app_config.type }} \
        --tweaks ${{ matrix.app_config.tweaks }}
```

### Conditional Builds

Build only when specific files change:

```yaml
on:
  push:
    paths:
      - 'tweaks/**'
      - 'configs/**'
      - '.github/workflows/**'
```

## 🔐 Custom Signing Certificates

### Enterprise Certificate Setup

For organizations with Apple Enterprise Developer accounts:

```bash
# Store certificate in GitHub Secrets as base64
cat enterprise.p12 | base64 | pbcopy

# In workflow:
- name: Setup Enterprise Signing
  env:
    ENTERPRISE_CERT: ${{ secrets.ENTERPRISE_CERT_BASE64 }}
    CERT_PASSWORD: ${{ secrets.ENTERPRISE_CERT_PASSWORD }}
  run: |
    echo "$ENTERPRISE_CERT" | base64 -d > cert.p12
    security import cert.p12 -k ~/Library/Keychains/login.keychain -P "$CERT_PASSWORD"
    ./scripts/resign.sh --method enterprise --identity "iPhone Distribution: Company Name"
```

### Custom Provisioning Profiles

```bash
# Add provisioning profile
./scripts/resign.sh \
  --method developer \
  --identity "iPhone Developer: Your Name" \
  --profile "path/to/profile.mobileprovision" \
  modified.ipa
```

## 💻 Local Development Setup

### Development Environment

Set up a complete local development environment:

```bash
# Clone and setup
git clone https://github.com/yourusername/ios-app-patcher
cd ios-app-patcher

# Run setup script
./setup.sh

# Verify installation
./scripts/patch.sh --help
./scripts/resign.sh --help
```

### Environment Variables

Configure persistent settings:

```bash
# ~/.bashrc or ~/.zshrc
export IOS_PATCHER_ROOT="/path/to/ios-app-patcher"
export DEFAULT_BUNDLE_PREFIX="com.yourname"
export DEFAULT_SIGNING_METHOD="free"

# Use in scripts
./scripts/patch.sh \
  --bundle-id "$DEFAULT_BUNDLE_PREFIX.youtube" \
  --ipa-url "https://your-host.com/youtube.ipa" \
  --app-type youtube
```

### Debug Mode

Enable detailed logging and debugging:

```bash
# Enable debug mode
export DEBUG=true

# Run with verbose output
./scripts/patch.sh --ipa-url "URL" --app-type youtube -v

# Check logs
tail -f logs/build.log
```

## 🧩 Creating Custom Tweaks

### Tweak Development with Theos

Set up Theos for tweak development:

```bash
# Install Theos (macOS)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# Create new tweak project
$THEOS/bin/nic.pl
# Select "iphone/tweak" template

# Build tweak
make package
```

### Tweak Template

Basic tweak structure:

```objective-c
// Tweak.h
@interface YourTargetClass : NSObject
- (void)targetMethod;
@end

// Tweak.x
%hook YourTargetClass

- (void)targetMethod {
    // Your custom code here
    NSLog(@"[YourTweak] Method called!");
    
    // Call original method
    %orig;
}

%end
```

### Integration with Patcher

1. Build your tweak: `make package`
2. Extract `.dylib` from `.deb` package
3. Place in appropriate `tweaks/` directory
4. Update `configs/tweak-manifest.json`
5. Test with patch script

## 🔄 Batch Processing

### Multiple Apps Script

Process multiple apps in sequence:

```bash
#!/bin/bash
# batch-build.sh

apps=(
    "youtube|https://host.com/youtube.ipa|youtube-reborn,sponsorblock"
    "instagram|https://host.com/instagram.ipa|instagram-plus"
    "tiktok|https://host.com/tiktok.ipa|tiktok-plus"
)

for app_config in "${apps[@]}"; do
    IFS='|' read -r app_type ipa_url tweaks <<< "$app_config"
    
    echo "Building $app_type..."
    ./scripts/patch.sh \
        --app-type "$app_type" \
        --ipa-url "$ipa_url" \
        --tweaks "$tweaks" \
        --bundle-id "com.custom.$app_type"
        
    # Move output with app name
    mv output/modified.ipa "output/${app_type}_modified.ipa"
done
```

### Parallel Processing

Use GNU parallel for faster builds:

```bash
# Install parallel
brew install parallel

# Create job list
echo "youtube|https://host.com/youtube.ipa|youtube-reborn" > jobs.txt
echo "instagram|https://host.com/instagram.ipa|instagram-plus" >> jobs.txt

# Run parallel builds
parallel --colsep '|' ./scripts/patch.sh --app-type {1} --ipa-url {2} --tweaks {3} :::: jobs.txt
```

## 🔄 CI/CD Integration

### Jenkins Integration

```groovy
pipeline {
    agent any
    
    parameters {
        choice(name: 'APP_TYPE', choices: ['youtube', 'instagram', 'tiktok'])
        string(name: 'IPA_URL', description: 'IPA download URL')
    }
    
    stages {
        stage('Setup') {
            steps {
                checkout scm
                sh './setup.sh --skip-deps'
            }
        }
        
        stage('Build') {
            steps {
                sh """
                ./scripts/patch.sh \\
                    --app-type ${params.APP_TYPE} \\
                    --ipa-url ${params.IPA_URL}
                """
            }
        }
        
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'output/*.ipa'
            }
        }
    }
}
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - build
  - sign
  - deploy

variables:
  APP_TYPE: "youtube"
  TWEAKS: "youtube-reborn,sponsorblock"

build_app:
  stage: build
  image: macos-latest
  script:
    - ./setup.sh
    - ./scripts/patch.sh --app-type $APP_TYPE --tweaks $TWEAKS --ipa-url $IPA_URL
  artifacts:
    paths:
      - output/modified.ipa
    expire_in: 1 day

sign_app:
  stage: sign
  dependencies:
    - build_app
  script:
    - ./scripts/resign.sh output/modified.ipa
  artifacts:
    paths:
      - output/signed.ipa
```

## 🔧 Advanced Customization

### Custom App Handling

Add support for complex app structures:

```bash
# In scripts/patch.sh, add custom handling
handle_custom_app() {
    local app_type="$1"
    
    case "$app_type" in
        complex-app)
            # Custom preprocessing
            preprocess_complex_app
            
            # Apply patches with special options
            azule_cmd="$azule_cmd --custom-flag"
            ;;
    esac
}
```

### Dynamic Tweak Loading

Load tweaks based on app version:

```bash
get_compatible_tweaks() {
    local app_version="$1"
    local app_type="$2"
    
    # Parse version and select compatible tweaks
    if version_compare "$app_version" "18.0.0" -ge 0; then
        echo "new-tweaks,modern-features"
    else
        echo "legacy-tweaks,compatibility-mode"
    fi
}
```

### Hook System

Create a plugin system for custom processing:

```bash
# hooks/pre-patch.sh
#!/bin/bash
echo "Running pre-patch hook..."
# Custom preprocessing logic

# hooks/post-patch.sh
#!/bin/bash
echo "Running post-patch hook..."
# Custom post-processing logic
```

## 🐛 Advanced Troubleshooting

### Debug Build Process

Enable comprehensive debugging:

```bash
# Enable all debugging
export DEBUG=true
export AZULE_DEBUG=true
export VERBOSE=true

# Run with maximum logging
./scripts/patch.sh --ipa-url "URL" --app-type youtube 2>&1 | tee debug.log
```

### Memory and Performance Optimization

For large IPAs or resource-constrained systems:

```bash
# Use temporary files in faster storage
export TMPDIR="/tmp/fast-storage"

# Limit parallel operations
export MAX_PARALLEL_JOBS=2

# Use compression
export ENABLE_COMPRESSION=true
```

### Crash Analysis

When apps crash after modification:

1. **Check device logs:**
   ```bash
   # macOS with connected device
   log stream --predicate 'process == "YourApp"'
   ```

2. **Analyze crash reports:**
   - Settings → Analytics & Improvements → Analytics Data
   - Look for your app's crash logs

3. **Test incrementally:**
   ```bash
   # Build with minimal tweaks first
   ./scripts/patch.sh --tweaks "universal-adblock" --app-type youtube
   
   # Add tweaks one by one
   ./scripts/patch.sh --tweaks "universal-adblock,youtube-reborn" --app-type youtube
   ```

### Network Issues

Handle network-related problems:

```bash
# Use alternative download methods
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 5

# Test URL accessibility
curl -I --max-time 10 "$IPA_URL"

# Use proxy if needed
export https_proxy="http://proxy:port"
```

## 📊 Monitoring and Analytics

### Build Statistics

Track build success rates and performance:

```bash
# Log build metrics
echo "$(date),${APP_TYPE},${BUILD_TIME},${SUCCESS}" >> metrics.csv

# Generate reports
awk -F, '{success[$2]+=$4; total[$2]++} END {for (app in total) print app, success[app]/total[app]*100"%"}' metrics.csv
```

### Resource Usage

Monitor resource consumption:

```bash
# Memory usage during build
/usr/bin/time -l ./scripts/patch.sh --ipa-url "URL" --app-type youtube

# Disk space monitoring
df -h . && ./scripts/patch.sh --ipa-url "URL" --app-type youtube && df -h .
```

---

## 🆘 Advanced Support

For advanced usage questions:
- **GitHub Discussions**: Technical deep-dives
- **Discord Developer Channel**: Real-time help
- **Documentation**: Check all docs/ files
- **Source Code**: Read the scripts for implementation details

**Remember**: Advanced usage requires good understanding of iOS app structure, code signing, and shell scripting. Always test thoroughly before using in production!
