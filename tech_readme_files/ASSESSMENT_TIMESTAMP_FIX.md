# Assessment Timestamp Serialization Fix

## Summary
Fixed Timestamp serialization error when saving Firestore assessments to Hive local cache. The issue occurred because Hive cannot directly serialize Firestore `Timestamp` objects.

---

## 🐛 The Problem

### Error Message
```
Error syncing with Firestore (using cached data): 
Converting object to an encodable object failed: Instance of 'Timestamp'
```

### Root Cause
When syncing assessments from Firestore to the local Hive cache:
1. Firestore stores dates as `Timestamp` objects
2. We call `assessment.toMap()` which returns `Timestamp` objects
3. We try to `jsonEncode()` the map
4. ❌ `jsonEncode` can't serialize `Timestamp` objects
5. Error thrown, sync fails

### Code Location
**File:** `lib/features/assessment/data/repositories/assessment_repository.dart`

**Problem Lines:**
```dart
// ❌ This fails because toMap() returns Timestamp objects
await _box.put(assessmentKey, jsonEncode(assessment.toMap()));
```

---

## ✅ The Solution

### Dual-Format Support

Modified `SkillAssessment.toMap()` to support both Firestore and Hive:

**Before:**
```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'userId': userId,
    'completedAt': Timestamp.fromDate(completedAt),  // ❌ Always Timestamp
    // ... other fields
  };
}
```

**After:**
```dart
Map<String, dynamic> toMap({bool forFirestore = true}) {
  return {
    'id': id,
    'userId': userId,
    'completedAt': forFirestore 
        ? Timestamp.fromDate(completedAt)     // ✅ For Firestore
        : completedAt.toIso8601String(),      // ✅ For Hive/JSON
    // ... other fields
  };
}
```

### Updated Parsing

Enhanced `SkillAssessment.fromMap()` to handle multiple date formats:

**Before:**
```dart
completedAt: map['completedAt'] is Timestamp
    ? (map['completedAt'] as Timestamp).toDate()
    : DateTime.now(),  // ❌ Falls back to now() if not Timestamp
```

**After:**
```dart
DateTime parseDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();           // ✅ From Firestore
  } else if (value is DateTime) {
    return value;                    // ✅ Already DateTime
  } else if (value is String) {
    return DateTime.parse(value);    // ✅ From Hive (ISO string)
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);  // ✅ Timestamp ms
  }
  return DateTime.now();             // Fallback
}

completedAt: parseDateTime(map['completedAt']),
```

---

## 📁 Files Modified

### 1. `lib/features/assessment/data/models/skill_assessment.dart`

#### Change 1: Added `forFirestore` Parameter
```dart
Map<String, dynamic> toMap({bool forFirestore = true}) {
  return {
    'id': id,
    'userId': userId,
    'skills': skills.map((key, value) => MapEntry(key, value.name)),
    'completedAt': forFirestore 
        ? Timestamp.fromDate(completedAt)
        : completedAt.toIso8601String(),
    'totalScore': totalScore,
    'maxScore': maxScore,
    'categoryScores': categoryScores,
    'categoryMaxScores': categoryMaxScores,
    'weakAreas': weakAreas,
    'strongAreas': strongAreas,
    'timeTaken': timeTaken.inSeconds,
    'questionsAnswered': questionsAnswered,
    'correctAnswers': correctAnswers,
  };
}
```

#### Change 2: Enhanced Date Parsing
```dart
factory SkillAssessment.fromMap(Map<String, dynamic> map) {
  // Parse skills map
  final skillsMap = (map['skills'] as Map<String, dynamic>).map(
    (key, value) => MapEntry(
      key,
      SkillLevel.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SkillLevel.beginner,
      ),
    ),
  );

  // Helper function to parse DateTime from various formats
  DateTime parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  return SkillAssessment(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    skills: skillsMap,
    completedAt: parseDateTime(map['completedAt']),
    // ... rest of fields
  );
}
```

### 2. `lib/features/assessment/data/repositories/assessment_repository.dart`

#### Change 1: `saveAssessment()` Method
```dart
Future<void> saveAssessment(SkillAssessment assessment) async {
  // Save to Hive first (always succeeds, works offline)
  try {
    final assessmentKey = 'assessment_${assessment.userId}_${assessment.id}';
    // ✅ Use forFirestore: false for Hive (ISO strings)
    await _box.put(assessmentKey, jsonEncode(assessment.toMap(forFirestore: false)));
  } catch (e) {
    print('Error saving assessment to local cache: $e');
  }

  // Try to save to Firestore (requires internet and auth)
  try {
    // ✅ Use forFirestore: true for Firestore (Timestamps)
    await _assessmentsCollection.doc(assessment.id).set(assessment.toMap(forFirestore: true));
  } catch (e) {
    print('Error syncing assessment to Firestore: $e');
  }
}
```

#### Change 2: `getUserLatestAssessment()` Method
```dart
// Cache Firestore assessment locally
final assessmentKey =
    'assessment_${firestoreAssessment.userId}_${firestoreAssessment.id}';
// ✅ Use forFirestore: false for Hive (ISO strings)
await _box.put(assessmentKey, jsonEncode(firestoreAssessment.toMap(forFirestore: false)));
```

#### Change 3: `getUserAssessments()` Method  
```dart
// Cache Firestore assessments locally
for (final assessment in firestoreAssessments) {
  final assessmentKey =
      'assessment_${assessment.userId}_${assessment.id}';
  // ✅ Use forFirestore: false to get ISO string format for Hive
  await _box.put(assessmentKey, jsonEncode(assessment.toMap(forFirestore: false)));
}
```

---

## 🔄 Data Flow (Fixed)

### Saving New Assessment

```
1. User completes assessment
2. Create SkillAssessment object
   ↓
3. Save to Hive:
   - Call toMap(forFirestore: false)
   - Returns ISO string: "2025-10-29T12:34:56.789Z"
   - jsonEncode succeeds ✅
   - Saved to Hive
   ↓
4. Save to Firestore:
   - Call toMap(forFirestore: true)
   - Returns Timestamp object
   - Firestore accepts ✅
   - Saved to Firestore
```

### Loading Assessment from Firestore

```
1. Fetch from Firestore
   - Data contains Timestamp objects
   ↓
2. Parse with fromMap():
   - parseDateTime(value) detects Timestamp
   - Converts to DateTime
   - Assessment object created ✅
   ↓
3. Cache to Hive:
   - Call toMap(forFirestore: false)
   - Timestamp → ISO string
   - jsonEncode succeeds ✅
   - Cached in Hive
```

### Loading Assessment from Hive

```
1. Read from Hive
   - Data contains ISO string
   ↓
2. Parse with fromMap():
   - parseDateTime(value) detects String
   - Parses ISO string to DateTime
   - Assessment object created ✅
```

---

## 🎯 Benefits

### 1. **No More Serialization Errors**
- ✅ Hive can serialize ISO strings
- ✅ Firestore gets proper Timestamp objects
- ✅ No encoding failures

### 2. **Flexible Parsing**
- ✅ Handles Timestamp (from Firestore)
- ✅ Handles ISO String (from Hive)
- ✅ Handles DateTime objects
- ✅ Handles milliseconds (int)

### 3. **Consistent Architecture**
- ✅ Same pattern as `StudySession` model
- ✅ Works across all features
- ✅ Easy to maintain

### 4. **Offline Support**
- ✅ Assessments save to Hive successfully
- ✅ Data available offline
- ✅ Syncs when online

### 5. **Data Integrity**
- ✅ No data loss
- ✅ Dates preserved accurately
- ✅ Cross-platform compatible

---

## 🧪 Testing

### Test Scenarios

#### ✅ Save New Assessment
1. Complete assessment
2. Check Hive → Has ISO string ✅
3. Check Firestore → Has Timestamp ✅

#### ✅ Load from Firestore
1. Fetch assessment from Firestore
2. Parse successfully ✅
3. Cache to Hive with ISO string ✅

#### ✅ Load from Hive (Offline)
1. Disconnect internet
2. Load assessments from Hive
3. Dates parse correctly ✅

#### ✅ Sync After Offline
1. Complete assessment offline
2. Saved to Hive ✅
3. Connect internet
4. Syncs to Firestore ✅

---

## 📊 Date Format Reference

| Source | Format | Example | Handled By |
|--------|--------|---------|------------|
| Firestore | Timestamp | `Timestamp(seconds: 1698588896, nanoseconds: 789000000)` | `parseDateTime()` |
| Hive/JSON | ISO 8601 String | `"2025-10-29T12:34:56.789Z"` | `parseDateTime()` |
| Dart | DateTime | `DateTime(2025, 10, 29, 12, 34, 56)` | `parseDateTime()` |
| Milliseconds | int | `1698588896789` | `parseDateTime()` |

---

## 💡 Similar Pattern Used In

This same dual-format pattern is used in other models:

1. **`StudySession`** (`lib/features/analytics/data/models/study_session.dart`)
   - Also needs Timestamp for Firestore
   - ISO string for Hive

2. **Future Models**
   - Any model with DateTime fields
   - Saved to both Firestore and Hive
   - Should use this pattern

---

## 🔧 Developer Notes

### When to Use Each Format

**Use `toMap(forFirestore: true)` when:**
- Saving to Firestore
- Updating Firestore documents
- Setting Firestore data

**Use `toMap(forFirestore: false)` when:**
- Saving to Hive
- Converting to JSON
- Logging/debugging
- Sending over network (JSON API)

### Adding New DateTime Fields

If you add new DateTime fields to `SkillAssessment`:

```dart
// In toMap():
'newDateField': forFirestore 
    ? Timestamp.fromDate(newDateField)
    : newDateField.toIso8601String(),

// In fromMap():
newDateField: parseDateTime(map['newDateField']),
```

---

## ✨ Summary

**Problem:** Firestore `Timestamp` objects couldn't be serialized to Hive.

**Solution:** Dual-format `toMap()` method that outputs:
- Timestamp objects for Firestore
- ISO strings for Hive/JSON

**Result:** 
- ✅ Assessments save successfully to both storages
- ✅ No more serialization errors
- ✅ Full offline support
- ✅ Data integrity maintained

---

*Last Updated: October 29, 2025*
*Status: ✅ Fixed and Tested*

