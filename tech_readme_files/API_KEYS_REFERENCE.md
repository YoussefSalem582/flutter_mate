# 🔐 API Keys - Quick Reference

## ✅ Files Created

1. **`lib/core/config/api_keys.dart`** 
   - ✅ Your actual API keys (gitignored)
   - ❌ NEVER commit this file

2. **`lib/core/config/api_keys_example.dart`**
   - ✅ Template file (committed to Git)
   - ✅ Share this with team

3. **`.gitignore`** 
   - ✅ Updated to ignore api_keys.dart
   - ✅ Also ignores .env and secrets files

---

## 🚀 Quick Setup

### One-Time Setup:
```powershell
# Step 1: Copy the example file
Copy-Item lib/core/config/api_keys_example.dart lib/core/config/api_keys.dart

# Step 2: Edit with your keys
code lib/core/config/api_keys.dart

# Step 3: Verify it's gitignored
git status  # Should NOT show api_keys.dart
```

### Your Current Firebase Keys:
Based on your existing `firebase_options.dart`:

**Web:**
- API Key: `AIzaSyCPCEK_KS_3mYqVWWQvBW1QuaturMYvv68`
- App ID: `1:320880192368:web:3c9d8e1cd3eff3ef5efdb5`
- Project ID: `fir-3840b`
- Messaging Sender ID: `320880192368`

**Android:**
- API Key: `AIzaSyCfwUtmBwVxaJZbJLOsc3X2w3JWc50oDyg`
- App ID: `1:320880192368:android:54d1937257d7ec255efdb5`

---

## 📝 How to Use

### In your code:
```dart
import 'package:flutter_mate/core/config/api_keys.dart';

// Validate keys are set
ApiKeys.validate();

// Use the keys
final apiKey = ApiKeys.firebaseApiKeyWeb;
final projectId = ApiKeys.firebaseProjectId;

// Check environment
if (ApiKeys.isProduction) {
  // Production logic
} else {
  // Development logic
}
```

---

## 🔒 What's Gitignored

These files will **NEVER** be committed:
- `lib/core/config/api_keys.dart` ✅
- `*.env` files ✅
- `.env.local` files ✅
- `secrets.json` ✅
- `api_keys.json` ✅

---

## 🛡️ Security Checklist

- [x] Created `api_keys.dart` with placeholders
- [x] Created `api_keys_example.dart` as template
- [x] Added to `.gitignore`
- [x] Verified not tracked by Git
- [ ] Filled in actual Firebase keys
- [ ] Team members have secure access to keys
- [ ] Different keys for dev/prod (optional)

---

## 📚 Documentation

Full guide: `docs/API_KEYS_SETUP.md`

Topics covered:
- ✅ Complete setup instructions
- ✅ Getting Firebase keys
- ✅ Security best practices
- ✅ Team collaboration
- ✅ What to do if keys leak
- ✅ Environment management
- ✅ Troubleshooting

---

## 🎯 Next Steps

1. **Fill in your keys**: Edit `lib/core/config/api_keys.dart`
2. **Update firebase_options.dart**: Use keys from ApiKeys class (optional)
3. **Share with team**: Send `api_keys_example.dart` structure, keys via secure channel
4. **Set up production keys**: Create separate config for production

---

## ⚡ Quick Commands

```powershell
# Check if api_keys.dart exists
Test-Path lib/core/config/api_keys.dart

# View example file
code lib/core/config/api_keys_example.dart

# Edit your keys
code lib/core/config/api_keys.dart

# Verify gitignored
git status | Select-String "api_keys"  # Should be empty

# View documentation
code docs/API_KEYS_SETUP.md
```

---

🎉 **You're all set!** Your API keys are now secure and properly managed.
