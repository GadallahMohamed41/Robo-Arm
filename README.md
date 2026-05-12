<div align="center">

# 🤖 Robotics App

> تطبيق Flutter متقدم للتحكم بأنظمة الروبوتات عبر Bluetooth و WiFi مع دعم سحابي كامل

<br/>

![Version](https://img.shields.io/badge/version-1.0.0-0affb4?style=flat-square&labelColor=0a0a0f)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat-square&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-enabled-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/license-MIT-ff2d6b?style=flat-square)

<br/>

![Android](https://img.shields.io/badge/Android-✓-3DDC84?style=flat-square&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-✓-000000?style=flat-square&logo=apple&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-000000?style=flat-square&logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-0078D6?style=flat-square&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-✓-FCC624?style=flat-square&logo=linux&logoColor=black)
![Web](https://img.shields.io/badge/Web-✓-4285F4?style=flat-square&logo=googlechrome&logoColor=white)

</div>

---

## ✨ الميزات

| | الميزة | الوصف |
|--|--------|--------|
| 🔗 | **Bluetooth** | تواصل مباشر مع أجهزة الروبوتات |
| 📡 | **WiFi Scan** | كشف الشبكات المتاحة تلقائياً |
| 🔐 | **Authentication** | تسجيل دخول آمن عبر Firebase |
| ☁️ | **Firestore** | قاعدة بيانات سحابية فورية |
| 💾 | **Local Storage** | تخزين محلي عبر Shared Preferences |
| 🔔 | **Connectivity** | مراقبة حالة الاتصال تلقائياً |
| ⚙️ | **Settings** | إعدادات كاملة قابلة للتخصيص |

---

## 📦 المتطلبات

| الأداة | الإصدار المطلوب |
|--------|----------------|
| Flutter | `>= 3.0` |
| Dart | `>= 3.0` |
| Java | `>= 11` *(Android)* |
| Xcode | `>= 14` *(iOS / macOS)* |
| Visual Studio | `>= 2019` *(Windows)* |

---

## 🚀 التثبيت

```bash
# 1 — استنساخ المستودع
git clone <repository-url>
cd robotics_app

# 2 — تثبيت المكتبات
flutter pub get

# 3 — توليد الكود للـ release
flutter pub run build_runner build --release

# 4 — ربط Firebase (اختياري)
flutterfire configure

# 5 — تشغيل التطبيق 🚀
flutter run
```

---

## 📂 البنية الهيكلية

```
lib/
├── main.dart                    # نقطة الدخول
├── firebase_options.dart        # إعدادات Firebase
│
├── core/
│   ├── constants/               # الثوابت
│   ├── extensions/              # التوسيعات
│   ├── theme/                   # المظهر والألوان
│   └── utils/                   # الأدوات المساعدة
│
└── features/
    ├── authentication/          # تسجيل الدخول
    ├── bluetooth/               # اتصال Bluetooth
    ├── wifi_scan/               # مسح WiFi
    ├── settings/                # الإعدادات
    ├── dashboard/               # لوحة التحكم
    └── home/                    # الصفحة الرئيسية
```

---

## ▶️ التشغيل والبناء

<details>
<summary>▶️ تشغيل على المنصات</summary>

```bash
flutter run -d android    # Android
flutter run -d ios        # iOS
flutter run -d chrome     # Web
flutter run -d windows    # Windows
flutter run -d macos      # macOS
flutter run -d linux      # Linux
```

</details>

<details>
<summary>🔨 بناء للإنتاج</summary>

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Google Play Bundle
flutter build ios --release          # iOS IPA
flutter build web --release          # Web
flutter build windows --release      # Windows
flutter build macos --release        # macOS
```

</details>

---

## 📚 المكتبات المستخدمة

| المكتبة | الوصف |
|---------|--------|
| `firebase_core` | أساس Firebase |
| `firebase_auth` | المصادقة |
| `cloud_firestore` | قاعدة البيانات السحابية |
| `flutter_bluetooth_serial` | اتصال Bluetooth |
| `wifi_scan` | مسح شبكات WiFi |
| `connectivity_plus` | مراقبة الاتصال |
| `shared_preferences` | التخزين المحلي |
| `permission_handler` | إدارة الأذونات |
| `network_info_plus` | معلومات الشبكة |
| `app_settings` | إعدادات النظام |

---

## ⚙️ الأذونات

<details>
<summary>🤖 Android — <code>AndroidManifest.xml</code></summary>

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

</details>

<details>
<summary>🍎 iOS — <code>Info.plist</code></summary>

```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>يحتاج التطبيق لاستخدام Bluetooth للتواصل مع الروبوت</string>
<key>NSLocalNetworkUsageDescription</key>
<string>يحتاج التطبيق للوصول للشبكة المحلية</string>
```

</details>

---

## 🧪 الاختبار

```bash
# تشغيل كل الاختبارات
flutter test

# اختبارات الأداء
flutter test --trace-startup
```

---

## 🤝 المساهمة

1. 🍴 **Fork** المستودع
2. 🌿 أنشئ فرعاً جديداً — `git checkout -b feature/amazing-feature`
3. ✅ Commit التغييرات — `git commit -m 'Add amazing feature'`
4. 📤 Push الفرع — `git push origin feature/amazing-feature`
5. 🔁 افتح **Pull Request**

---

## 🔗 روابط مفيدة

- 📘 [Flutter Documentation](https://docs.flutter.dev/)
- 🔥 [Firebase Documentation](https://firebase.google.com/docs)
- 🎯 [Dart Documentation](https://dart.dev/guides)
- 🐛 [Report a Bug](../../issues)
- 💬 [Discussions](../../discussions)

---

<div align="center">

**الإصدار 1.0.0 — May 2026**

مرخص تحت [MIT License](LICENSE)

</div>