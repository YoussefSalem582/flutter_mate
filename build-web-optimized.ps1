# Flutter Web Build Script - Optimized for GitHub Pages
# This script builds the Flutter web app with all performance optimizations

Write-Host "🚀 Building FlutterMate for GitHub Pages..." -ForegroundColor Cyan
Write-Host ""

# Clean previous build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build with optimizations
Write-Host "🔨 Building web app with optimizations..." -ForegroundColor Yellow
Write-Host "   ✓ CanvasKit renderer (better performance)" -ForegroundColor Gray
Write-Host "   ✓ PWA with offline support" -ForegroundColor Gray
Write-Host "   ✓ Tree-shaking unused icons" -ForegroundColor Gray
Write-Host "   ✓ No source maps (smaller size)" -ForegroundColor Gray
Write-Host ""

flutter build web --release `
  --base-href /flutter_mate/ `
  --web-renderer canvaskit `
  --pwa-strategy offline-first `
  --tree-shake-icons `
  --no-source-maps `
  --dart-define=PRODUCTION=true

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Output location: build/web/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🧪 To test locally, run:" -ForegroundColor Yellow
    Write-Host "   cd build/web" -ForegroundColor White
    Write-Host "   python -m http.server 8000" -ForegroundColor White
    Write-Host "   Then open: http://localhost:8000" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 To deploy, commit and push to GitHub:" -ForegroundColor Yellow
    Write-Host "   git add ." -ForegroundColor White
    Write-Host "   git commit -m 'build: optimize web build'" -ForegroundColor White
    Write-Host "   git push origin main" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Build failed! Check the errors above." -ForegroundColor Red
    Write-Host ""
    exit 1
}

