# 🔥 Firestore Database Setup Guide

## 📋 Table of Contents
1. [Creating Firestore Database](#creating-firestore-database)
2. [Database Structure](#database-structure)
3. [Security Rules](#security-rules)
4. [Indexes](#indexes)
5. [Testing](#testing)

---

## 🎯 Creating Firestore Database

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **fir-3840b**

### Step 2: Create Database
1. Click **"Firestore Database"** in left menu
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
   - Test mode allows read/write for 30 days
   - We'll add proper rules after
4. Select location: **us-central** (or closest to you)
5. Click **"Enable"**

✅ Database created! Now let's set up the structure.

---

## 🏗️ Database Structure

### Overview
```
flutter_mate (Database)
├── users (Collection)
│   └── {userId} (Document)
│       ├── profile data
│       ├── preferences (Map)
│       └── stats (Map)
├── learning_paths (Collection)
│   └── {pathId} (Document)
│       ├── path details
│       └── milestones (Array)
├── analytics (Collection)
│   └── {userId} (Document)
│       └── sessions (Subcollection)
├── quiz_results (Collection)
│   └── {resultId} (Document)
├── study_sessions (Collection)
│   └── {sessionId} (Document)
├── forum_posts (Collection)
│   └── {postId} (Document)
│       └── comments (Subcollection)
├── achievements (Collection)
│   └── {achievementId} (Document)
└── user_achievements (Collection)
    └── {userId} (Document)
```

---

## 📦 Collection Details

### 1. `users` Collection
**Purpose**: Store user profiles and authentication data

**Document ID**: Firebase Auth UID (auto from AuthService)

**Structure**:
```json
{
  "id": "string (Firebase Auth UID)",
  "email": "string",
  "username": "string (unique)",
  "displayName": "string (optional)",
  "photoURL": "string (optional)",
  "bio": "string (optional)",
  "authProvider": "string (email|google|apple|anonymous)",
  "emailVerified": "boolean",
  "phoneNumber": "string (optional)",
  
  "subscription": {
    "tier": "string (free|premium|pro)",
    "expiresAt": "timestamp (optional)"
  },
  
  "learningStats": {
    "lessonsCompleted": "number",
    "totalXP": "number",
    "currentStreak": "number",
    "longestStreak": "number",
    "lastStudyDate": "timestamp",
    "categoryProgress": {
      "flutter_basics": "number (0-100)",
      "widgets": "number (0-100)",
      "state_management": "number (0-100)",
      "navigation": "number (0-100)",
      "animations": "number (0-100)",
      "api_integration": "number (0-100)"
    }
  },
  
  "communityStats": {
    "reputationPoints": "number",
    "questionsAsked": "number",
    "answersGiven": "number",
    "helpfulVotes": "number",
    "badges": ["array of badge IDs"]
  },
  
  "preferences": {
    "darkMode": "boolean",
    "language": "string (en|es|ar|fr)",
    "notificationsEnabled": "boolean",
    "emailNotifications": "boolean",
    "studyReminders": "boolean",
    "dailyGoalMinutes": "number",
    "preferredCategories": ["array of category IDs"]
  },
  
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Example**:
```json
{
  "id": "abc123xyz",
  "email": "john@example.com",
  "username": "john_flutter",
  "displayName": "John Doe",
  "authProvider": "email",
  "emailVerified": true,
  "subscription": {
    "tier": "free"
  },
  "learningStats": {
    "lessonsCompleted": 15,
    "totalXP": 450,
    "currentStreak": 5,
    "longestStreak": 12,
    "categoryProgress": {
      "flutter_basics": 80,
      "widgets": 60,
      "state_management": 40
    }
  },
  "preferences": {
    "darkMode": true,
    "language": "en",
    "dailyGoalMinutes": 30
  },
  "createdAt": "2025-10-27T10:00:00Z",
  "lastLoginAt": "2025-10-27T14:30:00Z"
}
```

---

### 2. `learning_paths` Collection
**Purpose**: Personalized learning paths for each user

**Document ID**: Auto-generated or `{userId}_default`

**Structure**:
```json
{
  "id": "string",
  "userId": "string (reference to users)",
  "name": "string",
  "description": "string",
  "difficulty": "string (beginner|intermediate|advanced)",
  "estimatedDuration": "number (hours)",
  "currentStep": "number",
  "totalSteps": "number",
  "completionPercentage": "number (0-100)",
  
  "milestones": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "lessonIds": ["array of lesson IDs"],
      "quizIds": ["array of quiz IDs"],
      "completed": "boolean",
      "completedAt": "timestamp (optional)"
    }
  ],
  
  "recommendations": [
    {
      "lessonId": "string",
      "reason": "string",
      "priority": "number (1-10)"
    }
  ],
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 3. `analytics` Collection + `sessions` Subcollection
**Purpose**: Track user study sessions and analytics

**Parent Document ID**: userId

**Parent Structure**:
```json
{
  "userId": "string",
  "totalStudyTime": "number (minutes)",
  "averageSessionDuration": "number (minutes)",
  "mostActiveHour": "number (0-23)",
  "mostActiveDay": "string (monday-sunday)",
  "updatedAt": "timestamp"
}
```

**Subcollection `sessions` Structure**:
```json
{
  "id": "string (auto)",
  "userId": "string",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "duration": "number (minutes)",
  "category": "string",
  "lessonsViewed": ["array of lesson IDs"],
  "quizzesCompleted": ["array of quiz IDs"],
  "xpEarned": "number",
  "createdAt": "timestamp"
}
```

---

### 4. `quiz_results` Collection
**Purpose**: Store quiz attempts and scores

**Document ID**: Auto-generated

**Structure**:
```json
{
  "id": "string (auto)",
  "userId": "string",
  "quizId": "string",
  "category": "string",
  "difficulty": "string (easy|medium|hard)",
  
  "score": "number",
  "totalQuestions": "number",
  "correctAnswers": "number",
  "incorrectAnswers": "number",
  "skippedQuestions": "number",
  "percentage": "number (0-100)",
  
  "timeTaken": "number (seconds)",
  "averageTimePerQuestion": "number (seconds)",
  
  "answers": [
    {
      "questionId": "string",
      "selectedAnswer": "number",
      "correctAnswer": "number",
      "isCorrect": "boolean",
      "timeTaken": "number (seconds)"
    }
  ],
  
  "xpEarned": "number",
  "passed": "boolean",
  
  "createdAt": "timestamp"
}
```

---

### 5. `study_sessions` Collection
**Purpose**: Track individual study sessions (legacy, consider using analytics/sessions)

**Document ID**: Auto-generated

**Structure**:
```json
{
  "id": "string (auto)",
  "userId": "string",
  "lessonId": "string",
  "category": "string",
  "startedAt": "timestamp",
  "completedAt": "timestamp (optional)",
  "duration": "number (minutes)",
  "progress": "number (0-100)",
  "notes": "string (optional)",
  "createdAt": "timestamp"
}
```

---

### 6. `forum_posts` Collection + `comments` Subcollection
**Purpose**: Community forum for questions and discussions

**Parent Document ID**: Auto-generated

**Parent Structure**:
```json
{
  "id": "string (auto)",
  "userId": "string",
  "username": "string",
  "userPhotoURL": "string (optional)",
  
  "title": "string",
  "content": "string (markdown)",
  "category": "string",
  "tags": ["array of strings"],
  
  "views": "number",
  "upvotes": "number",
  "downvotes": "number",
  "votedBy": {
    "userId": "number (1 for upvote, -1 for downvote)"
  },
  
  "commentsCount": "number",
  "hasAcceptedAnswer": "boolean",
  "acceptedAnswerId": "string (optional)",
  
  "isPinned": "boolean",
  "isClosed": "boolean",
  "isDeleted": "boolean",
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Subcollection `comments` Structure**:
```json
{
  "id": "string (auto)",
  "postId": "string",
  "userId": "string",
  "username": "string",
  "userPhotoURL": "string (optional)",
  
  "content": "string (markdown)",
  
  "upvotes": "number",
  "downvotes": "number",
  "votedBy": {
    "userId": "number (1 for upvote, -1 for downvote)"
  },
  
  "isAccepted": "boolean",
  "isEdited": "boolean",
  "isDeleted": "boolean",
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 7. `achievements` Collection
**Purpose**: Define available achievements/badges

**Document ID**: achievement slug (e.g., "first_lesson", "week_streak")

**Structure**:
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "iconUrl": "string",
  "category": "string (learning|community|streak|milestone)",
  "difficulty": "string (bronze|silver|gold|platinum)",
  "xpReward": "number",
  "requirements": {
    "type": "string (lessons_completed|streak|quiz_score|etc)",
    "target": "number"
  },
  "isSecret": "boolean",
  "createdAt": "timestamp"
}
```

**Example**:
```json
{
  "id": "first_lesson",
  "name": "First Steps",
  "description": "Complete your first lesson",
  "iconUrl": "https://...",
  "category": "learning",
  "difficulty": "bronze",
  "xpReward": 10,
  "requirements": {
    "type": "lessons_completed",
    "target": 1
  },
  "isSecret": false
}
```

---

### 8. `user_achievements` Collection
**Purpose**: Track which achievements each user has earned

**Document ID**: userId

**Structure**:
```json
{
  "userId": "string",
  "achievements": [
    {
      "achievementId": "string",
      "earnedAt": "timestamp",
      "progress": "number (0-100)"
    }
  ],
  "totalXPFromAchievements": "number",
  "updatedAt": "timestamp"
}
```

---

## 🔒 Security Rules

After testing, replace test mode rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles (for forum, leaderboards)
      allow read: if true;
      // Only the user can create/update their own profile
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Learning paths
    match /learning_paths/{pathId} {
      // Users can only read their own learning paths
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      // Users can create/update their own paths
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }
    
    // Analytics
    match /analytics/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
      
      // Sessions subcollection
      match /sessions/{sessionId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
    }
    
    // Quiz results
    match /quiz_results/{resultId} {
      // Users can read their own results
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      // Users can create their own results
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      // No updates or deletes (quiz results are immutable)
      allow update, delete: if false;
    }
    
    // Study sessions
    match /study_sessions/{sessionId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }
    
    // Forum posts
    match /forum_posts/{postId} {
      // Anyone can read posts
      allow read: if true;
      // Authenticated users can create posts
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      // Only post owner can update
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      // Only post owner can delete
      allow delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
      
      // Comments subcollection
      match /comments/{commentId} {
        allow read: if true;
        allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
        allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
        allow delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
      }
    }
    
    // Achievements (read-only for all users)
    match /achievements/{achievementId} {
      allow read: if true;
      allow write: if false; // Only admins via Firebase Console
    }
    
    // User achievements
    match /user_achievements/{userId} {
      allow read: if true; // Public for leaderboards
      allow write: if isOwner(userId);
    }
  }
}
```

### Applying Security Rules:
1. Go to Firebase Console → Firestore Database
2. Click **"Rules"** tab
3. Replace the rules with the above
4. Click **"Publish"**

---

## 📊 Indexes

Firestore will auto-create most indexes. You might need these composite indexes:

### Required Indexes:
1. **Forum Posts** (for sorting by votes + date):
   - Collection: `forum_posts`
   - Fields: `category` (Ascending), `upvotes` (Descending), `createdAt` (Descending)

2. **Quiz Results** (for leaderboards):
   - Collection: `quiz_results`
   - Fields: `category` (Ascending), `score` (Descending), `createdAt` (Descending)

3. **Study Sessions** (for analytics):
   - Collection: `analytics/{userId}/sessions`
   - Fields: `userId` (Ascending), `startTime` (Descending)

**Creating Indexes:**
1. Go to Firebase Console → Firestore Database
2. Click **"Indexes"** tab
3. Click **"Create Index"**
4. Add the fields above
5. Click **"Create"**

Or wait for Firebase to suggest indexes when queries fail (it will give you a link to auto-create).

---

## 🧪 Testing the Database

### Test Data Creation

Run this in your app after signing up:

```dart
// This happens automatically when you sign up
// Check Firebase Console → Firestore → users collection
```

### Manual Test Data (Optional)

You can add test data in Firebase Console:

1. Go to **Firestore Database**
2. Click **"Start collection"**
3. Collection ID: `achievements`
4. Document ID: `first_lesson`
5. Add fields:
```
name: "First Steps" (string)
description: "Complete your first lesson" (string)
category: "learning" (string)
difficulty: "bronze" (string)
xpReward: 10 (number)
```
6. Click **"Save"**

---

## 🔍 Verifying the Setup

### Check User Creation:
1. Sign up in your app
2. Go to Firebase Console → Firestore
3. Click **users** collection
4. You should see a document with your user ID
5. Verify all fields are present

### Check Analytics:
1. Study for a few minutes
2. Go to Firebase Console → Firestore
3. Click **analytics** → your user ID → **sessions**
4. Should see session documents

---

## 📈 Database Growth Estimates

### Free Tier Limits:
- **Reads**: 50,000/day
- **Writes**: 20,000/day
- **Deletes**: 20,000/day
- **Storage**: 1 GB

### Estimated Usage (per user/day):
- **Reads**: ~200 (browsing, loading data)
- **Writes**: ~50 (sessions, quiz results, updates)
- **Storage**: ~1 KB per user profile

With free tier, you can support:
- **~250 active users/day**
- **~1000 total users**

---

## 🚀 Next Steps

1. **Create the database** (2 minutes)
2. **Test with your app** (sign up → verify data)
3. **Add security rules** (after testing)
4. **Monitor usage** (Firebase Console → Usage tab)
5. **Create indexes** (as needed)

---

## 🐛 Common Issues

### "Missing or insufficient permissions"
- Check security rules
- Make sure user is authenticated
- Verify `userId` matches `request.auth.uid`

### "Query requires an index"
- Click the link in the error message
- Firebase will create the index automatically

### User data not appearing
- Check that `AuthService.getUserProfile()` is called
- Verify Firebase initialization in `main.dart`
- Check Firebase Console → Authentication (user should be there)

---

## ✅ Quick Checklist

- [ ] Firestore database created
- [ ] Test mode enabled (30 days)
- [ ] Location selected
- [ ] Security rules reviewed
- [ ] Tested sign up (user document created)
- [ ] Collections appear in console
- [ ] Ready for production rules

---

Ready to create your database? Follow Step 1 above! 🎉
