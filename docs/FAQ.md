# ❓ Frequently Asked Questions

## 🔧 General Questions

### Q: What is Universal iOS App Patcher?
**A:** It's an automated system that uses GitHub Actions to modify iOS apps by injecting tweaks (dylibs) and re-signing them for sideloading.

### Q: Is this legal?
**A:** The tool itself is legal for educational and personal use. However, you must:
- Own the original application
- Comply with app terms of service
- Follow your local copyright laws
- Use for personal purposes only

### Q: Do I need a jailbroken device?
**A:** No! Modified apps work on non-jailbroken devices when installed via sideloading tools like AltStore or Sideloadly.

## 🛠️ Setup Questions

### Q: How do I get started?
**A:** 
1. Fork this repository
2. Enable GitHub Actions with write permissions
3. Run the "Build Modified iOS App" workflow
4. Provide an IPA URL and select your tweaks

### Q: Where do I get decrypted IPA files?
**A:** You need to obtain these yourself from:
- Your own apps using tools like Clutch or frida-ios-dump
- Apps you've purchased and own
- **Note:** We cannot provide these for legal reasons

### Q: Can I add my own tweaks?
**A:** Yes! Place `.dylib` files in the appropriate `tweaks/` directory and update the manifest. See CONTRIBUTING.md for details.

## 📱 Build Questions

### Q: Why is my build failing?
**A:** Common causes:
- Invalid IPA URL (not direct download)
- Corrupted or encrypted IPA file
- Incompatible tweaks for the app version
- GitHub Actions timeout

### Q: How long does building take?
**A:** Typically 5-15 minutes depending on:
- IPA file size
- Number of tweaks being injected
- GitHub Actions queue

### Q: Can I build multiple apps at once?
**A:** Each workflow run builds one app, but you can run multiple workflows simultaneously.

## 🔐 Signing Questions

### Q: What's the difference between free and developer signing?
**A:**
- **Free signing**: 7-day expiration, requires regular refresh
- **Developer signing**: 1-year expiration, requires paid Apple Developer account

### Q: Why does my app expire after 7 days?
**A:** Free Apple ID certificates expire after 7 days. Use AltStore's auto-refresh feature or get a paid developer account.

### Q: Can I install alongside the original app?
**A:** Yes! Use a custom bundle ID when building to install both versions.

## 📋 App-Specific Questions

### Q: Which YouTube tweaks are best?
**A:** Popular combinations:
- YouTube Reborn + SponsorBlock
- YouTopia + Universal AdBlock
- YTUHD for higher quality videos

### Q: Do Instagram tweaks work with latest version?
**A:** Compatibility varies. Check the tweak manifest for supported app versions. Older app versions often have better tweak support.

### Q: Can I download TikTok videos?
**A:** Yes, with appropriate tweaks like TikTok++. Always respect content creators' rights.

## 🚨 Troubleshooting

### Q: App crashes on launch
**A:** Try:
- Building with fewer tweaks
- Using an older app version
- Checking iOS compatibility
- Verifying tweak compatibility

### Q: "Unable to install app"
**A:** Common solutions:
- Delete existing app first
- Use different bundle ID
- Check available storage space
- Restart device and try again

### Q: App installs but features don't work
**A:** Possible causes:
- Tweak incompatibility with app version
- iOS version mismatch
- Conflicting tweaks
- App updated detection methods

### Q: Certificate trust issues
**A:** Go to Settings → General → VPN & Device Management → Trust your certificate

## 💻 Technical Questions

### Q: Can I run this on Windows/Linux?
**A:** GitHub Actions runs on macOS automatically. Local usage requires:
- macOS for best compatibility
- Linux with manual ldid compilation
- Windows via WSL (advanced users)

### Q: How do I add support for new apps?
**A:** 
1. Update `configs/app-configs.json`
2. Add app type to workflow options
3. Create tweak directories
4. Test and submit PR

### Q: Can I use custom certificates?
**A:** Yes, for advanced users:
- Enterprise certificates for longer validity
- Custom provisioning profiles
- See resign.sh script options

## 🔄 Updates & Maintenance

### Q: How do I update tweaks?
**A:** 
1. Replace old dylib files with new versions
2. Update tweak manifest with new information
3. Test compatibility
4. Push changes to trigger new builds

### Q: How often should I update?
**A:** Update when:
- New tweak versions are released
- App versions change significantly
- iOS updates affect compatibility

### Q: How do I backup my configurations?
**A:** Your entire setup is in GitHub - just fork and clone!

## 🆘 Getting Help

### Q: Where can I get support?
**A:** 
- **GitHub Issues**: Bug reports and technical problems
- **Discussions**: General questions and community help
- **Discord**: Real-time community support
- **Documentation**: Check all docs/ files first

### Q: How do I report bugs?
**A:** Create a GitHub issue with:
- iOS version and device model
- App version and tweaks used
- Complete error messages
- Steps to reproduce

### Q: Can I contribute?
**A:** Absolutely! See CONTRIBUTING.md for guidelines on:
- Adding new tweaks
- Supporting new apps
- Improving documentation
- Fixing bugs

## 💡 Pro Tips

### Q: Best practices for stable builds?
**A:**
- Use verified tweaks from the manifest
- Test with minimal tweaks first
- Keep app versions reasonably current
- Backup working configurations

### Q: How to minimize app size?
**A:**
- Only include necessary tweaks
- Remove unused frameworks if possible
- Use compressed dylib files when available

### Q: Fastest installation method?
**A:**
- AltStore for convenience
- Sideloadly for advanced options
- Direct installation for development

---

**Still have questions?** 

Check our [GitHub Discussions](https://github.com/yourusername/ios-app-patcher/discussions) or create an [Issue](https://github.com/yourusername/ios-app-patcher/issues) for technical problems.
