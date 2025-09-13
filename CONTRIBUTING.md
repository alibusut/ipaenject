# 🤝 Contributing to IPAenject

We welcome contributions from the community! This guide will help you get started with contributing to the IPAenject project.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Adding New Tweaks](#adding-new-tweaks)
- [Adding New Apps](#adding-new-apps)
- [Improving Workflows](#improving-workflows)
- [Testing](#testing)
- [Code Style](#code-style)
- [Legal Considerations](#legal-considerations)

## 🚀 Getting Started

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/yourusername/ipaenject
   cd ipaenject
   ```

3. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🎯 How to Contribute

### 🧩 Adding New Tweaks

#### Step 1: Organize Your Tweak
Place your tweak in the appropriate category:

```
tweaks/
├── media/           # Video/Audio apps
├── social/          # Social media apps
├── productivity/    # Work/productivity apps
└── universal/       # Cross-app tweaks
```

#### Step 2: Add Tweak Files
```bash
# Example: Adding YouTube tweak
mkdir -p tweaks/media/youtube
cp your-tweak.dylib tweaks/media/youtube/
```

#### Step 3: Update Manifest
Edit `configs/tweak-manifest.json` to include your tweak:

```json
{
  "your-tweak-name": {
    "name": "Your Tweak Name",
    "version": "1.0.0",
    "author": "@yourusername",
    "description": "Brief description of what the tweak does",
    "category": ["adblock", "customization"],
    "file": "your-tweak.dylib",
    "size": "1.2MB",
    "compatibility": {
      "ios_min": "13.0",
      "ios_max": "17.0",
      "app_versions": ["290.0+"]
    },
    "features": [
      "Feature 1",
      "Feature 2",
      "Feature 3"
    ],
    "conflicts": ["conflicting-tweak"],
    "verified": true,
    "rating": 4.5
  }
}
```

#### Step 4: Add Documentation
Create a README in your tweak directory:

```markdown
# Your Tweak Name

## Description
Brief description of what this tweak does.

## Features
- Feature 1
- Feature 2
- Feature 3

## Compatibility
- iOS 13.0+
- App Version 290.0+

## Installation
This tweak will be automatically injected when selected.

## Credits
- Author: @yourusername
- Original source: [link if applicable]
```

### 📱 Adding New Apps

#### Step 1: Update App Configs
Edit `configs/app-configs.json`:

```json
{
  "apps": {
    "your-app": {
      "name": "Your App",
      "bundle_id": "com.company.yourapp",
      "display_name": "Your App++",
      "icon": "📱",
      "category": "productivity",
      "compatible_tweaks": [
        "your-tweak-1",
        "your-tweak-2"
      ],
      "recommended_tweaks": [
        "your-tweak-1",
        "universal-adblock"
      ],
      "min_ios_version": "13.0",
      "notes": "Description of the app and its tweaks"
    }
  }
}
```

#### Step 2: Update Workflow
Add your app to `.github/workflows/build-app.yml` options:

```yaml
app_type:
  type: choice
  options:
    - youtube
    - instagram
    - your-app  # Add your app here
```

#### Step 3: Update Scripts
Add handling for your app in `scripts/patch.sh`:

```bash
your-app)
    echo "📱 Adding Your App tweaks..."
    copy_tweaks_from "$TWEAKS_DIR/category/your-app"
    ;;
```

### ⚙️ Improving Workflows

#### GitHub Actions Improvements
- Enhance error handling
- Add better logging
- Optimize build times
- Add more customization options

#### Script Improvements
- Add new utility functions
- Improve error messages
- Add progress indicators
- Enhance compatibility checks

### 🧪 Testing

#### Before Submitting
1. **Test your tweaks** with the target app
2. **Verify compatibility** with different iOS versions
3. **Check for conflicts** with other tweaks
4. **Test the build process** end-to-end

#### Testing Checklist
- [ ] Tweak loads without crashing
- [ ] Features work as expected
- [ ] No conflicts with other tweaks
- [ ] App installs and runs properly
- [ ] Documentation is accurate

### 📝 Code Style

#### Shell Scripts
```bash
#!/bin/bash
# Use strict mode
set -e

# Clear function names
function_name() {
    local param="$1"
    # Function body
}

# Consistent indentation (4 spaces)
# Clear variable names
# Proper error handling
```

#### JSON Files
```json
{
  "consistent": "formatting",
  "proper": "indentation",
  "clear": "naming"
}
```

#### Markdown
- Use clear headings
- Include code examples
- Add emojis for visual appeal
- Keep sections concise

### ⚖️ Legal Considerations

#### Important Guidelines
- **Only contribute tweaks you have rights to share**
- **Respect original developers' work**
- **Don't include copyrighted materials**
- **Follow applicable laws in your jurisdiction**

#### Required Information
When contributing tweaks, include:
- Original source/author credit
- License information (if available)
- Compatibility information
- Any known limitations or issues

## 📝 Pull Request Guidelines

### Before Submitting
1. **Update documentation** if needed
2. **Test your changes** thoroughly  
3. **Follow naming conventions**
4. **Include clear commit messages**

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New tweak
- [ ] New app support
- [ ] Documentation update
- [ ] Workflow improvement

## Testing
- [ ] Tested on iOS [version]
- [ ] Tested with [app name] version [version]
- [ ] No conflicts with existing tweaks
- [ ] Build process works correctly

## Additional Notes
Any additional information about the changes
```

### Commit Message Format
```
type: brief description

Longer description if needed

- Specific changes made
- Any breaking changes
- References to issues
```

Examples:
```
feat: add Instagram Story Saver tweak
fix: resolve YouTube PiP compatibility issue  
docs: update installation instructions
workflow: improve error handling in build process
```

## 🏆 Recognition

Contributors will be:
- Listed in the project README
- Credited in tweak documentation
- Mentioned in release notes
- Added to the CONTRIBUTORS file

## 📞 Getting Help

- **Questions**: Open a Discussion
- **Issues**: Create an Issue  
- **Chat**: Join our community Discord
- **Email**: [maintainer email]

## 🎉 Thank You!

Thank you for contributing to IPAenject! Your contributions help make iOS customization more accessible to everyone.

---

**Remember**: Always respect intellectual property rights and follow applicable laws when contributing to this project.
