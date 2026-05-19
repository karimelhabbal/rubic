#!/bin/bash
# ============================================================
# Setup script - يجهز المشروع للبناء
# ============================================================

set -e

echo "⚙️  تجهيز مشروع حل مكعب روبيك..."
echo "================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create assets directories
mkdir -p assets/fonts assets/images

echo ""
echo "📥 تحميل خطوط Cairo العربية..."

# Download Cairo font from Google Fonts
BASE_URL="https://fonts.gstatic.com/s/cairo"

# We'll use a simpler approach - download from a CDN
FONTS_DIR="assets/fonts"

if command -v curl &> /dev/null; then
    DOWNLOADER="curl -sL -o"
elif command -v wget &> /dev/null; then
    DOWNLOADER="wget -q -O"
else
    echo "⚠️  لا يوجد curl أو wget. يرجى تحميل خطوط Cairo يدوياً من:"
    echo "   https://fonts.google.com/specimen/Cairo"
    echo "   وضعها في: assets/fonts/"
fi

echo ""
echo "ℹ️  ملاحظة: إذا لم تتوفر خطوط Cairo، سيستخدم التطبيق الخط الافتراضي."
echo "   يمكن تحميل الخطوط من: https://fonts.google.com/specimen/Cairo"
echo ""

# Create placeholder fonts notice
cat > assets/fonts/README.txt << 'EOF'
Place Cairo font files here:
- Cairo-Regular.ttf
- Cairo-Bold.ttf  
- Cairo-SemiBold.ttf

Download from: https://fonts.google.com/specimen/Cairo
Click "Download family" button.
EOF

echo "✅ مجلدات الـ assets جاهزة"
echo ""

# Check flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter متوفر"
    flutter pub get
    echo "✅ المكتبات محملة"
else
    echo "⚠️  Flutter غير موجود في PATH"
    echo "   يرجى تثبيته من: https://flutter.dev/docs/get-started/install"
fi

echo ""
echo "🎉 الإعداد اكتمل!"
echo ""
echo "📋 الخطوات التالية:"
echo "   1. أضف خطوط Cairo في مجلد assets/fonts/"
echo "   2. شغل: flutter pub get"
echo "   3. للاختبار: flutter run"
echo "   4. للإصدار: ./build_release.sh"
