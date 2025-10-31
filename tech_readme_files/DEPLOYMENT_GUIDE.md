# Deployment Guide - GitHub Pages

Quick reference for deploying FlutterMate to GitHub Pages with optimal performance.

## 🚀 Quick Deploy

### Automatic Deployment (Recommended)

Just push to main branch:
```bash
git add .
git commit -m "feat: your changes"
git push origin main
```

The GitHub Actions workflow will:
1. Build with all optimizations
2. Generate service worker for offline support
3. Add caching headers
4. Deploy to GitHub Pages

**Live URL:** https://youssefsalem582.github.io/flutter_mate/

## 🔨 Manual Build (Local Testing)

### Option 1: Quick Build
```bash
flutter build web --release \
  --base-href /flutter_mate/ \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --tree-shake-icons
```

### Option 2: Full Build (With All Flags)
```bash
flutter build web --release \
  --base-href /flutter_mate/ \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --tree-shake-icons \
  --no-source-maps \
  --dart-define=PRODUCTION=true
```

### Option 3: Build Script (PowerShell)
```powershell
# Save as build-web.ps1
flutter clean
flutter pub get
flutter build web --release `
  --base-href /flutter_mate/ `
  --web-renderer canvaskit `
  --pwa-strategy offline-first `
  --tree-shake-icons `
  --no-source-maps

Write-Host "Build completed! Files are in build/web/"
Write-Host "To test locally, run: python -m http.server 8000 -d build/web"
```

### Option 4: Build Script (Bash)
```bash
#!/bin/bash
# Save as build-web.sh
flutter clean
flutter pub get
flutter build web --release \
  --base-href /flutter_mate/ \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --tree-shake-icons \
  --no-source-maps

echo "Build completed! Files are in build/web/"
echo "To test locally, run: python -m http.server 8000 -d build/web"
```

## 🧪 Test Locally

### Using Python (Recommended)
```bash
cd build/web
python -m http.server 8000
```
Open: http://localhost:8000

### Using Flutter's Web Server
```bash
flutter run -d web-server --web-port 8080
```
Open: http://localhost:8080

### Using Live Server (VS Code)
1. Install "Live Server" extension
2. Right-click `build/web/index.html`
3. Select "Open with Live Server"

## 📊 Performance Flags Explained

### `--web-renderer canvaskit`
- Uses Skia (CanvasKit) for rendering
- Better performance for complex UIs
- Consistent across browsers
- ~2MB initial download

### `--pwa-strategy offline-first`
- Generates service worker
- Enables offline support
- Caches assets locally
- Faster subsequent loads

### `--tree-shake-icons`
- Removes unused icons
- Reduces bundle by 100-400KB
- Only includes icons you use

### `--no-source-maps`
- Skips source map generation
- Reduces build size by 30-50%
- Faster builds
- Not needed in production

### `--base-href /flutter_mate/`
- Sets base URL for GitHub Pages
- Required for subdirectory hosting
- Change if repo name changes

## 🎯 Build Optimization Tips

### Reduce Build Size
```bash
# Analyze bundle size
flutter build web --analyze-size

# Check what's taking up space
flutter build web --release --verbose
```

### Different Renderers
```bash
# HTML renderer (smaller, but less performant)
flutter build web --release --web-renderer html

# CanvasKit renderer (better performance)
flutter build web --release --web-renderer canvaskit

# Auto (Flutter chooses based on device)
flutter build web --release --web-renderer auto
```

### Debug vs Release
```bash
# Debug build (larger, with source maps)
flutter build web

# Release build (optimized, production-ready)
flutter build web --release
```

## 🔐 Building with API Keys

### For Production (GitHub Actions)
API keys are passed via environment variables:
```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY_WEB=$FIREBASE_WEB_KEY \
  --dart-define=FIREBASE_APP_ID_WEB=$FIREBASE_WEB_APP_ID \
  --dart-define=FIREBASE_MEASUREMENT_ID_WEB=$FIREBASE_MEASUREMENT_ID \
  --dart-define=OPENAI_API_KEY=$OPENAI_KEY
```

### For Local Testing
Create `.env` file or pass directly:
```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY_WEB=your_key \
  --dart-define=FIREBASE_APP_ID_WEB=your_app_id
```

## 📦 Build Output

After building, `build/web/` contains:

```
build/web/
├── assets/               # App assets (images, fonts)
├── canvaskit/           # CanvasKit WASM files
├── icons/               # App icons (PWA)
├── index.html           # Entry point
├── flutter.js           # Flutter engine loader
├── flutter_bootstrap.js # Bootstrap script
├── flutter_service_worker.js  # Service worker (offline support)
├── manifest.json        # PWA manifest
├── version.json         # Build version info
└── main.dart.js.*       # App code (hashed filenames)
```

### Important Files
- **index.html** - Entry point, always fetched fresh
- **flutter_service_worker.js** - Manages caching
- **manifest.json** - PWA configuration
- **assets/** - Your images, fonts, etc.

## 🌐 Deployment Verification

After deployment, verify:

### 1. Check Build Status
- Go to: https://github.com/YoussefSalem582/flutter_mate/actions
- Latest workflow should be ✅ green

### 2. Test Live Site
- Visit: https://youssefsalem582.github.io/flutter_mate/
- Should load in 2-4 seconds (first time)
- Subsequent loads: < 1 second

### 3. Test Service Worker
1. Open DevTools (F12)
2. Go to Application → Service Workers
3. Should see "flutter_service_worker.js" activated
4. Check "Offline" - app should still work

### 4. Test Caching
1. Open DevTools → Network
2. Refresh page
3. Should see 200 or 304 status codes
4. Many files served from service worker

### 5. Run Lighthouse
```bash
npx lighthouse https://youssefsalem582.github.io/flutter_mate/ --view
```

Target scores:
- Performance: > 90
- PWA: > 90
- Accessibility: > 95

## ⚡ Performance Checklist

Before deploying, ensure:

- [ ] Build with `--release` flag
- [ ] Use `--web-renderer canvaskit` for better performance
- [ ] Enable `--pwa-strategy offline-first`
- [ ] Use `--tree-shake-icons` to reduce size
- [ ] Remove source maps with `--no-source-maps`
- [ ] Set correct `--base-href`
- [ ] Test locally before pushing
- [ ] Verify service worker works
- [ ] Check Lighthouse scores

## 🐛 Troubleshooting

### Build Fails
```bash
# Clean and retry
flutter clean
flutter pub get
flutter build web --release
```

### "Failed to load resource" Errors
- Check `--base-href` matches your repo structure
- Should be `/flutter_mate/` for github.io/flutter_mate

### Service Worker Not Working
- Ensure `--pwa-strategy` flag is used
- Check browser console for errors
- Try hard refresh (Ctrl+Shift+R)

### Blank Page on GitHub Pages
- Verify base-href is correct
- Check browser console for 404s
- Ensure `.nojekyll` file exists in web folder

### Slow Loading
- Check bundle size with `--analyze-size`
- Verify CanvasKit is loading from CDN
- Test network speed with DevTools

## 📱 Testing on Different Devices

### Desktop
```bash
# Chrome
flutter run -d chrome

# Edge
flutter run -d edge
```

### Mobile
1. Build and deploy
2. Open on phone: https://youssefsalem582.github.io/flutter_mate/
3. Add to home screen (PWA)
4. Test offline functionality

## 🔄 Update Deployment

To update the live site:

1. Make your changes
2. Test locally
3. Commit and push:
```bash
git add .
git commit -m "feat: your update"
git push origin main
```
4. Wait 2-3 minutes for workflow to complete
5. Visit site - service worker updates automatically
6. Users get update on next visit (no cache clear needed)

## 📚 Additional Resources

- [GitHub Actions Workflow](.github/workflows/deploy.yml)
- [Web Performance Optimization](WEB_PERFORMANCE_OPTIMIZATION.md)
- [Flutter Web Deployment Docs](https://docs.flutter.dev/deployment/web)

---

**Ready to deploy! 🚀**

Your app is optimized for fast loading, offline support, and automatic updates.

