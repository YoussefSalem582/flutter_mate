# Firestore Indexes Guide

## Overview
This document lists all Firestore composite indexes required by FlutterMate. These indexes optimize query performance and enable complex queries with multiple filters and ordering.

---

## 🔍 Required Composite Indexes

### 1. **Skill Assessments Index**
**Collection:** `skill_assessments`

| Field | Order | Purpose |
|-------|-------|---------|
| `userId` | Ascending | Filter assessments by user |
| `completedAt` | Descending | Sort by most recent first |

**Used By:**
- Assessment History Page
- User profile assessment summary
- Analytics dashboard

**Query Example:**
```dart
await _assessmentsCollection
  .where('userId', isEqualTo: userId)
  .orderBy('completedAt', descending: true)
  .get();
```

**How to Create:**
1. Visit [Firebase Console](https://console.firebase.google.com)
2. Go to Firestore Database → Indexes
3. Click "Create Index"
4. Collection ID: `skill_assessments`
5. Add fields:
   - `userId` (Ascending)
   - `completedAt` (Descending)
6. Query scope: Collection
7. Click "Create"

**Or click the link in this error:**
```
Error performing query: [cloud_firestore/failed-precondition] 
The query requires an index. You can create it here: 
https://console.firebase.google.com/v1/r/project/YOUR_PROJECT/firestore/indexes?create_composite=...
```

---

### 2. **Study Sessions Index**
**Collection:** `study_sessions`

| Field | Order | Purpose |
|-------|-------|---------|
| `userId` | Ascending | Filter sessions by user |
| `startTime` | Descending | Sort by most recent first |

**Used By:**
- Analytics Dashboard
- Time Tracker Service
- Study statistics calculations

**Query Example:**
```dart
await _firestore
  .collection('study_sessions')
  .where('userId', isEqualTo: userId)
  .orderBy('startTime', descending: true)
  .limit(100)
  .get();
```

**How to Create:**
Same steps as above, but use:
- Collection ID: `study_sessions`
- Fields:
  - `userId` (Ascending)
  - `startTime` (Descending)

---

### 3. **Quiz Results Index**
**Collection:** `quiz_results`

| Field | Order | Purpose |
|-------|-------|---------|
| `userId` | Ascending | Filter results by user |
| `completedAt` | Descending | Sort by most recent first |

**Used By:**
- Quiz history page
- Progress tracker
- Achievement calculations

**Query Example:**
```dart
await _firestore
  .collection('quiz_results')
  .where('userId', isEqualTo: userId)
  .orderBy('completedAt', descending: true)
  .get();
```

**How to Create:**
- Collection ID: `quiz_results`
- Fields:
  - `userId` (Ascending)
  - `completedAt` (Descending)

---

## 📋 Index Status Checklist

- [ ] `skill_assessments` index created
- [ ] `study_sessions` index created
- [ ] `quiz_results` index created

---

## 🚀 Automatic Index Creation

### Option 1: Click Error Link
When you run a query that needs an index, Firestore provides a direct link:

```
The query requires an index. You can create it here: 
https://console.firebase.google.com/v1/r/project/.../firestore/indexes?create_composite=...
```

**Just click the link and confirm the index creation!**

### Option 2: Use Firebase CLI
Create a `firestore.indexes.json` file:

```json
{
  "indexes": [
    {
      "collectionGroup": "skill_assessments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "completedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "study_sessions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "startTime", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "quiz_results",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "completedAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Then deploy:
```bash
firebase deploy --only firestore:indexes
```

---

## ⏱️ Index Building Time

- **Small datasets (<1000 docs):** A few seconds
- **Medium datasets (1000-10000 docs):** 1-5 minutes
- **Large datasets (>10000 docs):** 5-30 minutes

You'll receive an email when index building is complete.

---

## 🔧 Troubleshooting

### Error: "The query requires an index"
**Solution:** Create the index using the provided link or manual steps above.

### Error: "Index already exists"
**Solution:** The index is either building or already created. Wait a few minutes and try again.

### Error: "Permission denied"
**Solution:** Make sure you have "Firebase Admin" or "Editor" role for the project.

### Query still fails after creating index
**Solution:** 
1. Wait for index to finish building (check Firebase Console → Indexes)
2. Verify the field names match exactly (case-sensitive)
3. Clear app cache and restart

---

## 📊 Index Monitoring

### Check Index Status
1. Visit Firebase Console
2. Go to Firestore Database → Indexes
3. Look for:
   - ✅ **Green checkmark** = Active
   - 🔄 **Building** = In progress
   - ❌ **Error** = Failed (check field names)

### Index Performance
- Monitor query performance in Firebase Console
- Check "Usage" tab for query counts
- Optimize indexes if queries are slow

---

## 💡 Best Practices

### 1. **Create Indexes Early**
Set up indexes during development to avoid runtime errors.

### 2. **Test Queries**
Always test queries with real data before deploying.

### 3. **Monitor Usage**
Keep an eye on index size and query performance.

### 4. **Remove Unused Indexes**
Delete indexes that are no longer needed to save storage.

### 5. **Use Inequality Filters Wisely**
Firestore limits ordering to one field after an inequality filter.

---

## 📝 Notes

- **Automatic Indexing:** Single-field queries are automatically indexed
- **Composite Indexes:** Multi-field queries require manual index creation
- **Array Contains:** Special indexes may be needed for `array-contains` queries
- **Collection Group Queries:** Require separate indexes from collection queries

---

## 🔗 Useful Links

- [Firebase Indexes Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Query Limitations](https://firebase.google.com/docs/firestore/query-data/queries#query_limitations)

---

*Last Updated: October 29, 2025*
*Status: Required for Assessment History Feature*

