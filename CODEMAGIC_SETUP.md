# 🚀 رفع المشروع على Codemagic وبناء APK

<div dir="rtl">

## ما هو Codemagic؟
Codemagic هو منصة CI/CD سحابية مخصصة لـ Flutter — تبني APK/AAB في السحابة بدون جهاز Mac أو بيئة Android محلية.

---

## الخطوة 1 — تجهيز المستودع

### رفع المشروع على GitHub
```bash
# فك ضغط الأرشيف
tar -xzf rubik_solver_ar.tar.gz
cd rubik_solver_ar

# إنشاء مستودع Git
git init
git add .
git commit -m "Initial commit: Rubik Cube Solver AR"

# ربط بـ GitHub (أنشئ repo فارغاً أولاً)
git remote add origin https://github.com/YOUR_USERNAME/rubik-solver-ar.git
git push -u origin main
```

---

## الخطوة 2 — إنشاء حساب Codemagic

1. اذهب إلى **[codemagic.io](https://codemagic.io)**
2. سجّل بحساب GitHub أو Google
3. انقر **"Add application"**
4. اختر **GitHub** → اختر مستودع `rubik-solver-ar`
5. اختر **"Flutter App"** → انقر **"Finish"**

---

## الخطوة 3 — إضافة متغيرات البيئة (للتوقيع)

في Codemagic → **Teams → Environment variables → Add group** → اسمها `keystore_credentials`

| المتغير | القيمة | النوع |
|---------|--------|------|
| `CM_KEYSTORE` | ملف `.jks` محوّل لـ base64 | **File** |
| `CM_KEYSTORE_PASSWORD` | كلمة سر الـ keystore | Secret |
| `CM_KEY_ALIAS` | اسم المفتاح | Text |
| `CM_KEY_PASSWORD` | كلمة سر المفتاح | Secret |

### كيف تنشئ Keystore؟
```bash
# على جهازك المحلي (يحتاج Java)
keytool -genkey -v \
  -keystore rubik-release.jks \
  -alias rubik_solver \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "CN=Rubik Solver, OU=Apps, O=MyCompany, L=Cairo, S=Cairo, C=EG"

# تحويله لـ base64 لرفعه على Codemagic
base64 rubik-release.jks | pbcopy   # Mac
base64 rubik-release.jks            # Linux → انسخ الناتج
```

> 💡 **بدون Keystore:** يمكن تشغيل الـ workflow مباشرة — سيستخدم debug signing تلقائياً (APK يعمل على الأجهزة لكن لا يُقبل على Play Store).

---

## الخطوة 4 — تشغيل أول Build

1. في لوحة Codemagic → اختر تطبيقك
2. اختر workflow: **"Android Release APK"**
3. انقر **"Start new build"**
4. انتظر ~10 دقائق
5. حمّل APK من قسم **Artifacts** ✅

---

## هيكل ملف codemagic.yaml

```
codemagic.yaml          ← ملف الإعداد الرئيسي (موجود في جذر المشروع)
├── workflows:
│   └── android-release:
│       ├── environment:   Flutter 3.24.5 + Java 17
│       ├── scripts:       8 خطوات (تحميل خطوط، توقيع، بناء...)
│       ├── artifacts:     APK + AAB + mapping.txt
│       └── publishing:    إرسال بريد عند النجاح/الفشل
```

---

## مخرجات البناء

بعد نجاح البناء ستجد في **Artifacts**:

| الملف | الاستخدام |
|-------|----------|
| `app-arm64-v8a-release.apk` | أجهزة حديثة 64-bit (معظم الأجهزة) |
| `app-armeabi-v7a-release.apk` | أجهزة قديمة 32-bit |
| `app-release.aab` | رفع على Google Play Store |
| `mapping.txt` | رموز للـ crash reports |

---

## استكشاف الأخطاء الشائعة

| الخطأ | الحل |
|-------|------|
| `SDK not found` | Codemagic يثبّت Flutter تلقائياً — تأكد من `flutter: 3.24.5` في yaml |
| `Font file not found` | الخطوة 2 في السكريبت تحمّله تلقائياً، أو احذف قسم `fonts:` من pubspec |
| `Keystore error` | تحقق من المتغيرات في Codemagic → بدلاً من ذلك احذف السطر `CM_KEYSTORE` وسيستخدم debug |
| `Gradle build failed` | تحقق من `compileSdk 34` و`jvmTarget = '17'` في build.gradle |
| `Package not found` | تأكد أن `pubspec.yaml` يحتوي الإصدارات الصحيحة للمكتبات |

---

## نصيحة: Build بدون Keystore (اختبار سريع)

إذا أردت تجربة Codemagic فوراً بدون إعداد keystore، عدّل `codemagic.yaml`:

```yaml
# في قسم environment، احذف:
      groups:
        - keystore_credentials
```

سيستخدم debug signing وينجح البناء في أقل من 10 دقائق.

</div>
