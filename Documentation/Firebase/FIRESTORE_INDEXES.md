# Firestore Indexes Configuration - MyDreamTeam

**Date:** December 3, 2025
**Project:** MyDreamTeam - Fantasy Football iOS App
**Status:** Complete Indexes Configuration

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Index Types](#index-types)
3. [Required Indexes](#required-indexes)
4. [How to Create Indexes](#how-to-create-indexes)
5. [Performance Optimization](#performance-optimization)
6. [Index Deployment](#index-deployment)

---

## Overview

Firestore indexes optimize query performance. Without indexes, complex queries become slow. This guide includes all indexes needed for MyDreamTeam's queries.

**Total Indexes Required:** 12

---

## Index Types

### Single Field Indexes (Auto-Created)
Simple queries on one field automatically get indexes:
```
Collection: users
  Ascending: email
  Descending: createdAt
```

### Composite Indexes (Manual)
Complex queries requiring multiple fields:
```
Collection: fantasySquads
  Ascending: uid
  Ascending: leagueId
```

---

## Required Indexes

### Index 1: Fantasy Squads by User and League

**Purpose:** Query squads for a specific user in a specific league
**Collection:** `fantasySquads`
**Query Type:** Equality + Equality

**Fields:**
```
1. uid (Ascending)
2. leagueId (Ascending)
```

**Used By:**
```swift
db.collection("fantasySquads")
  .whereField("uid", isEqualTo: currentUserUid)
  .whereField("leagueId", isEqualTo: leagueId)
  .getDocuments()
```

---

### Index 2: Fantasy Squads Sorted by Points

**Purpose:** Get league standings by points
**Collection:** `fantasySquads`
**Query Type:** Equality + Descending

**Fields:**
```
1. leagueId (Ascending)
2. totalPoints (Descending)
```

**Used By:**
```swift
db.collection("fantasySquads")
  .whereField("leagueId", isEqualTo: leagueId)
  .order(by: "totalPoints", descending: true)
  .limit(to: 20)
  .getDocuments()
```

---

### Index 3: Matches by Season and Status

**Purpose:** Get all matches for a season with specific status
**Collection:** `matches`
**Query Type:** Equality + Equality + Ascending

**Fields:**
```
1. season (Ascending)
2. status (Ascending)
3. kickoffTime (Ascending)
```

**Used By:**
```swift
db.collection("matches")
  .whereField("season", isEqualTo: 2024)
  .whereField("status", isEqualTo: "completed")
  .order(by: "kickoffTime", descending: true)
  .getDocuments()
```

---

### Index 4: League Feed Sorted by Type

**Purpose:** Get league activity by type and date
**Collection:** `leagues/{leagueId}/feed`
**Query Type:** Equality + Descending

**Fields:**
```
1. type (Ascending)
2. createdAt (Descending)
```

**Used By:**
```swift
db.collection("leagues").document(leagueId)
  .collection("feed")
  .whereField("type", isEqualTo: "transfer")
  .order(by: "createdAt", descending: true)
  .limit(to: 50)
  .getDocuments()
```

---

### Index 5: League Matchups by Matchday

**Purpose:** Get all matchups for a specific matchday
**Collection:** `leagues/{leagueId}/matchups`
**Query Type:** Equality + Equality

**Fields:**
```
1. matchday (Ascending)
2. status (Ascending)
```

**Used By:**
```swift
db.collection("leagues").document(leagueId)
  .collection("matchups")
  .whereField("matchday", isEqualTo: 15)
  .whereField("status", isEqualTo: "completed")
  .getDocuments()
```

---

### Index 6: Players by Team and Position

**Purpose:** Get available players for a specific team at a position
**Collection:** `players`
**Query Type:** Equality + Equality

**Fields:**
```
1. team (Ascending)
2. position (Ascending)
```

**Used By:**
```swift
db.collection("players")
  .whereField("team", isEqualTo: db.collection("teams").document("man-united"))
  .whereField("position", isEqualTo: "FWD")
  .getDocuments()
```

---

### Index 7: Players Sorted by Fantasy Price

**Purpose:** Browse players sorted by fantasy points cost
**Collection:** `players`
**Query Type:** Ascending + Descending

**Fields:**
```
1. position (Ascending)
2. fantasyStats.price (Descending)
```

**Used By:**
```swift
db.collection("players")
  .whereField("position", isEqualTo: "MID")
  .order(by: "fantasyStats.price", descending: true)
  .limit(to: 20)
  .getDocuments()
```

---

### Index 8: Transfers by Date

**Purpose:** Get recent transfers chronologically
**Collection:** `transfers`
**Query Type:** Ascending + Descending

**Fields:**
```
1. status (Ascending)
2. transferDate (Descending)
```

**Used By:**
```swift
db.collection("transfers")
  .whereField("status", isEqualTo: "completed")
  .order(by: "transferDate", descending: true)
  .limit(to: 30)
  .getDocuments()
```

---

### Index 9: League Members by Rank

**Purpose:** Get league members sorted by current ranking
**Collection:** `leagues/{leagueId}/members`
**Query Type:** Ascending + Descending

**Fields:**
```
1. status (Ascending)
2. currentRank (Ascending)
```

**Used By:**
```swift
db.collection("leagues").document(leagueId)
  .collection("members")
  .whereField("status", isEqualTo: "active")
  .order(by: "currentRank", ascending: true)
  .getDocuments()
```

---

### Index 10: Matches by Team

**Purpose:** Get all matches involving a specific team
**Collection:** `matches`
**Query Type:** Equality + Equality + Ascending

**Fields:**
```
1. homeTeam (Ascending)
2. season (Ascending)
3. kickoffTime (Descending)
```

Note: May need separate index for awayTeam
```
1. awayTeam (Ascending)
2. season (Ascending)
3. kickoffTime (Descending)
```

**Used By:**
```swift
db.collection("matches")
  .whereField("homeTeam", isEqualTo: db.collection("teams").document("man-united"))
  .whereField("season", isEqualTo: 2024)
  .order(by: "kickoffTime", descending: true)
  .getDocuments()
```

---

### Index 11: User Leagues Created

**Purpose:** Get all leagues created by a user
**Collection:** `leagues`
**Query Type:** Equality + Descending

**Fields:**
```
1. creatorUid (Ascending)
2. createdAt (Descending)
```

**Used By:**
```swift
db.collection("leagues")
  .whereField("creatorUid", isEqualTo: db.collection("users").document(currentUserUid))
  .order(by: "createdAt", descending: true)
  .getDocuments()
```

---

### Index 12: Players by Form Rating

**Purpose:** Get best performing players currently
**Collection:** `players`
**Query Type:** Ascending + Descending

**Fields:**
```
1. position (Ascending)
2. fantasyStats.form (Descending)
```

**Used By:**
```swift
db.collection("players")
  .whereField("position", isEqualTo: "FWD")
  .order(by: "fantasyStats.form", descending: true)
  .limit(to: 10)
  .getDocuments()
```

---

## How to Create Indexes

### Method 1: Automatic Creation (Easiest)

Firebase automatically creates composite indexes when you run queries. To use this method:

1. **Run your query in the app or Firestore Console**
2. **Firebase will show a notification** suggesting to create index
3. **Click the link** in the notification
4. **Firebase creates the index automatically**
5. **Wait for index build** (usually 1-2 minutes)

### Method 2: Firebase Console (Manual)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select MyDreamTeam project
3. Navigate to **Cloud Firestore** → **Indexes** tab
4. Click **Create Index**
5. Fill in index details:
   - **Collection ID:** `fantasySquads`
   - **Query Scope:** Collection
6. Add fields in order:
   - Field: `uid` → Direction: `Ascending`
   - Click **Add field**
   - Field: `leagueId` → Direction: `Ascending`
7. Click **Create Index**
8. Wait for "Enabled" status

**Repeat for all 12 indexes above**

### Method 3: Upload firestore.indexes.json

1. Create file: `firestore.indexes.json` in project root

2. Paste the JSON configuration (see section below)

3. Deploy with Firebase CLI:
   ```bash
   firebase deploy --only firestore:indexes
   ```

4. Monitor deployment:
   ```bash
   firebase deployment:list
   ```

---

## firestore.indexes.json Configuration

Create this file in your project root with all indexes:

```json
{
  "indexes": [
    {
      "collectionGroup": "fantasySquads",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "uid",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "leagueId",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "fantasySquads",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "leagueId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "totalPoints",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "matches",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "season",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "kickoffTime",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "feed",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "type",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "matchups",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "matchday",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "players",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "team",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "position",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "players",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "position",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "fantasyStats.price",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "transfers",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "transferDate",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "members",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "currentRank",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "matches",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "homeTeam",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "season",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "kickoffTime",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "leagues",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "creatorUid",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "players",
      "queryScope": "Collection",
      "fields": [
        {
          "fieldPath": "position",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "fantasyStats.form",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## Performance Optimization

### Index Best Practices

✅ **DO:**
- Create indexes for all multi-field queries
- Use ascending order for equality filters
- Use descending order for sorting fields
- Name indexes descriptively (Firebase auto-names them)
- Monitor index performance in Firebase Console
- Archive old indexes for deleted queries

❌ **DON'T:**
- Create indexes for single-field queries (auto-indexed)
- Create duplicate indexes for same field combination
- Over-index (only index queries you actually use)
- Create very large composite indexes (4+ fields)

### Query Performance Monitoring

In Firebase Console:

1. Go to **Cloud Firestore** → **Stats** tab
2. View **Queries** section to see slow queries
3. Check **Composite Indexes** to see usage stats
4. Delete unused indexes to save costs

---

## Index Deployment

### Deployment Checklist

- [ ] All 12 indexes identified
- [ ] firestore.indexes.json created in project root
- [ ] JSON syntax validated
- [ ] Firebase CLI installed (`firebase-tools`)
- [ ] Logged in to Firebase (`firebase login`)
- [ ] Project initialized (`firebase init`)
- [ ] Deployment command ready

### Deploy Indexes

**Option 1: CLI Deployment** (Recommended)

```bash
# From project root
firebase deploy --only firestore:indexes
```

**Option 2: Manual Creation in Console**

For each of the 12 indexes above:
1. Go to Firebase Console
2. Cloud Firestore → Indexes
3. Create each index manually
4. Wait for "Enabled" status before next index

**Option 3: Let Firebase Auto-Create**

1. Deploy app to production
2. Run queries that need indexes
3. Click "Create Index" in error messages
4. Firebase creates them automatically
5. Monitor in Indexes tab

---

## Index Maintenance

### Monitor Index Health

**Monthly Index Review:**

```bash
firebase firestore:indexes
```

Shows all indexes with:
- Status (Enabled/Pending/Disabled)
- Creation date
- Size on disk
- Query count

### Clean Up Old Indexes

1. Identify unused indexes from query stats
2. Go to Indexes tab in Firebase Console
3. Select index
4. Click **Delete** button
5. Confirm deletion

**Cost Savings:** Unused indexes increase storage and write costs.

---

## Troubleshooting

### Issue: "Missing or insufficient permissions" on query

**Cause:** Query exceeds single-field filter without index

**Solution:**
- Check if composite index exists for this query
- Create index using methods above
- Wait 2-3 minutes for index build
- Retry query

### Issue: Query still slow after creating index

**Cause:** Index may not be optimal for your query pattern

**Solution:**
- Check index field order matches query filters
- Equality filters should be first
- Sorting should be last in index
- Test in Firestore Console Simulator

### Issue: "Index not yet built" error

**Cause:** Index still building (takes 1-5 minutes)

**Solution:**
- Wait for "Enabled" status in Console
- Check deployment status: `firebase deployment:list`
- Retry query in 2-3 minutes

### Issue: Firestore costs increasing

**Cause:** Creating too many indexes or over-indexing

**Solution:**
- Review Index stats in Console
- Delete unused indexes
- Consolidate similar queries
- Use document-level caching where possible

---

## Summary

### Index Creation Steps

1. **Identify** which queries your app runs
2. **Create** composite indexes for multi-field queries
3. **Deploy** using firebase deploy or Console
4. **Test** queries in Firebase Console Simulator
5. **Monitor** index performance monthly
6. **Maintain** by removing unused indexes

### Benefits

✅ Queries execute in milliseconds instead of seconds
✅ App stays responsive even with large datasets
✅ Reduced CPU usage and bandwidth costs
✅ Better user experience with instant results

### All 12 Indexes Included

- Fantasy Squads: User + League (Index 1)
- Fantasy Squads: League + Points (Index 2)
- Matches: Season + Status + Time (Index 3)
- League Feed: Type + Created (Index 4)
- League Matchups: Matchday + Status (Index 5)
- Players: Team + Position (Index 6)
- Players: Position + Price (Index 7)
- Transfers: Status + Date (Index 8)
- League Members: Status + Rank (Index 9)
- Matches: Team (2 indexes - home/away) (Index 10)
- User Leagues: Creator + Created (Index 11)
- Players: Position + Form (Index 12)

---

**Last Updated:** December 3, 2025
**Status:** Complete - Ready for Deployment

