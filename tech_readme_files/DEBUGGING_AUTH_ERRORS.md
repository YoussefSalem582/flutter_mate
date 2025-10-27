# Debugging Firebase Authentication Errors on GitHub Pages

## Quick Debugging Steps

### 1. Check Browser Console for Detailed Errors

1. Open your deployed app: `https://youssefsalem582.github.io/flutter_mate/`
2. Press **F12** to open Developer Tools
3. Click on the **Console** tab
4. Clear the console (trash icon)
5. Try to sign in or sign up
6. Look for error messages in red

You should now see detailed error messages like:
- `FirebaseAuthException during sign in: [ERROR_CODE] - [ERROR_MESSAGE]`
- The error code will help identify the exact issue

### 2. Common Firebase Auth Errors on GitHub Pages

#### Error: `auth/unauthorized-domain`
**Cause:** Your GitHub Pages domain is not authorized in Firebase Console

**Solution:**
1. Go to [Firebase Console](https://console.firebase.google.com/project/fir-3840b/authentication/settings)
2. Scroll to **Authorized domains**
3. Click **Add domain**
4. Add: `youssefsalem582.github.io`
5. Click **Add**
6. Refresh your app and try again (no rebuild needed)

#### Error: `auth/api-key-not-valid` or `auth/invalid-api-key`
**Cause:** API key is restricted and doesn't allow requests from your domain

**Solution:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **fir-3840b**
3. Navigate to **APIs & Services** → **Credentials**
4. Find your Web API key (starts with `AIzaSyCPCEK_KS_3mYqVWWQvBW1QuaturMYvv68`)
5. Click **Edit** (pencil icon)
6. Under **Website restrictions**, add:
   - `https://youssefsalem582.github.io/*`
7. Click **Save**
8. Wait 5 minutes for changes to propagate

#### Error: `auth/operation-not-allowed`
**Cause:** Email/Password authentication is not enabled

**Solution:**
1. Go to [Firebase Console](https://console.firebase.google.com/project/fir-3840b/authentication/providers)
2. Click **Sign-in method** tab
3. Click on **Email/Password**
4. Toggle **Enable**
5. Click **Save**

#### Error: `auth/network-request-failed`
**Cause:** Network connectivity issue or CORS problem

**Solution:**
1. Check your internet connection
2. Try a different browser
3. Clear browser cache and cookies
4. Verify Firebase is not experiencing outages: https://status.firebase.google.com/

#### Error: `auth/app-not-authorized`
**Cause:** Your Firebase app is not authorized for this domain

**Solution:**
1. Verify your Firebase config in `web/index.html` matches Firebase Console
2. Check that the `apiKey`, `authDomain`, `projectId`, and `appId` are correct
3. Compare values in Firebase Console → Project Settings → General

### 3. Verify Firebase Configuration

#### Check Firebase Console Settings

1. **Project Overview** → **Project settings**
   - Verify your web app is registered
   - Check the config values

2. **Authentication** → **Settings** → **Authorized domains**
   - Ensure `youssefsalem582.github.io` is listed
   - Also ensure `fir-3840b.firebaseapp.com` is listed

3. **Authentication** → **Sign-in method**
   - Verify **Email/Password** is enabled
   - Verify **Google** is enabled (if using Google Sign-In)

#### Verify web/index.html Configuration

Your `web/index.html` should have:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyCPCEK_KS_3mYqVWWQvBW1QuaturMYvv68",
  authDomain: "fir-3840b.firebaseapp.com",
  projectId: "fir-3840b",
  storageBucket: "fir-3840b.firebasestorage.app",
  messagingSenderId: "320880192368",
  appId: "1:320880192368:web:3c9d8e1cd3eff3ef5efdb5",
  measurementId: "G-2HMTMF3J0Z"
};
```

### 4. After Making Changes

1. **If you changed Firebase Console settings:**
   - No rebuild needed
   - Just refresh the browser
   - Wait 5 minutes for Google Cloud changes to propagate

2. **If you changed code:**
   - Rebuild: `flutter build web --release`
   - Commit and push to GitHub
   - Wait for GitHub Pages deployment (1-2 minutes)

### 5. Testing Checklist

- [ ] Added `youssefsalem582.github.io` to Firebase authorized domains
- [ ] Verified Email/Password is enabled in Firebase Console
- [ ] Checked API key restrictions (if any)
- [ ] Cleared browser cache
- [ ] Checked browser console for detailed error messages
- [ ] Verified Firebase config in web/index.html is correct
- [ ] Tested in incognito/private window
- [ ] Tried a different browser

### 6. Get Help

If errors persist after following these steps:

1. **Copy the exact error from browser console**
2. **Take a screenshot of the error**
3. **Check Firebase Console → Authentication → Users**
   - Are users being created?
   - This tells you if auth is working but there's an app error

4. **Common issues:**
   - Firestore rules blocking user profile creation
   - Missing Firestore indexes
   - Email verification redirect URL not authorized

### 7. Firestore Rules

If users are being created but you see Firestore errors:

1. Go to Firebase Console → Firestore Database → Rules
2. Ensure rules allow user creation:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
  }
}
```

## Current Error Investigation

Based on the updated code, when you try to sign in/up now, you should see:
- Print statements in the console showing the exact error code
- The error message will include the Firebase error code and message
- Example: `An error occurred. Please try again. (Error: auth/unauthorized-domain - This domain is not authorized...)`

**Next Step:** Try signing in again and copy the exact error message from the browser console.
