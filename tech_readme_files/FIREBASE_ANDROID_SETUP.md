# 🔥 Firebase Android Setup Guide

## ✅ What's Been Configured

I've updated your Android build files to support Firebase:

### 1. Root-level `build.gradle.kts` ✅
- Added Google Services plugin (version 4.4.4)

### 2. App-level `build.gradle.kts` ✅
- Applied Google Services plugin
- Added Firebase BoM (version 34.4.0)
- Added Firebase dependencies:
  - Firebase Analytics
  - Firebase Authentication
  - Cloud Firestore

---

## 📋 Next Steps

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `flutter-mate`
4. Enable Google Analytics (optional but recommended)
5. Click **"Create project"**

### Step 2: Add Android App to Firebase
1. In Firebase Console, click the **Android** icon
2. Enter your package name: `com.example.flutter_mate`
   - ⚠️ This must match the `applicationId` in your `android/app/build.gradle.kts`
3. Enter app nickname (optional): `Flutter Mate Android`
4. Enter SHA-1 certificate (optional for now, required for Google Sign-In)
5. Click **"Register app"**

### Step 3: Download Configuration File
1. Download the `google-services.json` file
2. **Place it in:** `android/app/google-services.json`
   ```
   flutter_mate/
   └── android/
       └── app/
           └── google-services.json  ← Put it here!
   ```
3. ⚠️ **Important:** Never commit this file to public repositories!

### Step 4: Get SHA-1 Certificate (for Google Sign-In)

#### On Windows (PowerShell):
```powershell
cd $env:USERPROFILE\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### On Mac/Linux:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA-1** fingerprint and add it to Firebase:
1. Go to Firebase Console → Project Settings
2. Scroll to "Your apps" → Select your Android app
3. Click "Add fingerprint"
4. Paste SHA-1 and save

### Step 5: Enable Authentication Methods

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable these providers:

#### Email/Password:
- Click "Email/Password"
- Toggle **"Enable"**
- Click "Save"

#### Google:
- Click "Google"
- Toggle **"Enable"**
- Select support email
- Click "Save"

#### Anonymous:
- Click "Anonymous"
- Toggle **"Enable"**
- Click "Save"

### Step 6: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
4. Choose a location (preferably close to your users)
5. Click **"Enable"**

### Step 7: Set Firestore Security Rules

Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles
      allow read: if request.auth != null;
      // Users can only write to their own profile
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Analytics data
    match /analytics/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Forum discussions (for future community features)
    match /forum/{document=**} {
      // Anyone authenticated can read
      allow read: if request.auth != null;
      // Only authenticated users can write
      allow write: if request.auth != null;
    }
    
    // Quiz results
    match /quiz_results/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Step 8: Update Your main.dart

Make sure your `main.dart` initializes Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Auth Controller
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Mate',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      
      // Initial route - check auth state
      initialRoute: '/login',
      
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/signup',
          page: () => const SignUpPage(),
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordPage(),
        ),
        GetPage(
          name: '/email-verification',
          page: () => const EmailVerificationPage(),
        ),
        // Your existing routes
        GetPage(
          name: '/home',
          page: () => const HomePage(), // Your existing home page
        ),
      ],
    );
  }
}
```

### Step 9: Sync and Build

After placing `google-services.json`:

```powershell
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build the app
flutter build apk --debug

# Or run directly
flutter run
```

---

## 🔍 Verify Setup

1. **Check firebase_core initializes:**
   - Run the app
   - Check console logs for Firebase initialization

2. **Test Authentication:**
   - Try signing up with email/password
   - Try Google Sign-In
   - Try guest mode

3. **Check Firestore:**
   - After signing up, go to Firebase Console → Firestore
   - You should see a new document in the `users` collection

---

## 🐛 Troubleshooting

### Error: "google-services.json not found"
**Solution:** Ensure the file is in `android/app/` directory

### Error: "Default FirebaseApp is not initialized"
**Solution:** Make sure `await Firebase.initializeApp()` is called in `main()`

### Google Sign-In not working
**Solution:** 
1. Add SHA-1 certificate to Firebase Console
2. Download new `google-services.json`
3. Rebuild the app

### Gradle sync failed
**Solution:**
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### MultiDex error
**Solution:** Add to `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    // ...
    multiDexEnabled = true
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

---

## 📱 Testing Checklist

- [ ] Firebase project created
- [ ] `google-services.json` downloaded and placed correctly
- [ ] Email/Password authentication enabled
- [ ] Google authentication enabled
- [ ] Anonymous authentication enabled
- [ ] Firestore database created
- [ ] Security rules updated
- [ ] App builds successfully
- [ ] Sign up with email works
- [ ] Email verification works
- [ ] Sign in with email works
- [ ] Google Sign-In works
- [ ] Guest mode works
- [ ] User data appears in Firestore

---

## 🎯 What You'll See

After successful setup:
1. **Login screen** with beautiful animations
2. **Sign up** creates user in Firebase Auth + Firestore
3. **Email verification** with auto-checking
4. **Google Sign-In** creates/logs in user
5. **Guest mode** for anonymous access
6. **User data** in Firestore under `/users/{userId}`

---

## 📂 File Locations

```
flutter_mate/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← Add this file!
│   │   └── build.gradle.kts      ✅ Updated
│   └── build.gradle.kts          ✅ Updated
├── lib/
│   ├── main.dart                 ⚠️ Update this
│   └── features/
│       └── auth/                 ✅ Complete
└── pubspec.yaml                  ✅ Updated
```

---

## 🚀 After Setup Complete

Once authentication is working, I can help you build:
1. **User Profile Page** - View and edit profile
2. **Analytics Dashboard** - Track learning progress
3. **Skill Assessment** - Initial evaluation quiz
4. **Community Forum** - Discussion boards
5. **Personalized Learning** - Custom recommendations

Let me know when you're ready to continue! 🎉
