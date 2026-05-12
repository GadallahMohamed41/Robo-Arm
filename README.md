<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🤖 Robotics App — README</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Syne:wght@400;700;800&display=swap" rel="stylesheet">
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{
  --c1:#0affb4;--c2:#ff2d6b;--c3:#7c3aed;--c4:#0a0a0f;--c5:#111118;--c6:#1a1a28;
  --font-head:'Syne',sans-serif;--font-mono:'Space Mono',monospace;
}
body{background:var(--c4);color:#fff;font-family:var(--font-mono);min-height:100vh;}
.wrap{max-width:900px;margin:0 auto;padding:0 0 4rem;}
.hero{position:relative;z-index:1;padding:3rem 2rem 2rem;border-bottom:1px solid #ffffff10;}
.hero-grid{display:grid;grid-template-columns:1fr auto;align-items:start;gap:1rem;}
.badge{display:inline-flex;align-items:center;gap:6px;background:#ffffff08;border:1px solid #ffffff15;border-radius:999px;padding:4px 12px;font-size:11px;color:var(--c1);letter-spacing:.08em;text-transform:uppercase;margin-bottom:1rem;}
.badge-dot{width:6px;height:6px;border-radius:50%;background:var(--c1);animation:pulse 1.5s ease-in-out infinite;}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.4;transform:scale(.8)}}
.hero h1{font-family:var(--font-head);font-size:3rem;font-weight:800;line-height:1.05;letter-spacing:-.02em;margin-bottom:.75rem;}
.hero h1 .accent{color:var(--c1);}
.hero h1 .accent2{color:var(--c2);}
.hero p{font-size:13px;color:#ffffff60;line-height:1.7;max-width:400px;}
.version-box{background:var(--c6);border:1px solid #ffffff10;border-radius:8px;padding:1rem 1.25rem;text-align:right;min-width:140px;}
.version-box .v-label{font-size:10px;color:#ffffff40;letter-spacing:.1em;text-transform:uppercase;margin-bottom:4px;}
.version-box .v-num{font-family:var(--font-head);font-size:1.5rem;font-weight:800;color:var(--c1);}
.version-box .v-date{font-size:10px;color:#ffffff40;margin-top:2px;}
.tags{display:flex;flex-wrap:wrap;gap:6px;margin-top:1.5rem;}
.tag{padding:5px 10px;border-radius:4px;font-size:10px;letter-spacing:.06em;text-transform:uppercase;font-weight:700;border:1px solid;}
.tag-g{background:#0affb410;border-color:#0affb430;color:var(--c1);}
.tag-p{background:#ff2d6b10;border-color:#ff2d6b30;color:var(--c2);}
.tag-v{background:#7c3aed15;border-color:#7c3aed40;color:#a78bfa;}
.section{position:relative;z-index:1;padding:2rem 2rem 0;}
.section-label{font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:#ffffff30;margin-bottom:1rem;display:flex;align-items:center;gap:8px;}
.section-label::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,#ffffff10,transparent);}
.features-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:1px;background:#ffffff08;border:1px solid #ffffff08;border-radius:12px;overflow:hidden;}
.feat{background:var(--c5);padding:1.25rem;transition:background .15s;}
.feat:hover{background:var(--c6);}
.feat-icon{font-size:20px;margin-bottom:.75rem;}
.feat-icon i{color:var(--c1);}
.feat-name{font-family:var(--font-head);font-size:13px;font-weight:700;color:#fff;margin-bottom:4px;}
.feat-desc{font-size:11px;color:#ffffff50;line-height:1.5;}
.stack-row{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:8px;}
.lib-card{background:var(--c5);border:1px solid #ffffff08;border-radius:8px;padding:12px;display:flex;align-items:center;gap:10px;transition:border-color .15s;}
.lib-card:hover{border-color:#0affb430;}
.lib-dot{width:8px;height:8px;border-radius:2px;flex-shrink:0;}
.lib-name{font-size:11px;font-weight:700;color:#fff;margin-bottom:2px;}
.lib-desc{font-size:10px;color:#ffffff40;}
.code-block{background:#0a0a12;border:1px solid #ffffff0a;border-radius:8px;padding:1.25rem;overflow-x:auto;}
.code-block pre{font-family:var(--font-mono);font-size:11px;line-height:1.7;color:#ffffff70;}
.kw{color:#a78bfa;}.str{color:var(--c1);}.fn{color:var(--c2);}
.platforms{display:flex;gap:8px;flex-wrap:wrap;}
.plat{background:var(--c6);border:1px solid #ffffff10;border-radius:6px;padding:6px 14px;font-size:11px;font-weight:700;color:#ffffff70;letter-spacing:.04em;}
.plat.active{border-color:var(--c1);color:var(--c1);background:#0affb408;}
.big-stat-row{display:grid;grid-template-columns:repeat(3,1fr);gap:1px;background:#ffffff08;border:1px solid #ffffff08;border-radius:12px;overflow:hidden;}
.stat{background:var(--c5);padding:1.5rem 1.25rem;text-align:center;}
.stat-num{font-family:var(--font-head);font-size:2rem;font-weight:800;color:var(--c1);line-height:1;}
.stat-label{font-size:10px;color:#ffffff40;letter-spacing:.08em;text-transform:uppercase;margin-top:6px;}
.divider{height:1px;background:linear-gradient(90deg,transparent,#ffffff10,transparent);margin:2rem 0;}
.footer{position:relative;z-index:1;padding:1.5rem 2rem 0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;}
.footer-brand{font-family:var(--font-head);font-size:11px;font-weight:800;color:#ffffff20;letter-spacing:.1em;text-transform:uppercase;}
.footer-links{display:flex;gap:16px;}
.footer-links a{font-size:10px;color:#ffffff30;text-decoration:none;letter-spacing:.05em;text-transform:uppercase;transition:color .15s;}
.footer-links a:hover{color:var(--c1);}
.install-steps{display:flex;flex-direction:column;gap:8px;}
.step{display:flex;align-items:flex-start;gap:12px;}
.step-num{width:22px;height:22px;border-radius:4px;background:var(--c1);color:#000;font-size:10px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:2px;}
.step-cmd{font-family:var(--font-mono);font-size:11px;color:#ffffff80;background:#ffffff05;border:1px solid #ffffff08;border-radius:4px;padding:4px 8px;flex:1;}
.step-note{font-size:10px;color:#ffffff30;margin-top:2px;}
.struct-block{background:var(--c5);border:1px solid #ffffff08;border-radius:8px;padding:1.25rem;}
.struct-block pre{font-family:var(--font-mono);font-size:11px;line-height:1.8;color:#ffffff60;}
.struct-block .dir{color:var(--c1);}.struct-block .file{color:#ffffff80;}.struct-block .comment{color:#ffffff30;}
</style>
</head>
<body>
<div class="wrap">

  <div class="hero">
    <div class="badge"><span class="badge-dot"></span> Live v1.0.0</div>
    <div class="hero-grid">
      <div>
        <h1>🤖 <span class="accent">Robotics</span><br><span class="accent2">App</span></h1>
        <p>تطبيق Flutter متقدم للتحكم بأنظمة الروبوتات عبر Bluetooth و WiFi مع دعم سحابي كامل.</p>
        <div class="tags">
          <span class="tag tag-g">Flutter 3.0+</span>
          <span class="tag tag-g">Dart 3.0+</span>
          <span class="tag tag-p">Firebase</span>
          <span class="tag tag-p">Bluetooth</span>
          <span class="tag tag-v">MIT License</span>
          <span class="tag tag-v">Cross-Platform</span>
        </div>
      </div>
      <div class="version-box">
        <div class="v-label">إصدار</div>
        <div class="v-num">1.0.0</div>
        <div class="v-date">May 2026</div>
      </div>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="big-stat-row">
      <div class="stat"><div class="stat-num">6</div><div class="stat-label">منصات مدعومة</div></div>
      <div class="stat"><div class="stat-num">10</div><div class="stat-label">مكتبات مستخدمة</div></div>
      <div class="stat"><div class="stat-num">∞</div><div class="stat-label">إمكانيات الروبوت</div></div>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">المنصات المدعومة</div>
    <div class="platforms">
      <span class="plat active">Android</span>
      <span class="plat active">iOS</span>
      <span class="plat active">macOS</span>
      <span class="plat active">Windows</span>
      <span class="plat active">Linux</span>
      <span class="plat active">Web</span>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">الميزات الرئيسية</div>
    <div class="features-grid">
      <div class="feat"><div class="feat-icon"><i class="ti ti-bluetooth"></i></div><div class="feat-name">Bluetooth</div><div class="feat-desc">تواصل مباشر مع أجهزة الروبوتات</div></div>
      <div class="feat"><div class="feat-icon"><i class="ti ti-wifi"></i></div><div class="feat-name">WiFi Scan</div><div class="feat-desc">كشف الشبكات المتاحة تلقائياً</div></div>
      <div class="feat"><div class="feat-icon"><i class="ti ti-lock"></i></div><div class="feat-name">Auth آمن</div><div class="feat-desc">Firebase Authentication كامل</div></div>
      <div class="feat"><div class="feat-icon"><i class="ti ti-cloud"></i></div><div class="feat-name">Firestore</div><div class="feat-desc">قاعدة بيانات سحابية فورية</div></div>
      <div class="feat"><div class="feat-icon"><i class="ti ti-device-floppy"></i></div><div class="feat-name">تخزين محلي</div><div class="feat-desc">Shared Preferences للبيانات</div></div>
      <div class="feat"><div class="feat-icon"><i class="ti ti-settings"></i></div><div class="feat-name">إعدادات</div><div class="feat-desc">تكوين كامل قابل للتخصيص</div></div>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">التثبيت السريع</div>
    <div class="install-steps">
      <div class="step"><div class="step-num">1</div><div><div class="step-cmd">git clone &lt;repository-url&gt; &amp;&amp; cd robotics_app</div><div class="step-note">استنساخ المستودع</div></div></div>
      <div class="step"><div class="step-num">2</div><div><div class="step-cmd">flutter pub get</div><div class="step-note">تثبيت كل المكتبات</div></div></div>
      <div class="step"><div class="step-num">3</div><div><div class="step-cmd">flutter pub run build_runner build --release</div><div class="step-note">توليد الكود للـ release</div></div></div>
      <div class="step"><div class="step-num">4</div><div><div class="step-cmd">flutterfire configure</div><div class="step-note">ربط Firebase (اختياري)</div></div></div>
      <div class="step"><div class="step-num">5</div><div><div class="step-cmd">flutter run -d android</div><div class="step-note">تشغيل التطبيق 🚀</div></div></div>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">البنية الهيكلية</div>
    <div class="struct-block">
      <pre><span class="dir">lib/</span>
├── <span class="file">main.dart</span>                    <span class="comment"># نقطة الدخول الرئيسية</span>
├── <span class="file">firebase_options.dart</span>        <span class="comment"># إعدادات Firebase</span>
├── <span class="dir">core/</span>                        <span class="comment"># الأساسيات والمساعدات</span>
│   ├── <span class="dir">constants/</span>              <span class="comment"># الثوابت</span>
│   ├── <span class="dir">extensions/</span>             <span class="comment"># التوسيعات</span>
│   ├── <span class="dir">theme/</span>                  <span class="comment"># المظهر والألوان</span>
│   └── <span class="dir">utils/</span>                  <span class="comment"># الأدوات والمساعدات</span>
└── <span class="dir">features/</span>                    <span class="comment"># الميزات الرئيسية</span>
    ├── <span class="dir">authentication/</span>         <span class="comment"># المصادقة</span>
    ├── <span class="dir">bluetooth/</span>              <span class="comment"># اتصال Bluetooth</span>
    ├── <span class="dir">wifi_scan/</span>              <span class="comment"># مسح WiFi</span>
    ├── <span class="dir">settings/</span>               <span class="comment"># الإعدادات</span>
    ├── <span class="dir">dashboard/</span>              <span class="comment"># لوحة التحكم</span>
    └── <span class="dir">home/</span>                   <span class="comment"># الصفحة الرئيسية</span></pre>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">المكتبات المستخدمة</div>
    <div class="stack-row">
      <div class="lib-card"><div class="lib-dot" style="background:#ff6b35;"></div><div><div class="lib-name">firebase_core</div><div class="lib-desc">أساس Firebase</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#0affb4;"></div><div><div class="lib-name">firebase_auth</div><div class="lib-desc">المصادقة</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#a78bfa;"></div><div><div class="lib-name">cloud_firestore</div><div class="lib-desc">قاعدة البيانات</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#ff2d6b;"></div><div><div class="lib-name">flutter_bluetooth_serial</div><div class="lib-desc">اتصال Bluetooth</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#0affb4;"></div><div><div class="lib-name">wifi_scan</div><div class="lib-desc">مسح WiFi</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#facc15;"></div><div><div class="lib-name">connectivity_plus</div><div class="lib-desc">مراقبة الاتصال</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#38bdf8;"></div><div><div class="lib-name">shared_preferences</div><div class="lib-desc">التخزين المحلي</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#a78bfa;"></div><div><div class="lib-name">permission_handler</div><div class="lib-desc">إدارة الأذونات</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#38bdf8;"></div><div><div class="lib-name">network_info_plus</div><div class="lib-desc">معلومات الشبكة</div></div></div>
      <div class="lib-card"><div class="lib-dot" style="background:#ff6b35;"></div><div><div class="lib-name">app_settings</div><div class="lib-desc">إعدادات النظام</div></div></div>
    </div>
  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">مثال كود — الاتصال بـ Bluetooth</div>
    <div class="code-block">
      <pre><span class="kw">List</span>&lt;<span class="kw">BluetoothDevice</span>&gt; devices =
  <span class="kw">await</span> FlutterBluetoothSerial.<span class="fn">instance</span>
    .<span class="fn">getBondedDevices</span>();

<span class="kw">await</span> connection.<span class="fn">connect</span>(device);
<span class="str">// 🤖 جهازك الروبوت متصل الآن!</span></pre>
</div>

  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">مثال كود — Firestore</div>
    <div class="code-block">
      <pre><span class="kw">import</span> <span class="str">'package:cloud_firestore/cloud_firestore.dart'</span>;

<span class="kw">await</span> FirebaseFirestore.<span class="fn">instance</span>
.<span class="fn">collection</span>(<span class="str">'devices'</span>).<span class="fn">add</span>({
<span class="str">'name'</span>: <span class="str">'Device Name'</span>,
<span class="str">'status'</span>: <span class="str">'connected'</span>,
});

<span class="kw">var</span> snapshot = <span class="kw">await</span> FirebaseFirestore.<span class="fn">instance</span>
.<span class="fn">collection</span>(<span class="str">'devices'</span>).<span class="fn">get</span>();</pre>
</div>

  </div>

  <div class="section" style="margin-top:2rem;">
    <div class="section-label">الأذونات — Android</div>
    <div class="code-block">
      <pre><span class="kw">&lt;uses-permission</span> android:name=<span class="str">"android.permission.BLUETOOTH"</span> /&gt;
<span class="kw">&lt;uses-permission</span> android:name=<span class="str">"android.permission.BLUETOOTH_ADMIN"</span> /&gt;
<span class="kw">&lt;uses-permission</span> android:name=<span class="str">"android.permission.BLUETOOTH_SCAN"</span> /&gt;
<span class="kw">&lt;uses-permission</span> android:name=<span class="str">"android.permission.ACCESS_FINE_LOCATION"</span> /&gt;
<span class="kw">&lt;uses-permission</span> android:name=<span class="str">"android.permission.INTERNET"</span> /&gt;</pre>
    </div>
  </div>

  <div class="divider"></div>

  <div class="footer">
    <span class="footer-brand">🤖 Robotics App — MIT License</span>
    <div class="footer-links">
      <a href="https://docs.flutter.dev/">Flutter Docs</a>
      <a href="https://firebase.google.com/docs">Firebase</a>
      <a href="https://dart.dev/guides">Dart</a>
    </div>
  </div>

</div>
</body>
</html>
