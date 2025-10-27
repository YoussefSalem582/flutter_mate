# API Tokenization Guide

## 🔐 Overview

The API keys in this project are now **tokenized** using Dart's `--dart-define` compilation constants. This allows you to:

✅ Use hardcoded fallback values for local development  
✅ Override keys with environment variables for CI/CD pipelines  
✅ Keep sensitive keys out of version control  
✅ Build different configurations without changing code  

---

## 📋 How It Works

### Default Behavior (Local Development)
```dart
// Uses hardcoded fallback values from api_keys.dart
flutter run
flutter build web
flutter build apk
```

### Override with Tokens (CI/CD / Production)
```dart
// Override specific keys at build time
flutter build web --dart-define=FIREBASE_API_KEY_WEB=your_actual_key_here
flutter build apk --dart-define=FIREBASE_API_KEY_ANDROID=your_actual_key_here
```

---

## 🚀 Usage Examples

### 1. Local Development (Default)
Just build normally - uses fallback values from `api_keys.dart`:

```bash
flutter run
flutter build web --release
flutter build apk --release
```

### 2. GitHub Actions / CI/CD

Create a workflow file (`.github/workflows/deploy.yml`):

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Build Web with Tokenized Keys
        env:
          FIREBASE_WEB_KEY: ${{ secrets.FIREBASE_API_KEY_WEB }}
        run: |
          flutter build web --release \
            --dart-define=FIREBASE_API_KEY_WEB=$FIREBASE_WEB_KEY \
            --dart-define=PRODUCTION=true
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### 3. Command Line with Multiple Keys

```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY_WEB=AIzaSy... \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_... \
  --dart-define=PRODUCTION=true
```

### 4. Using Environment Variables

Create a `.env` file (add to `.gitignore`):
```env
FIREBASE_API_KEY_WEB=AIzaSy...
FIREBASE_API_KEY_ANDROID=AIzaSy...
OPENAI_API_KEY=sk-...
```

Then load and build (requires `dotenv` or shell script):
```bash
#!/bin/bash
source .env
flutter build web --release \
  --dart-define=FIREBASE_API_KEY_WEB=$FIREBASE_API_KEY_WEB \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY
```

---

## 🔑 Available Tokens

### Firebase Configuration
| Token | Default Value | Usage |
|-------|---------------|-------|
| `FIREBASE_API_KEY_WEB` | From `api_keys.dart` | Web API key |
| `FIREBASE_API_KEY_ANDROID` | From `api_keys.dart` | Android API key |
| `FIREBASE_API_KEY_IOS` | Placeholder | iOS API key |
| `FIREBASE_APP_ID_IOS` | Placeholder | iOS app ID |

### Google Sign-In
| Token | Default Value | Usage |
|-------|---------------|-------|
| `GOOGLE_CLIENT_ID_WEB` | Placeholder | OAuth web client |
| `GOOGLE_CLIENT_ID_ANDROID` | Placeholder | OAuth Android client |
| `GOOGLE_CLIENT_ID_IOS` | Placeholder | OAuth iOS client |

### Third-Party Services
| Token | Default Value | Usage |
|-------|---------------|-------|
| `OPENAI_API_KEY` | Placeholder | OpenAI API access |
| `STRIPE_PUBLISHABLE_KEY` | Placeholder | Stripe payments |
| `RAZORPAY_KEY` | Placeholder | Razorpay payments |

### Environment
| Token | Default Value | Usage |
|-------|---------------|-------|
| `PRODUCTION` | `false` | Production mode flag |

---

## 🛡️ Security Best Practices

### ✅ DO:
- ✅ Use `--dart-define` for sensitive production keys
- ✅ Store secrets in GitHub Secrets for CI/CD
- ✅ Keep `.env` files in `.gitignore`
- ✅ Use different keys for dev/staging/prod environments
- ✅ Rotate keys regularly

### ❌ DON'T:
- ❌ Commit real API keys to version control
- ❌ Share `.env` files with real keys
- ❌ Use production keys in development
- ❌ Hardcode sensitive keys in public repositories
- ❌ Expose backend API keys in client code

---

## 📦 Build Scripts

### PowerShell Script (Windows)
Create `build-web.ps1`:
```powershell
# Load environment variables
$env:FIREBASE_KEY = "AIzaSy..."

# Build with tokens
flutter build web --release `
  --dart-define=FIREBASE_API_KEY_WEB=$env:FIREBASE_KEY `
  --dart-define=PRODUCTION=true

Write-Host "✅ Build complete!"
```

### Bash Script (Linux/Mac)
Create `build-web.sh`:
```bash
#!/bin/bash

# Load from .env file
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

# Build with tokens
flutter build web --release \
  --dart-define=FIREBASE_API_KEY_WEB=$FIREBASE_API_KEY_WEB \
  --dart-define=PRODUCTION=true

echo "✅ Build complete!"
```

---

## 🔍 Verification

Check which values are being used at runtime:

```dart
import 'package:flutter_mate/core/config/api_keys.dart';

void main() {
  print('Firebase Web Key: ${ApiKeys.firebaseApiKeyWeb}');
  print('Production Mode: ${ApiKeys.isProduction}');
  print('Environment: ${ApiKeys.environment}');
}
```

---

## 🐛 Troubleshooting

### Issue: Keys not being overridden
**Solution:** Ensure `--dart-define` flags come BEFORE the build command:
```bash
# ✅ Correct
flutter build web --dart-define=KEY=value --release

# ❌ Wrong
flutter build web --release --dart-define=KEY=value
```

### Issue: Still using hardcoded values
**Solution:** Do a clean build:
```bash
flutter clean
flutter pub get
flutter build web --dart-define=KEY=value --release
```

### Issue: GitHub Actions secrets not working
**Solution:** Check secrets are set in repository settings and properly referenced:
```yaml
env:
  MY_KEY: ${{ secrets.SECRET_NAME }}  # Correct
run: flutter build --dart-define=KEY=$MY_KEY
```

---

## 📚 Resources

- [Flutter --dart-define Documentation](https://flutter.dev/docs/development/tools/sdk/build-modes)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/basics)

---

## ✅ Current Configuration Status

| Platform | Status | Notes |
|----------|--------|-------|
| Web | ✅ Configured | Uses hardcoded fallback, override for production |
| Android | ✅ Configured | Uses hardcoded fallback, override for production |
| iOS | ⚠️ Not configured | Placeholder values, needs setup |
| Google Sign-In | ⚠️ Not configured | OAuth client IDs needed |
| OpenAI | ⚠️ Not configured | API key needed for AI features |
| Stripe | ⚠️ Not configured | Payment keys needed |

---

## 🎯 Quick Reference

**Build for local testing:**
```bash
flutter run
```

**Build for GitHub Pages:**
```bash
flutter build web --release --dart-define=PRODUCTION=true
```

**Build for production (all keys):**
```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY_WEB=your_key \
  --dart-define=OPENAI_API_KEY=your_key \
  --dart-define=PRODUCTION=true
```

**Check current configuration:**
```bash
flutter run --dart-define=PRODUCTION=true
# Check console output for ApiKeys values
```

---

## 💡 Pro Tips

1. **Use build flavors** for different environments (dev/staging/prod)
2. **Create shell scripts** to avoid typing long commands
3. **Document your secrets** in a secure password manager
4. **Use GitHub Secrets** for automated deployments
5. **Test locally** with production keys before deploying

---

**Last Updated:** October 28, 2025  
**Version:** 1.0.0
