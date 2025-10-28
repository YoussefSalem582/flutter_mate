# User Progress Synchronization System

## Overview
This document explains how user progress (lesson completions, advanced mode, etc.) is saved and synchronized between local storage and Firestore cloud database.

## Architecture

### Components

#### 1. **ProgressSyncService** (`progress_sync_service.dart`)
- Core service responsible for syncing data between local storage (SharedPreferences) and Firestore
- Handles both authenticated users and guest users
- Provides automatic sync, manual sync, and migration capabilities

#### 2. **LessonRepository** (`lesson_repository.dart`)
- Updated to use `ProgressSyncService` for all write operations
- Still uses SharedPreferences for read operations (fast local access)
- Automatically syncs to cloud when marking lessons complete or changing advanced mode

#### 3. **AuthController** (`auth_controller.dart`)
- Triggers progress sync when user logs in
- Migrates guest progress to authenticated user account
- Clears local data on sign out

## Data Flow

### Guest User Flow
```
1. Guest completes lesson
   ↓
2. Data saved to SharedPreferences (local only)
   ↓
3. Guest decides to sign up
   ↓
4. AuthController detects new authentication
   ↓
5. ProgressSyncService.migrateGuestProgress()
   ↓
6. Local progress synced to Firestore under new user ID
   ↓
7. User's progress is now saved to cloud
```

### Authenticated User Flow
```
1. User completes lesson
   ↓
2. LessonRepository.markLessonCompleted()
   ↓
3. ProgressSyncService.markLessonCompleted()
   ↓
4. Data saved to SharedPreferences (immediate)
   ↓
5. Data synced to Firestore (background)
   ↓
6. User profile stats updated (lessonsCompleted count)
```

### Login/Sync Flow
```
1. User logs in
   ↓
2. AuthController.\_initAuthListener() triggered
   ↓
3. ProgressSyncService.autoSync() called
   ↓
4. Fetch cloud progress from Firestore
   ↓
5. Merge with local progress (union of both)
   ↓
6. Save merged data locally
   ↓
7. Sync back to cloud if merged data differs
```

## Firestore Structure

### User Document
```
users/{userId}
  ├── email: string
  ├── username: string
  ├── lessonsCompleted: number  ← Updated on sync
  ├── totalXP: number
  ├── currentStreak: number
  └── ... other user fields

users/{userId}/progress/lessons
  ├── completedLessons: string[]  ← List of lesson IDs
  ├── advancedMode: boolean
  ├── lessonsCompleted: number
  └── lastUpdated: timestamp
```

## Key Features

### ✅ Automatic Sync
- Progress syncs automatically on app start (if > 5 minutes since last sync)
- Progress syncs after each lesson completion
- Progress syncs when toggling advanced mode

### ✅ Offline Support
- All data saved locally first (instant UX)
- Cloud sync happens in background
- Works perfectly offline (local storage only)
- Auto-syncs when connection returns

### ✅ Guest to User Migration
- Guest progress automatically migrated when user signs up
- No data loss during account creation
- Seamless experience for users

### ✅ Multi-Device Sync
- Login on new device loads cloud progress
- Local and cloud progress merged (union)
- Most recent data wins
- No progress lost

### ✅ Smart Merging
- Union of completed lessons from local + cloud
- If cloud has [lesson1, lesson2] and local has [lesson2, lesson3]
- Result: [lesson1, lesson2, lesson3]
- Ensures no progress is lost

## Usage

### For Developers

#### Manual Sync
```dart
final syncService = Get.find<ProgressSyncService>();

// Sync to cloud
await syncService.syncToCloud();

// Sync from cloud
await syncService.syncFromCloud();

// Auto-sync (smart)
await syncService.autoSync();
```

#### Check Sync Status
```dart
final syncService = Get.find<ProgressSyncService>();
final lastSync = syncService.getLastSyncTime();

if (lastSync != null) {
  print('Last synced: $lastSync');
} else {
  print('Never synced');
}
```

#### Migrate Guest Progress
```dart
final syncService = Get.find<ProgressSyncService>();
await syncService.migrateGuestProgress();
```

## Testing

### Test Scenarios

1. **Guest User**
   - ✅ Complete lessons as guest
   - ✅ Verify data saved locally
   - ✅ Sign up
   - ✅ Verify progress migrated to Firestore

2. **Authenticated User**
   - ✅ Complete lessons
   - ✅ Verify Firestore updated
   - ✅ Check `users/{userId}/progress/lessons`
   - ✅ Verify `lessonsCompleted` count updated

3. **Multi-Device**
   - ✅ Complete lessons on Device A
   - ✅ Login on Device B
   - ✅ Verify progress appears on Device B

4. **Offline Mode**
   - ✅ Complete lessons offline
   - ✅ Verify saved locally
   - ✅ Go online
   - ✅ Verify syncs to cloud

5. **Sign Out/In**
   - ✅ Sign out
   - ✅ Verify local data cleared
   - ✅ Sign back in
   - ✅ Verify progress restored from cloud

## Security

### Firestore Rules
```javascript
// Ensure users can only access their own progress
match /users/{userId}/progress/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## Performance Considerations

### Optimization Strategies
1. **Local-First**: Always read from SharedPreferences (fast)
2. **Background Sync**: Cloud writes happen async (non-blocking)
3. **Throttled Sync**: Auto-sync only every 5+ minutes
4. **Batch Updates**: Multiple changes batched before sync

### Network Usage
- Minimal: Only syncs changed data
- Efficient: Uses Firestore's `merge: true` option
- Smart: Skips sync if no changes detected

## Future Enhancements

### Potential Improvements
- [ ] Real-time sync using Firestore listeners
- [ ] Conflict resolution UI (if cloud and local differ significantly)
- [ ] Progress versioning (track history)
- [ ] Backup/restore functionality
- [ ] Export progress to JSON
- [ ] Sync achievements and badges
- [ ] Sync quiz scores and attempts

## Troubleshooting

### Progress Not Syncing
1. Check user authentication status
2. Verify Firestore permissions
3. Check network connectivity
4. Review console logs for sync errors
5. Verify `ProgressSyncService` is registered in bindings

### Lost Progress
1. Check Firestore console for user's progress document
2. Verify `completedLessons` array in Firestore
3. Check SharedPreferences for local data
4. Review last sync timestamp
5. Try manual sync: `syncService.autoSync()`

### Guest Progress Not Migrating
1. Ensure user was actually guest before (not returning user)
2. Check local storage has data before migration
3. Verify new user account created successfully
4. Check console logs for migration errors
5. Verify Firestore write permissions

## Related Files

### Core Files
- `lib/features/roadmap/data/services/progress_sync_service.dart` - Sync logic
- `lib/features/roadmap/data/repositories/lesson_repository.dart` - Repository layer
- `lib/features/roadmap/controller/lesson_controller.dart` - UI controller
- `lib/features/auth/controller/auth_controller.dart` - Auth integration

### Binding Files
- `lib/features/roadmap/controller/lesson_binding.dart`
- `lib/features/roadmap/controller/roadmap_binding.dart`
- `lib/features/progress_tracker/controller/progress_tracker_binding.dart`

### Models
- `lib/features/auth/data/models/app_user.dart` - User model with progress fields

## Summary

The progress synchronization system provides:
- ✅ **Reliable** - Data saved locally first, then synced
- ✅ **Seamless** - Automatic background sync
- ✅ **Smart** - Merges local and cloud progress
- ✅ **Guest-Friendly** - Migrates guest progress on signup
- ✅ **Multi-Device** - Access progress anywhere
- ✅ **Offline-Ready** - Works without internet
- ✅ **Performant** - Local-first with async cloud sync

Users can start as guests, complete lessons, sign up later, and never lose their progress. The system ensures data integrity across devices and network conditions.
