#!/bin/bash
# ============================================================
# Build script for Rubik Solver AR - Release APK
# ============================================================

set -e

echo "🚀 بناء تطبيق حل مكعب روبيك..."
echo "=============================="

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter غير مثبت. يرجى تثبيته من: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter موجود: $(flutter --version | head -1)"

# Clean previous builds
echo ""
echo "🧹 تنظيف الملفات القديمة..."
flutter clean

# Get dependencies
echo ""
echo "📦 تحميل المكتبات..."
flutter pub get

# Build release APK
echo ""
echo "🔨 بناء APK للإصدار..."
flutter build apk --release \
    --target-platform android-arm64,android-arm \
    --split-per-abi \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --dart-define=dart.vm.product=true

echo ""
echo "✅ تم البناء بنجاح!"
echo ""
echo "📱 ملفات APK:"
ls -lh build/app/outputs/apk/release/*.apk
echo ""
echo "📁 الملفات موجودة في: build/app/outputs/apk/release/"
echo ""
echo "💡 للتثبيت مباشرة على الجهاز:"
echo "   adb install build/app/outputs/apk/release/app-arm64-v8a-release.apk"
