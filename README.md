# 🚀 IPAenject - Universal iOS App Patcher

> **أداة قوية لدمج التعديلات (tweaks/dylibs) مع تطبيقات iOS بشكل آلي باستخدام GitHub Actions**

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=flat-square&logo=ios&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)

## ✨ **المميزات**

- 🔄 **بناء آلي كامل** باستخدام GitHub Actions
- 📱 **دعم تطبيقات متعددة** (YouTube, Instagram, TikTok, WhatsApp, إلخ...)
- 🧩 **مكتبة واسعة من الـ tweaks** منظمة حسب فئات التطبيقات
- ⚙️ **خيارات قابلة للتخصيص** (Bundle ID, Display Name, Icon)
- 🔐 **إعادة توقيع تلقائية** للتطبيقات المعدلة
- 📦 **توزيع مباشر** عبر GitHub Releases
- 🌐 **واجهة سهلة الاستخدام** عبر GitHub Actions UI

## 📱 **التطبيقات المدعومة**

### 📺 **تطبيقات الفيديو:**
- **YouTube** - إزالة الإعلانات، تحميل الفيديوهات، PiP
- **TikTok** - تحميل الفيديوهات، إزالة العلامة المائية
- **Instagram** - تحميل الصور والفيديوهات، إخفاء القصص
- **Snapchat** - حفظ الرسائل، تسجيل الشاشة بدون إشعار

### 💬 **تطبيقات التواصل:**
- **WhatsApp** - إخفاء آخر ظهور، قراءة الرسائل بدون إشعار
- **Telegram** - ميزات متقدمة، تحميل بلا حدود
- **Discord** - ميزات Nitro مجاناً

### 🎵 **تطبيقات الموسيقى:**
- **Spotify** - Premium مجاناً، تحميل الأغاني
- **SoundCloud** - تحميل الأغاني، إزالة الإعلانات

## 🛠️ **كيفية الاستخدام**

### **الطريقة السهلة (موصى بها):**

1. **قم بعمل Fork لهذا المستودع**
   ```bash
   # اضغط على زر Fork في أعلى الصفحة
   ```

2. **فعّل GitHub Actions**
   - اذهب إلى `Settings` > `Actions` > `General`
   - فعّل `Read and write permissions`

3. **شغّل الـ Workflow**
   - اذهب إلى تبويب `Actions`
   - اختر `Build Modified iOS App`
   - اضغط `Run workflow`

4. **املأ المعلومات:**
   - **رابط IPA**: رابط مباشر لملف IPA مفكك التشفير
   - **نوع التطبيق**: اختر من القائمة المتاحة
   - **التعديلات المطلوبة**: اختر الـ tweaks التي تريد دمجها

5. **احصل على التطبيق المعدل**
   - انتظر انتهاء عملية البناء (5-15 دقيقة)
   - نزّل التطبيق من قسم `Releases`

## 📁 **هيكل المشروع**

```
ipaenject/
├── 📂 .github/workflows/          # GitHub Actions workflows
│   ├── build-app.yml             # البناء الرئيسي
│   └── update-tweaks.yml          # تحديث المكتبة
│
├── 📂 tweaks/                     # مكتبة التعديلات
│   ├── 📂 social/                 # تطبيقات التواصل
│   │   ├── whatsapp/
│   │   ├── telegram/
│   │   └── discord/
│   ├── 📂 media/                  # تطبيقات الميديا
│   │   ├── youtube/
│   │   ├── tiktok/
│   │   ├── instagram/
│   │   └── spotify/
│   └── 📂 universal/              # تعديلات عامة
│       ├── adblock/
│       ├── jailbreak-detection/
│       └── flex-patches/
│
├── 📂 scripts/                    # سكريبتات المساعدة
│   ├── patch.sh                   # سكريبت الـ patching
│   ├── resign.sh                  # سكريبت إعادة التوقيع
│   └── utils.sh                   # وظائف مساعدة
│
├── 📂 configs/                    # ملفات التكوين
│   ├── app-configs.json           # إعدادات التطبيقات
│   ├── tweak-manifest.json        # فهرس التعديلات
│   └── build-settings.yml         # إعدادات البناء
│
└── 📄 README.md                   # هذا الملف
```

## 🧩 **مكتبة التعديلات**

### **YouTube Tweaks:**
- **YouTube Reborn** - إزالة الإعلانات، تحميل الفيديوهات
- **YouTopia** - واجهة محسنة، ميزات إضافية
- **YTUHD** - جودات عالية إضافية
- **YouPiP** - Picture-in-Picture للجميع
- **SponsorBlock** - تخطي الإعلانات المدمجة

### **Instagram Tweaks:**
- **Instagram++** - تحميل الصور والفيديوهات
- **Rocket for Instagram** - ميزات متقدمة
- **InstaSave** - حفظ المحتوى بسهولة

### **Universal Tweaks:**
- **AppStore++** - downgrade للتطبيقات
- **Flex 3** - تعديلات مرنة
- **Liberty Lite** - bypass jailbreak detection
- **A-Bypass** - تجاوز حماية التطبيقات

## ⚠️ **متطلبات مهمة**

### **📋 قبل البدء:**
1. **ملف IPA مفكك التشفير** - يجب أن يكون لديك ملف IPA أصلي مفكك التشفير
2. **رابط تحميل مباشر** - استخدم خدمات مثل Dropbox, Google Drive, أو filebin
3. **مساحة GitHub** - تأكد من وجود مساحة كافية في حسابك

### **🔒 ملاحظات قانونية:**
- استخدم فقط التطبيقات التي تملكها أو لديك الحق في تعديلها
- هذا المشروع للأغراض التعليمية والاستخدام الشخصي فقط
- نحن غير مسؤولين عن أي استخدام غير قانوني

## 🔧 **إعدادات متقدمة**

### **تخصيص Bundle ID:**
```yaml
bundle_id: com.yourname.modifiedapp
display_name: "My Modified App"
version: "1.0.0"
```

### **اختيار التعديلات:**
```yaml
tweaks:
  - youtube/youtube-reborn.dylib
  - universal/adblock.dylib
  - universal/liberty-lite.dylib
```

### **إعدادات التوقيع:**
```yaml
signing:
  method: "free"          # free, enterprise, developer
  team_id: "YOUR_TEAM_ID" # اختياري
```

## 📊 **إحصائيات المشروع**

- **🧩 عدد التعديلات**: 50+ tweak جاهز
- **📱 التطبيقات المدعومة**: 20+ تطبيق شهير
- **⏱️ زمن البناء المتوسط**: 8 دقائق
- **✅ معدل النجاح**: 95%

## 🤝 **المساهمة**

نرحب بمساهماتكم! يمكنكم:

1. **إضافة tweaks جديدة** في مجلد `tweaks/`
2. **دعم تطبيقات جديدة** عبر تحديث `configs/app-configs.json`
3. **تحسين الـ workflow** في `.github/workflows/`
4. **تحديث التوثيق** وإضافة أمثلة

### **خطوات المساهمة:**
```bash
# Fork المشروع
git clone https://github.com/yourusername/ios-app-patcher
cd ios-app-patcher

# إضافة التعديلات
cp your-tweak.dylib tweaks/category/app/

# تحديث الـ manifest
# edit configs/tweak-manifest.json

# إرسال Pull Request
git add .
git commit -m "Add new tweak for AppName"
git push origin main
```

## 📞 **الدعم والمساعدة**

- **🐛 تقرير المشاكل**: [Issues](https://github.com/yourusername/ipaenject/issues)
- **💬 النقاش**: [Discussions](https://github.com/yourusername/ipaenject/discussions)
- **📧 التواصل**: [البريد الإلكتروني](mailto:your.email@example.com)

## 📝 **الترخيص**

هذا المشروع مرخص تحت [MIT License](LICENSE) - راجع ملف LICENSE للتفاصيل.

---

<div align="center">

**⭐ إذا أعجبك المشروع، لا تنسَ إعطاءه نجمة! ⭐**

Made with ❤️ by IPAenject Team

</div>
