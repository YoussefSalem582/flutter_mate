# 🔐 API Keys Setup Guide

## 🎯 Overview

This guide explains how to securely manage API keys and sensitive configuration in your Flutter app.

---

## 📁 File Structure

```
lib/core/config/
├── api_keys.dart           ← YOUR ACTUAL KEYS (gitignored)
└── api_keys_example.dart   ← TEMPLATE (committed to Git)
```

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Create Your API Keys File

Copy the example file:

```powershell
Copy-Item lib/core/config/api_keys_example.dart lib/core/config/api_keys.dart
```

### Step 2: Get Your Firebase Keys

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **fir-3840b**
3. Click ⚙️ **Settings** → **Project Settings**
4. Scroll down to **"Your apps"** section

#### For Web App:
1. Click on your Web app (🌐 icon)
2. Scroll to **"SDK setup and configuration"**
3. Select **"Config"** radio button
4. Copy the values:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSy...",        ← firebaseApiKeyWeb
     authDomain: "...",
     projectId: "fir-3840b",      ← firebaseProjectId
     storageBucket: "...",         ← firebaseStorageBucket
     messagingSenderId: "...",     ← firebaseMessagingSenderIdWeb
     appId: "1:320880192368:web:..." ← firebaseAppIdWeb
   };
   ```

#### For Android App:
1. Click on your Android app (🤖 icon)
2. Find:
   - **App ID**: `1:320880192368:android:...`
   - **API Key**: In `google-services.json` → `current_key`

#### For iOS App (Optional):
1. Click on your iOS app (🍎 icon)
2. Download `GoogleService-Info.plist`
3. Find:
   - **API_KEY**: Your iOS API key
   - **GOOGLE_APP_ID**: Your iOS app ID

### Step 3: Fill in Your Keys

Open `lib/core/config/api_keys.dart` and replace placeholders:

```dart
class ApiKeys {
  ApiKeys._();

  // Replace these with your actual values from Firebase Console
  static const String firebaseApiKeyWeb = 'AIzaSyCPCEK_KS_3mYqVWWQvBW1QuaturMYvv68';
  static const String firebaseAppIdWeb = '1:320880192368:web:3c9d8e1cd3eff3ef5efdb5';
  static const String firebaseMessagingSenderIdWeb = '320880192368';
  static const String firebaseProjectId = 'fir-3840b';
  static const String firebaseStorageBucket = 'fir-3840b.appspot.com';
  
  static const String firebaseApiKeyAndroid = 'AIzaSyCfwUtmBwVxaJZbJLOsc3X2w3JWc50oDyg';
  static const String firebaseAppIdAndroid = '1:320880192368:android:54d1937257d7ec255efdb5';
  
  // Keep these as placeholders if you haven't set up iOS yet
  static const String firebaseApiKeyIos = 'YOUR_FIREBASE_IOS_API_KEY';
  static const String firebaseAppIdIos = 'YOUR_FIREBASE_IOS_APP_ID';

  // Optional: Add these later
  static const String googleClientIdWeb = 'YOUR_GOOGLE_CLIENT_ID_WEB';
  static const String googleClientIdAndroid = 'YOUR_GOOGLE_CLIENT_ID_ANDROID';
  static const String googleClientIdIos = 'YOUR_GOOGLE_CLIENT_ID_IOS';

  static const String googleAnalyticsId = 'YOUR_ANALYTICS_ID';
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
  
  static const bool isProduction = false;
  static const String environment = isProduction ? 'production' : 'development';

  static bool get isConfigured {
    return firebaseApiKeyWeb != 'YOUR_FIREBASE_WEB_API_KEY' &&
           firebaseProjectId != 'YOUR_PROJECT_ID';
  }

  static void validate() {
    if (!isConfigured) {
      throw Exception('API Keys not configured!');
    }
  }
}
```

### Step 4: Verify It's Ignored

Check that your keys file is gitignored:

```powershell
git status
```

You should **NOT** see `lib/core/config/api_keys.dart` in the list.

✅ If it doesn't appear, you're good!
❌ If it appears, check your `.gitignore` file.

---

## 🔒 Security Best Practices

### ✅ DO:
- ✅ Keep `api_keys.dart` in `.gitignore`
- ✅ Use different keys for development and production
- ✅ Rotate keys regularly
- ✅ Share keys only through secure channels (1Password, LastPass, etc.)
- ✅ Use Firebase Security Rules to restrict access

### ❌ DON'T:
- ❌ **NEVER** commit `api_keys.dart` to Git
- ❌ **NEVER** share keys in screenshots or videos
- ❌ **NEVER** hardcode keys directly in your UI code
- ❌ **NEVER** post keys in issues, PRs, or forums

---

## 🛠️ Usage in Code

### Import the API keys:

```dart
import 'package:flutter_mate/core/config/api_keys.dart';

void main() async {
  // Validate keys are configured
  ApiKeys.validate();
  
  // Use the keys
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: ApiKeys.firebaseApiKeyWeb,
      appId: ApiKeys.firebaseAppIdWeb,
      messagingSenderId: ApiKeys.firebaseMessagingSenderIdWeb,
      projectId: ApiKeys.firebaseProjectId,
      storageBucket: ApiKeys.firebaseStorageBucket,
    ),
  );
}
```

### Check environment:

```dart
if (ApiKeys.isProduction) {
  // Use production endpoints
} else {
  // Use development endpoints
}
```

---

## 📋 Getting Other API Keys

### Google Sign-In Client ID:
1. Firebase Console → Authentication → Sign-in method
2. Click **Google**
3. Click **"Web SDK configuration"**
4. Copy **Web client ID**

### OpenAI API Key (for AI features):
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up / Log in
3. Go to [API Keys](https://platform.openai.com/api-keys)
4. Click **"Create new secret key"**
5. Copy and save immediately (shown only once!)

### Stripe API Key (for payments):
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Sign up / Log in
3. Go to **Developers** → **API Keys**
4. Use **Test Mode** for development
5. Copy **Publishable key** (starts with `pk_test_`)

---

## 🔄 For Team Members

When someone clones the repository:

### Step 1: Check for api_keys.dart
```powershell
Test-Path lib/core/config/api_keys.dart
```

### Step 2: If it doesn't exist:
```powershell
# Copy the example
Copy-Item lib/core/config/api_keys_example.dart lib/core/config/api_keys.dart

# Open and fill in keys (get from team lead)
code lib/core/config/api_keys.dart
```

### Step 3: Get keys from team:
- Ask your team lead for the keys
- They should share via **secure channel** (1Password, LastPass, etc.)
- **NEVER via email or Slack!**

---

## 🚨 What If Keys Are Leaked?

If you accidentally commit API keys to Git:

### Step 1: Revoke compromised keys immediately
1. Go to Firebase Console
2. Regenerate API keys
3. Update your local `api_keys.dart`

### Step 2: Remove from Git history
```powershell
# Remove the file from Git history
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch lib/core/config/api_keys.dart" --prune-empty --tag-name-filter cat -- --all

# Force push (be careful!)
git push origin --force --all
```

### Step 3: Add to .gitignore
Make sure `lib/core/config/api_keys.dart` is in `.gitignore`.

### Step 4: Notify your team
Let everyone know to update their keys.

---

## 📊 Different Environments

### Development (default):
```dart
static const bool isProduction = false;
```

### Production:
```dart
static const bool isProduction = true;
```

### Create separate files for each:
```
lib/core/config/
├── api_keys.dart           ← Current environment
├── api_keys_dev.dart       ← Development keys
├── api_keys_prod.dart      ← Production keys
└── api_keys_example.dart   ← Template
```

Switch between them:
```powershell
# Use development keys
Copy-Item lib/core/config/api_keys_dev.dart lib/core/config/api_keys.dart

# Use production keys
Copy-Item lib/core/config/api_keys_prod.dart lib/core/config/api_keys.dart
```

---

## ✅ Checklist

Before deploying:

- [ ] `api_keys.dart` is in `.gitignore`
- [ ] `api_keys.dart` is NOT in Git history
- [ ] All placeholder values are replaced with real keys
- [ ] Production keys are different from development keys
- [ ] Firebase Security Rules are configured
- [ ] API keys are documented in team's password manager
- [ ] Team members have access to keys via secure channel

---

## 🐛 Troubleshooting

### Error: "API Keys not configured"
**Solution:** 
1. Make sure `lib/core/config/api_keys.dart` exists
2. Check that placeholder values are replaced
3. Verify `firebaseProjectId != 'YOUR_PROJECT_ID'`

### Error: "Bad API key"
**Solution:**
1. Verify keys are copied correctly (no extra spaces)
2. Check that you're using the right key (Web vs Android)
3. Regenerate keys in Firebase Console

### Git is tracking api_keys.dart
**Solution:**
```powershell
# Remove from Git but keep local file
git rm --cached lib/core/config/api_keys.dart

# Commit the removal
git commit -m "Remove api_keys.dart from tracking"

# Verify .gitignore includes the file
```

---

## 📚 Additional Resources

- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/basics)
- [Securing API Keys in Flutter](https://docs.flutter.dev/deployment/obfuscate)
- [Git Secrets Management](https://git-secret.io/)

---

## 🎉 You're All Set!

Your API keys are now:
- ✅ Secure (not in Git)
- ✅ Organized (in dedicated file)
- ✅ Easy to manage (example file for team)
- ✅ Production-ready (environment support)

Happy coding! 🚀
