# Web Optimization Quick Reference Card

Quick lookup for Flutter web optimization flags and configurations.

## 🚀 Build Command (Full Optimized)

```bash
flutter build web --release \
  --base-href /flutter_mate/ \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --tree-shake-icons \
  --no-source-maps \
  --dart-define=PRODUCTION=true
```

## 🎯 Flag Reference

| Flag | Purpose | Savings/Benefit |
|------|---------|-----------------|
| `--release` | Production build | 70-80% size reduction |
| `--web-renderer canvaskit` | Use Skia rendering | Better UI performance |
| `--pwa-strategy offline-first` | Enable service worker | Offline support + caching |
| `--tree-shake-icons` | Remove unused icons | 100-400 KB reduction |
| `--no-source-maps` | Skip source maps | 30-50% size reduction |
| `--base-href /flutter_mate/` | Set base URL | Required for GitHub Pages |
| `--dart-define=KEY=value` | Pass environment vars | Secure API keys |

## 📊 Performance Metrics

### Target Performance
```
First Load:     2-4 seconds (4G)
Subsequent:     < 1 second
Bundle Size:    3-5 MB (including CanvasKit)
Lighthouse:     > 90 (all categories)
```

### File Sizes (Approximate)
```
main.dart.js:           800 KB - 2 MB (gzipped: 200-500 KB)
CanvasKit WASM:         2-3 MB (cached permanently)
Assets:                 Varies (images, fonts)
Total First Load:       3-5 MB
Total Cached:           < 100 KB on repeat visits
```

## 🗂️ Caching Strategy

| Resource | Cache Duration | Revalidation |
|----------|----------------|--------------|
| HTML files | 1 hour | Must revalidate |
| JavaScript | 1 year | Immutable |
| Assets | 1 year | Immutable |
| CanvasKit | 1 year | Immutable |
| Service Worker | 0 seconds | Always fresh |

## 🔧 Quick Commands

### Build & Test
```bash
# Build
flutter build web --release --web-renderer canvaskit --pwa-strategy offline-first --tree-shake-icons

# Test locally
cd build/web && python -m http.server 8000

# Analyze size
flutter build web --analyze-size
```

### Scripts
```bash
# Windows
.\build-web-optimized.ps1

# Linux/Mac
./build-web-optimized.sh
chmod +x build-web-optimized.sh  # First time only
```

### Deploy
```bash
git add .
git commit -m "build: optimize web"
git push origin main
```

## 🎨 Renderer Comparison

| Renderer | Size | Performance | Compatibility |
|----------|------|-------------|---------------|
| **canvaskit** | ~5 MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| html | ~2 MB | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| auto | Varies | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Recommendation:** Use `canvaskit` for best performance and visual consistency.

## 📱 PWA Strategies

| Strategy | Use Case | Offline Support |
|----------|----------|-----------------|
| **offline-first** | Apps with stable content | ✅ Full |
| none | Development only | ❌ None |

**Recommendation:** Always use `offline-first` for production.

## 🔍 Debugging

### Check Build Output
```bash
ls -lh build/web/
du -sh build/web/*
```

### Verify Service Worker
```javascript
// Browser console
navigator.serviceWorker.getRegistrations()
  .then(regs => console.log(regs));
```

### Test Offline
```
1. Open DevTools (F12)
2. Application → Service Workers
3. Check "Offline"
4. Refresh page
```

### Check Cache
```
1. DevTools → Application
2. Cache Storage → flutter-app-cache
3. View cached files
```

## 📈 Optimization Checklist

Before deploying:
- [ ] Built with `--release`
- [ ] Using `--web-renderer canvaskit`
- [ ] Enabled `--pwa-strategy offline-first`
- [ ] Applied `--tree-shake-icons`
- [ ] Removed source maps (`--no-source-maps`)
- [ ] Set correct `--base-href`
- [ ] Tested locally
- [ ] Verified service worker
- [ ] Checked Lighthouse scores
- [ ] Tested offline functionality

## 🐛 Common Issues

### Issue: App shows 404
**Solution:** Check `--base-href` matches GitHub Pages path

### Issue: Blank page
**Solution:** Hard refresh (Ctrl+Shift+R) or check browser console

### Issue: Not working offline
**Solution:** Verify service worker is registered and active

### Issue: Slow initial load
**Solution:** Normal for first visit; check bundle size with `--analyze-size`

### Issue: Cache not updating
**Solution:** Service worker updates automatically within 24 hours

## 📚 Resources

- Full docs: [WEB_PERFORMANCE_OPTIMIZATION.md](WEB_PERFORMANCE_OPTIMIZATION.md)
- Deployment: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- Flutter docs: https://docs.flutter.dev/deployment/web

## 🎯 One-Line Build Commands

### Development
```bash
flutter build web
```

### Production (Basic)
```bash
flutter build web --release --web-renderer canvaskit
```

### Production (Full)
```bash
flutter build web --release --web-renderer canvaskit --pwa-strategy offline-first --tree-shake-icons --no-source-maps
```

### With Base Href (GitHub Pages)
```bash
flutter build web --release --base-href /flutter_mate/ --web-renderer canvaskit --pwa-strategy offline-first --tree-shake-icons
```

---

**Quick Tip:** Save this page as a bookmark for quick reference! 🔖

