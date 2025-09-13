# 📱 Installation Guide

This guide will walk you through installing apps modified with Universal iOS App Patcher on your iOS device.

## 📋 Prerequisites

Before you begin, make sure you have:

- An iOS device (iPhone/iPad) running iOS 12.0 or later
- A computer (Mac/Windows/Linux) for sideloading
- A modified IPA file from Universal iOS App Patcher
- A sideloading tool (AltStore, Sideloadly, or Xcode)

## 🛠️ Installation Methods

### Method 1: AltStore (Recommended)

AltStore is the easiest way to install modified apps without a computer.

#### Setup AltStore

1. **Download AltStore**
   - Visit [altstore.io](https://altstore.io)
   - Download for your operating system

2. **Install AltServer**
   - Run the AltStore installer on your computer
   - Start AltServer (it runs in the background)

3. **Connect Your Device**
   - Connect your iOS device to your computer
   - Trust the computer on your device

4. **Install AltStore**
   - Open AltServer menu (system tray/menu bar)
   - Select "Install AltStore" → Your Device
   - Enter your Apple ID credentials

5. **Trust Developer**
   - Go to Settings → General → VPN & Device Management
   - Trust your Apple ID under "Developer App"

#### Install Modified App

1. **Get Your Modified IPA**
   - Download from GitHub Releases
   - Or use AirDrop/Files app to transfer

2. **Install via AltStore**
   - Open AltStore on your device
   - Tap "+" in the top-left corner
   - Browse and select your IPA file
   - Wait for installation to complete

3. **Refresh Apps**
   - Open AltStore regularly to refresh app certificates
   - Apps expire after 7 days (free Apple ID)

### Method 2: Sideloadly

Sideloadly is a powerful cross-platform sideloading tool.

#### Setup Sideloadly

1. **Download Sideloadly**
   - Visit [sideloadly.io](https://sideloadly.io)
   - Download for your platform

2. **Install and Launch**
   - Install the application
   - Launch Sideloadly

3. **Connect Device**
   - Connect your iOS device via USB
   - Trust the computer if prompted

#### Install App

1. **Load IPA File**
   - Drag your IPA file to Sideloadly
   - Or click "Browse" to select it

2. **Configure Settings**
   - Enter your Apple ID
   - Choose signing certificate
   - Modify bundle ID if needed

3. **Start Installation**
   - Click "Start" to begin sideloading
   - Enter Apple ID password when prompted
   - Wait for installation to complete

4. **Trust Developer**
   - Go to Settings → General → VPN & Device Management
   - Trust your Apple ID certificate

### Method 3: Xcode (Mac Only)

Use Xcode for development installation.

#### Requirements
- Mac computer with Xcode installed
- Apple ID (free account works)
- iOS device in Developer Mode

#### Installation Steps

1. **Open Xcode**
   - Launch Xcode on your Mac
   - Go to Window → Devices and Simulators

2. **Prepare Device**
   - Connect your iOS device
   - Select your device from the list
   - Click "Use for Development"

3. **Install IPA**
   - Drag your IPA file to Xcode
   - Select your device as the target
   - Click the install button

### Method 4: TrollStore (iOS 14.0-15.4.1)

For jailbroken or TrollStore-compatible devices.

#### Requirements
- iOS 14.0-15.4.1 (specific versions)
- TrollStore installed
- Root access

#### Installation
1. Open TrollStore
2. Tap "+" to add IPA
3. Select your modified IPA
4. Tap "Install"
5. App installs permanently (no expiration)

## ⚠️ Common Issues and Solutions

### App Won't Install

**Issue**: "Unable to install [app name]"

**Solutions**:
- Check iOS compatibility
- Verify IPA file integrity
- Try different bundle ID
- Clear device storage
- Restart device

### App Crashes on Launch

**Issue**: App opens then immediately closes

**Solutions**:
- Check tweak compatibility
- Verify iOS version support
- Try installing without specific tweaks
- Check crash logs in Settings → Analytics

### Certificate Issues

**Issue**: "Untrusted Enterprise Developer"

**Solutions**:
- Go to Settings → General → VPN & Device Management
- Find your profile under "Enterprise App"
- Tap "Trust [Developer Name]"
- Confirm trust in popup

### Signature Expiration

**Issue**: App stops working after 7 days

**Solutions**:
- Re-sign the app using AltStore
- Use AltStore's auto-refresh feature
- Consider using a paid Apple Developer account (1-year certificates)

## 🔧 Advanced Configuration

### Custom Bundle IDs

To install alongside the original app:
1. Use the `--bundle-id` option when building
2. Choose a unique identifier (e.g., `com.yourname.youtube`)
3. This allows both original and modified apps

### Multiple App Versions

Install different configurations:
1. Build multiple versions with different tweaks
2. Use different bundle IDs for each version
3. Label clearly to avoid confusion

### Enterprise Certificates

For longer-lasting installations:
1. Obtain enterprise certificate
2. Sign app with enterprise profile
3. Install via enterprise distribution
4. Certificate lasts 1 year

## 🛡️ Security Considerations

### Source Verification
- Only install IPAs from trusted sources
- Verify checksums if provided
- Be cautious of unknown modifications

### Permissions
- Review app permissions before installing
- Understand what tweaks can access
- Monitor app behavior after installation

### Privacy
- Some tweaks may collect data
- Read tweak descriptions carefully
- Consider using privacy-focused tweaks

## 📞 Getting Help

### Before Asking for Help
1. Check this guide thoroughly
2. Search existing issues on GitHub
3. Try basic troubleshooting steps

### Support Channels
- **GitHub Issues**: Technical problems
- **Discussions**: General questions
- **Community Discord**: Real-time help
- **Email**: Direct support

### Information to Include
When asking for help, provide:
- iOS version
- Device model
- App version
- Tweaks installed
- Error messages
- Installation method used

## 📚 Additional Resources

- [AltStore FAQ](https://altstore.io/faq/)
- [Sideloadly Guide](https://sideloadly.io/guide/)
- [Apple Developer Program](https://developer.apple.com/programs/)
- [iOS App Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html)

---

**Happy Sideloading! 🚀**

If you encounter any issues not covered in this guide, please open an issue on our GitHub repository.
