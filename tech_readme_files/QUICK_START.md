# 🚀 Quick Start Guide - Flutter Mate with Firebase

## ✅ Setup Status

### Completed:
- ✅ Authentication system (UI + Controller + Service)
- ✅ Firebase dependencies added
- ✅ Android Firebase configuration
- ✅ Web Firebase configuration
- ✅ Firebase options file created
- ✅ All code errors fixed

### Pending:
- ⚠️ Add `google-services.json` to `android/app/`
- ⚠️ Enable auth methods in Firebase Console
- ⚠️ Create Firestore database
- ⚠️ Update `main.dart` with Firebase initialization

---

## 🔥 Quick Setup Commands

### 1. Clean and Get Dependencies
```powershell
flutter clean
flutter pub get
```

### 2. Run on Web (Chrome)
```powershell
flutter run -d chrome
```

### 3. Run on Android (after adding google-services.json)
```powershell
flutter run -d android
```

### 4. Build Release APK
```powershell
flutter build apk --release
```

### 5. Build Web Release
```powershell
flutter build web --release
```

---

## 📋 Firebase Console Checklist

Go to: https://console.firebase.google.com/project/fir-3840b

### Authentication Setup:
- [ ] Go to Authentication → Sign-in method
- [ ] Enable **Email/Password**
- [ ] Enable **Google**
- [ ] Enable **Anonymous**

### Firestore Setup:
- [ ] Go to Firestore Database
- [ ] Click "Create database"
- [ ] Choose "Start in test mode"
- [ ] Select location
- [ ] Update security rules (see FIREBASE_WEB_SETUP.md)

### Web App Authorized Domains:
- [ ] Go to Authentication → Settings → Authorized domains
- [ ] Ensure `localhost` is listed
- [ ] Add your production domain when deploying

---

## 📱 Testing Authentication

### Test Sign Up:
1. Run app: `flutter run -d chrome`
2. Click "Sign Up"
3. Enter username, email, password
4. Submit
5. Check email for verification link
6. Verify email
7. Sign in

### Test Google Sign-In:
1. Click "Continue with Google"
2. Select Google account
3. Should create user and navigate to home

### Test Guest Mode:
1. Click "Continue as Guest"
2. Should allow access without account

### Verify in Firebase:
1. Go to Firebase Console → Authentication → Users
2. Should see new users listed
3. Go to Firestore → users collection
4. Should see user documents

---

## 🗂️ File Locations Reference

```
Key Files to Check:

📄 lib/main.dart
   → Add Firebase.initializeApp() here

📄 lib/firebase_options.dart
   → Contains Firebase config (already created)

📄 web/index.html
   → Firebase SDK loaded here (already updated)

📄 android/app/google-services.json
   → ADD THIS FILE (download from Firebase Console)

📄 android/app/build.gradle.kts
   → Firebase plugins configured (already done)

📄 android/build.gradle.kts
   → Google services plugin added (already done)
```

---

## 💻 Sample main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
// Import your existing home page
import 'features/roadmap/presentation/pages/roadmap_page.dart'; // Or whatever your home is

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignUpPage()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordPage()),
        GetPage(name: '/email-verification', page: () => const EmailVerificationPage()),
        GetPage(name: '/home', page: () => const RoadmapPage()), // Your home page
      ],
    );
  }
}
```

---

## 🎯 Platform-Specific Commands

### Web Development:
```powershell
# Run in Chrome
flutter run -d chrome

# Run with web server (any browser)
flutter run -d web-server --web-port=8080

# Build for deployment
flutter build web --release
```

### Android Development:
```powershell
# List devices
flutter devices

# Run on connected device
flutter run

# Get SHA-1 for Google Sign-In
cd $env:USERPROFILE\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android

# Build APK
flutter build apk --release
```

---

## 🔍 Debugging Commands

### Check Flutter Doctor:
```powershell
flutter doctor -v
```

### Clear Cache:
```powershell
flutter clean
flutter pub get
```

### Check Dependencies:
```powershell
flutter pub outdated
```

### Analyze Code:
```powershell
flutter analyze
```

### Run Tests:
```powershell
flutter test
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `PHASE_3_IMPLEMENTATION_PLAN.md` | Complete feature roadmap |
| `PHASE_3_PROGRESS.md` | What's been built |
| `FIREBASE_ANDROID_SETUP.md` | Detailed Android Firebase guide |
| `FIREBASE_WEB_SETUP.md` | Detailed Web Firebase guide |
| `SETUP_COMPLETE.md` | Configuration summary |
| `QUICK_START.md` | This file - quick reference |

---

## 🎨 What You'll See

After running the app:

### Login Page:
- ✨ Smooth animations
- 🔐 Email/password login
- 🔵 Google Sign-In button
- 👤 Guest mode button
- 🔑 Forgot password link
- 📝 Sign up link

### Sign Up Page:
- Username field
- Email field
- Password field
- Confirm password field
- Form validation
- Google Sign-In option

### Email Verification:
- Auto-checking (every 3 seconds)
- Resend button (60-second cooldown)
- Manual check button
- Help dialog

### After Login:
- Navigate to home page
- User data in Firestore
- Session persisted

---

## 🐛 Troubleshooting

### "Firebase not initialized"
```dart
// Make sure this is in main():
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### "google-services.json not found"
```
Place file in: android/app/google-services.json
Then run: flutter clean && flutter pub get
```

### Google Sign-In not working
```
1. Add SHA-1 to Firebase Console
2. Download new google-services.json
3. Rebuild app
```

### Web CORS errors
```
1. Check Firebase Console → Authentication → Authorized domains
2. Add localhost
3. Wait 5 minutes for changes
```

---

## ✅ Pre-Flight Checklist

Before running:
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] Web Firebase config added to `web/index.html` ✅
- [ ] `firebase_options.dart` created ✅
- [ ] Android `build.gradle.kts` files updated ✅
- [ ] `google-services.json` added (for Android)
- [ ] Auth methods enabled in Firebase Console
- [ ] Firestore database created
- [ ] `main.dart` updated with Firebase.initializeApp()

---

## 🚀 Ready to Launch!

Once you complete the pending items:

```powershell
# For Web testing:
flutter run -d chrome

# For Android testing:
flutter run

# Check it works:
# 1. Sign up with email
# 2. Verify email
# 3. Sign in
# 4. Check Firestore for user data
```

🎉 **You're ready to build an amazing learning app!**

---

Need help? Check the detailed guides:
- Android: `FIREBASE_ANDROID_SETUP.md`
- Web: `FIREBASE_WEB_SETUP.md`
- Features: `PHASE_3_IMPLEMENTATION_PLAN.md`
