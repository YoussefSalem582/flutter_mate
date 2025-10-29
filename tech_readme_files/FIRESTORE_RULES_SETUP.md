# Firestore Security Rules Setup

## Issue: Permission Denied Errors

If you're seeing errors like:
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

This means your Firestore security rules need to be updated.

## Quick Fix

### Method 1: Firebase Console (Recommended)

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Select your project** (flutter_mate)
3. **Navigate to Firestore Database**:
   - Click "Firestore Database" in the left sidebar
   - Click on the "Rules" tab
4. **Copy and paste the rules** from `firestore.rules` file in the project root
5. **Click "Publish"** to deploy the rules

### Method 2: Firebase CLI

If you have Firebase CLI installed:

```bash
# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

## What These Rules Do

### ✅ Allowed Operations

- **Assessment Questions**: All authenticated users can READ questions
- **Skill Assessments**: Users can READ/WRITE their own assessment results
- **User Data**: Users can READ/WRITE their own user data and progress
- **Analytics**: Users can READ/WRITE their own analytics data
- **Lessons**: All authenticated users can READ lessons

### ❌ Restricted Operations

- **Assessment Questions**: Only admins can write/modify questions (set manually in Console)
- **Lessons**: Only admins can write/modify lessons
- **Other Users' Data**: Users cannot access other users' personal data

## Testing the Rules

After updating, test by:

1. **Restart your Flutter app**
2. **Sign in with a valid account**
3. **Navigate to Skill Assessment** - should load questions
4. **Check Analytics Dashboard** - should load data

## Temporary Development Rules (NOT for production!)

If you want to test quickly during development, you can use:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **Warning**: These rules allow any authenticated user to read/write all data. Only use for development!

## Adding Sample Assessment Questions

Since assessment questions require data in Firestore, you need to add them manually:

### Via Firebase Console:

1. Go to **Firestore Database** > **Data** tab
2. Click **Start collection**
3. Collection ID: `assessment_questions`
4. Add documents with this structure:

```json
{
  "id": "flutter_basics_1",
  "question": "What is Flutter?",
  "options": [
    "A mobile development framework",
    "A programming language",
    "A database",
    "An IDE"
  ],
  "correctAnswer": 0,
  "category": "Flutter Basics",
  "difficulty": "easy",
  "points": 10,
  "explanation": "Flutter is an open-source UI software development kit created by Google."
}
```

### Sample Questions Script

You can also create a script to populate sample questions. See `FIRESTORE_SETUP.md` for more details.

## Common Issues

### Issue: "Missing or insufficient permissions"
**Solution**: Update Firestore rules as described above

### Issue: Questions not loading
**Solution**: 
1. Check Firestore rules are deployed
2. Verify `assessment_questions` collection exists
3. Ensure user is authenticated
4. Check internet connection

### Issue: Assessment crashes with RangeError
**Solution**: Already fixed in the code - the app now handles empty question lists gracefully

## Next Steps

1. ✅ Update Firestore security rules
2. ✅ Add sample assessment questions to Firestore
3. ✅ Restart the app and test
4. ✅ Create more assessment questions for different categories

For more details, see: `tech_readme_files/FIRESTORE_SETUP.md`
