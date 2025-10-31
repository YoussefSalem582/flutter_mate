#!/bin/bash
# Flutter Web Build Script - Optimized for GitHub Pages
# This script builds the Flutter web app with all performance optimizations

echo "🚀 Building FlutterMate for GitHub Pages..."
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build with optimizations
echo "🔨 Building web app with optimizations..."
echo "   ✓ CanvasKit renderer (better performance)"
echo "   ✓ PWA with offline support"
echo "   ✓ Tree-shaking unused icons"
echo "   ✓ No source maps (smaller size)"
echo ""

flutter build web --release \
  --base-href /flutter_mate/ \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --tree-shake-icons \
  --no-source-maps \
  --dart-define=PRODUCTION=true

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build completed successfully!"
    echo ""
    echo "📁 Output location: build/web/"
    echo ""
    echo "🧪 To test locally, run:"
    echo "   cd build/web"
    echo "   python -m http.server 8000"
    echo "   Then open: http://localhost:8000"
    echo ""
    echo "🌐 To deploy, commit and push to GitHub:"
    echo "   git add ."
    echo "   git commit -m 'build: optimize web build'"
    echo "   git push origin main"
    echo ""
else
    echo ""
    echo "❌ Build failed! Check the errors above."
    echo ""
    exit 1
fi

