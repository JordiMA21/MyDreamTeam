# Firestore Collections Implementation Guide - MyDreamTeam

**Date:** December 3, 2025
**Project:** MyDreamTeam - Fantasy Football iOS App
**Status:** Complete Step-by-Step Guide for All Collections

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Collection Structure](#collection-structure)
3. [Step-by-Step Implementation](#step-by-step-implementation)
4. [Security Rules](#security-rules)
5. [Indexes](#indexes)
6. [Testing Collection Setup](#testing-collection-setup)

---

## Overview

This guide provides step-by-step instructions to create all 11 Firestore collections for MyDreamTeam. Each collection includes:
- Complete schema with field types
- Document structure examples
- Relationships to other collections
- Security rules for access control
- Required indexes for queries

**Total Collections to Create:** 11
- Root Collections: 6 (users, teams, players, leagues, fantasySquads, matches, transfers, seasonHistory)
- Subcollections: 4 (members, feed, matchups under leagues)

---

## Collection Structure

### 1. **users** Collection
**Purpose:** Store authenticated user profiles
**Document ID:** Firebase Auth UID
**Access:** Owned by user, admin read-only

**Schema:**
```json
{
  "uid": "string (auto-generated)",
  "email": "string",
  "displayName": "string",
  "photoURL": "string (optional)",
  "isEmailVerified": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isAdmin": "boolean",
  "preferences": {
    "theme": "string (light/dark)",
    "notifications": "boolean",
    "language": "string (es/en)"
  },
  "stats": {
    "totalLeagues": "integer",
    "totalFantasySquads": "integer",
    "bestRanking": "integer"
  }
}
```

### 2. **teams** Collection
**Purpose:** Store football teams
**Document ID:** Custom string (e.g., "manchester-united")
**Access:** Public read, admin write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "name": "string",
  "shortName": "string (e.g., MUN)",
  "country": "string",
  "founded": "integer (year)",
  "stadium": "string",
  "coach": "string",
  "logoURL": "string",
  "colors": {
    "primary": "string (hex)",
    "secondary": "string (hex)"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 3. **players** Collection
**Purpose:** Store player information
**Document ID:** Custom string (e.g., "ronaldo-cr7")
**Access:** Public read, admin write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "firstName": "string",
  "lastName": "string",
  "displayName": "string",
  "team": "reference to teams/{teamId}",
  "position": "string (GK/DEF/MID/FWD)",
  "number": "integer",
  "nationality": "string",
  "dateOfBirth": "timestamp",
  "height": "integer (cm)",
  "weight": "integer (kg)",
  "photoURL": "string",
  "stats": {
    "goals": "integer",
    "assists": "integer",
    "appearances": "integer",
    "minutesPlayed": "integer",
    "avgRating": "double"
  },
  "fantasyStats": {
    "price": "double (in credits)",
    "fantasyPoints": "integer",
    "form": "integer (-3 to 3)",
    "nxtOpponent": "reference to teams/{teamId}"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 4. **leagues** Collection
**Purpose:** Store fantasy leagues
**Document ID:** Custom string (auto-generated)
**Access:** Members can read, creator can write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "name": "string",
  "description": "string",
  "creatorUid": "reference to users/{uid}",
  "season": "integer (e.g., 2024)",
  "status": "string (active/archived/draft)",
  "rules": {
    "maxPlayers": "integer",
    "maxTeamSize": "integer",
    "transferWindow": "boolean",
    "scoringFormat": "string (ppr/standard)"
  },
  "budget": {
    "initial": "integer (e.g., 10000)",
    "remaining": "integer"
  },
  "standings": {
    "totalMembers": "integer",
    "matchdayCount": "integer"
  },
  "imageURL": "string (optional)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Subcollection: members**
**Purpose:** League members and their join dates
**Parent:** leagues/{leagueId}
**Document ID:** User UID

**Schema:**
```json
{
  "uid": "reference to users/{uid}",
  "joinedAt": "timestamp",
  "currentRank": "integer",
  "points": "integer",
  "status": "string (active/inactive)"
}
```

**Subcollection: feed**
**Purpose:** League activity feed (transfers, rankings, etc.)
**Parent:** leagues/{leagueId}
**Document ID:** Custom string (auto-generated)

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "type": "string (transfer/ranking/match/join)",
  "userId": "reference to users/{uid}",
  "content": "string",
  "metadata": {
    "playerName": "string (optional)",
    "fromTeam": "reference to teams/{teamId}",
    "toTeam": "reference to teams/{teamId}"
  },
  "createdAt": "timestamp"
}
```

**Subcollection: matchups**
**Purpose:** Matchups between league members
**Parent:** leagues/{leagueId}
**Document ID:** Custom string (e.g., "matchup-1")

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "matchday": "integer",
  "team1Uid": "reference to users/{uid}",
  "team2Uid": "reference to users/{uid}",
  "team1Score": "integer",
  "team2Score": "integer",
  "status": "string (pending/completed)",
  "createdAt": "timestamp",
  "startedAt": "timestamp (optional)",
  "completedAt": "timestamp (optional)"
}
```

### 5. **fantasySquads** Collection
**Purpose:** User's fantasy team lineups
**Document ID:** Custom string (auto-generated)
**Access:** Only owner can read/write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "uid": "reference to users/{uid}",
  "leagueId": "reference to leagues/{leagueId}",
  "name": "string",
  "players": [
    {
      "playerId": "reference to players/{playerId}",
      "position": "string (GK/DEF/MID/FWD)",
      "isPicked": "boolean",
      "pointsContribution": "integer"
    }
  ],
  "formationString": "string (e.g., 4-3-3)",
  "totalPlayers": "integer",
  "totalPoints": "integer",
  "budgetRemaining": "double",
  "transfers": {
    "used": "integer",
    "remaining": "integer"
  },
  "lastUpdated": "timestamp",
  "createdAt": "timestamp"
}
```

### 6. **matches** Collection
**Purpose:** Actual football match results
**Document ID:** Custom string (e.g., "match-2024-01-15-1")
**Access:** Public read, admin write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "homeTeam": "reference to teams/{teamId}",
  "awayTeam": "reference to teams/{teamId}",
  "homeScore": "integer",
  "awayScore": "integer",
  "status": "string (scheduled/live/completed)",
  "matchday": "integer",
  "season": "integer",
  "league": "string (e.g., Premier League)",
  "stadium": "string",
  "referee": "string",
  "attendance": "integer (optional)",
  "kickoffTime": "timestamp",
  "completedAt": "timestamp (optional)",
  "highlights": {
    "homeGoalScorers": ["string (optional)"],
    "awayGoalScorers": ["string (optional)"]
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 7. **transfers** Collection
**Purpose:** Player transfers between teams
**Document ID:** Custom string (auto-generated)
**Access:** Public read, admin write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "playerId": "reference to players/{playerId}",
  "fromTeam": "reference to teams/{teamId}",
  "toTeam": "reference to teams/{teamId}",
  "transferDate": "timestamp",
  "transferFee": "string (e.g., '€50M')",
  "contractLength": "integer (years)",
  "jerseyNumber": "integer",
  "status": "string (pending/completed/cancelled)",
  "createdAt": "timestamp"
}
```

### 8. **seasonHistory** Collection
**Purpose:** Historical data for past seasons
**Document ID:** Custom string (e.g., "2023-2024")
**Access:** Public read, admin write

**Schema:**
```json
{
  "id": "string (auto-generated)",
  "season": "integer",
  "league": "string",
  "champion": "reference to teams/{teamId}",
  "topScorer": "reference to players/{playerId}",
  "topAssister": "reference to players/{playerId}",
  "totalMatches": "integer",
  "totalGoals": "integer",
  "topFantasyPlayer": "reference to players/{playerId}",
  "createdAt": "timestamp"
}
```

---

## Step-by-Step Implementation

### Phase 1: Core Collections Setup

#### Step 1: Create "users" Collection

1. Open [Firebase Console](https://console.firebase.google.com)
2. Navigate to **Cloud Firestore**
3. Click **Create Collection**
4. Collection ID: `users`
5. Document ID: Auto (Firebase will auto-generate from Auth UID)
6. Add sample document with fields:
   ```
   uid: (string) example-uid-123
   email: (string) user@example.com
   displayName: (string) John Doe
   isEmailVerified: (boolean) true
   createdAt: (timestamp) Dec 3, 2025
   ```
7. Click **Save**

**Firestore Rules to add** (see FIRESTORE_RULES.md):
```javascript
match /users/{uid} {
  allow read: if request.auth.uid == uid || isAdmin(request.auth.uid);
  allow write: if request.auth.uid == uid;
}
```

---

#### Step 2: Create "teams" Collection

1. Click **Create Collection**
2. Collection ID: `teams`
3. Document ID: Custom - use short unique identifier (e.g., "man-united")
4. Add sample document:
   ```
   id: (string) man-united
   name: (string) Manchester United
   shortName: (string) MUN
   country: (string) England
   founded: (integer) 1878
   stadium: (string) Old Trafford
   coach: (string) Erik ten Hag
   logoURL: (string) https://...
   createdAt: (timestamp) Dec 3, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /teams/{teamId} {
  allow read: if true; // Public read
  allow write: if isAdmin(request.auth.uid);
}
```

---

#### Step 3: Create "players" Collection

1. Click **Create Collection**
2. Collection ID: `players`
3. Document ID: Custom - use player identifier (e.g., "ronaldo-cr7")
4. Add sample document with nested data:
   ```
   id: (string) ronaldo-cr7
   firstName: (string) Cristiano
   lastName: (string) Ronaldo
   displayName: (string) Cristiano Ronaldo
   team: (reference) teams/man-united
   position: (string) FWD
   number: (integer) 7
   nationality: (string) Portugal
   dateOfBirth: (timestamp) Feb 5, 1985
   height: (integer) 187
   weight: (integer) 84

   stats: (map)
     goals: (integer) 50
     assists: (integer) 20
     appearances: (integer) 100
     minutesPlayed: (integer) 9000
     avgRating: (double) 7.8

   fantasyStats: (map)
     price: (double) 12.5
     fantasyPoints: (integer) 450
     form: (integer) 2
     nxtOpponent: (reference) teams/liverpool

   createdAt: (timestamp) Dec 3, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /players/{playerId} {
  allow read: if true; // Public read
  allow write: if isAdmin(request.auth.uid);
}
```

---

#### Step 4: Create "leagues" Collection

1. Click **Create Collection**
2. Collection ID: `leagues`
3. Document ID: Auto-generated
4. Add sample document:
   ```
   id: (string) league-001
   name: (string) Premier Fantasy
   description: (string) Fantasy league for PL 2024/25
   creatorUid: (reference) users/user-123
   season: (integer) 2024
   status: (string) active

   rules: (map)
     maxPlayers: (integer) 15
     maxTeamSize: (integer) 11
     transferWindow: (boolean) true
     scoringFormat: (string) ppr

   budget: (map)
     initial: (integer) 10000
     remaining: (integer) 5000

   standings: (map)
     totalMembers: (integer) 10
     matchdayCount: (integer) 15

   createdAt: (timestamp) Dec 3, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /leagues/{leagueId} {
  allow read: if isLeagueMember(leagueId, request.auth.uid);
  allow write: if resource.data.creatorUid == request.auth.uid;
  allow create: if request.auth != null;
}
```

---

#### Step 5: Create "members" Subcollection under "leagues"

1. In the league document you just created, click **Add collection** (or **Add subcollection**)
2. Subcollection ID: `members`
3. Document ID: User UID (e.g., "user-123")
4. Add fields:
   ```
   uid: (reference) users/user-123
   joinedAt: (timestamp) Dec 1, 2025
   currentRank: (integer) 3
   points: (integer) 850
   status: (string) active
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /leagues/{leagueId}/members/{uid} {
  allow read: if isLeagueMember(leagueId, request.auth.uid);
  allow write: if resource.data.uid == request.auth.uid || isAdmin(request.auth.uid);
}
```

---

#### Step 6: Create "fantasySquads" Collection

1. Click **Create Collection**
2. Collection ID: `fantasySquads`
3. Document ID: Auto-generated
4. Add sample document:
   ```
   id: (string) squad-001
   uid: (reference) users/user-123
   leagueId: (reference) leagues/league-001
   name: (string) My Dream Team

   players: (array of maps)
     - playerId: (reference) players/ronaldo-cr7
       position: (string) FWD
       isPicked: (boolean) true
       pointsContribution: (integer) 45
     - playerId: (reference) players/messi-leo
       position: (string) FWD
       isPicked: (boolean) true
       pointsContribution: (integer) 38

   formationString: (string) 4-3-3
   totalPlayers: (integer) 11
   totalPoints: (integer) 850
   budgetRemaining: (double) 1250.5

   transfers: (map)
     used: (integer) 2
     remaining: (integer) 3

   lastUpdated: (timestamp) Dec 3, 2025
   createdAt: (timestamp) Nov 1, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /fantasySquads/{squadId} {
  allow read: if resource.data.uid == request.auth.uid || isLeagueMember(resource.data.leagueId, request.auth.uid);
  allow write: if resource.data.uid == request.auth.uid;
}
```

---

### Phase 2: Supporting Collections

#### Step 7: Create "feed" Subcollection under "leagues"

1. Navigate to a league document
2. Click **Add subcollection**
3. Subcollection ID: `feed`
4. Document ID: Auto-generated
5. Add sample document:
   ```
   id: (string) feed-001
   type: (string) transfer
   userId: (reference) users/user-123
   content: (string) Transferred Messi to team

   metadata: (map)
     playerName: (string) Lionel Messi
     fromTeam: (reference) teams/psg
     toTeam: (reference) teams/inter-miami

   createdAt: (timestamp) Dec 3, 2025
   ```
6. Click **Save**

**Firestore Rules to add**:
```javascript
match /leagues/{leagueId}/feed/{feedId} {
  allow read: if isLeagueMember(leagueId, request.auth.uid);
  allow create: if request.auth != null && isLeagueMember(leagueId, request.auth.uid);
  allow write: if resource.data.userId == request.auth.uid;
}
```

---

#### Step 8: Create "matchups" Subcollection under "leagues"

1. Navigate to a league document
2. Click **Add subcollection**
3. Subcollection ID: `matchups`
4. Document ID: Custom (e.g., "matchup-1")
5. Add sample document:
   ```
   id: (string) matchup-1
   matchday: (integer) 1
   team1Uid: (reference) users/user-123
   team2Uid: (reference) users/user-456
   team1Score: (integer) 85
   team2Score: (integer) 72
   status: (string) completed
   createdAt: (timestamp) Dec 1, 2025
   completedAt: (timestamp) Dec 3, 2025
   ```
6. Click **Save**

**Firestore Rules to add**:
```javascript
match /leagues/{leagueId}/matchups/{matchupId} {
  allow read: if isLeagueMember(leagueId, request.auth.uid);
  allow create: if request.auth != null && isLeagueMember(leagueId, request.auth.uid);
  allow write: if isAdmin(request.auth.uid);
}
```

---

#### Step 9: Create "matches" Collection

1. Click **Create Collection**
2. Collection ID: `matches`
3. Document ID: Custom (e.g., "match-20241203-1")
4. Add sample document:
   ```
   id: (string) match-20241203-1
   homeTeam: (reference) teams/man-united
   awayTeam: (reference) teams/liverpool
   homeScore: (integer) 3
   awayScore: (integer) 2
   status: (string) completed
   matchday: (integer) 15
   season: (integer) 2024
   league: (string) Premier League
   stadium: (string) Old Trafford
   referee: (string) Mike Dean
   attendance: (integer) 75000

   kickoffTime: (timestamp) Dec 3, 2025 3:00 PM
   completedAt: (timestamp) Dec 3, 2025 5:00 PM

   highlights: (map)
     homeGoalScorers: (array) [Rashford, Hojlund, Garnacho]
     awayGoalScorers: (array) [Salah, Nunez]

   createdAt: (timestamp) Dec 3, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /matches/{matchId} {
  allow read: if true; // Public read
  allow write: if isAdmin(request.auth.uid);
}
```

---

#### Step 10: Create "transfers" Collection

1. Click **Create Collection**
2. Collection ID: `transfers`
3. Document ID: Auto-generated
4. Add sample document:
   ```
   id: (string) transfer-001
   playerId: (reference) players/ronaldo-cr7
   fromTeam: (reference) teams/man-utd
   toTeam: (reference) teams/al-nassr

   transferDate: (timestamp) Jan 1, 2023
   transferFee: (string) €200M
   contractLength: (integer) 2
   jerseyNumber: (integer) 7
   status: (string) completed

   createdAt: (timestamp) Dec 3, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /transfers/{transferId} {
  allow read: if true; // Public read
  allow write: if isAdmin(request.auth.uid);
}
```

---

#### Step 11: Create "seasonHistory" Collection

1. Click **Create Collection**
2. Collection ID: `seasonHistory`
3. Document ID: Custom (e.g., "2023-2024")
4. Add sample document:
   ```
   id: (string) 2023-2024
   season: (integer) 2024
   league: (string) Premier League
   champion: (reference) teams/man-city
   topScorer: (reference) players/ronaldo-cr7
   topAssister: (reference) players/messi-leo
   totalMatches: (integer) 380
   totalGoals: (integer) 1150
   topFantasyPlayer: (reference) players/haaland-erling
   createdAt: (timestamp) Dec 3, 2025
   ```
5. Click **Save**

**Firestore Rules to add**:
```javascript
match /seasonHistory/{seasonId} {
  allow read: if true; // Public read
  allow write: if isAdmin(request.auth.uid);
}
```

---

## Security Rules

**See complete rules in:** `FIRESTORE_SECURITY_RULES.md`

All 11 collections are protected with role-based access control:
- **Public read:** teams, players, matches, transfers, seasonHistory
- **Member-only read:** leagues and subcollections
- **User-owned:** users, fantasySquads
- **Admin write:** All sports data collections

Custom functions are used:
- `isAdmin(uid)` - Check if user is admin
- `isLeagueMember(leagueId, uid)` - Check league membership

---

## Indexes

**See complete indexes in:** `FIRESTORE_INDEXES.json`

Required indexes for efficient queries:

### Critical Indexes (Performance)
- `players` - Sort by fantasyStats.price, fantasyStats.form
- `fantasySquads` - Query by uid and leagueId
- `matches` - Query by season and status
- `transfers` - Query by transferDate
- `leagues/feed` - Query by type and createdAt
- `leagues/matchups` - Query by matchday and status

---

## Testing Collection Setup

### Verification Checklist

- [ ] All 11 collections created in Firestore
- [ ] Sample documents added to each collection
- [ ] All reference fields pointing to correct collections
- [ ] Timestamp fields properly set
- [ ] Array and map fields properly structured
- [ ] Security rules deployed (see FIRESTORE_SECURITY_RULES.md)
- [ ] Indexes created (see FIRESTORE_INDEXES.json)

### Test Reads and Writes

In Firestore Console, for each collection:

1. Click collection name
2. Click **Add document** button
3. Add a test document with all required fields
4. Click **Save** to test write permissions
5. Click document to verify all fields display correctly

### Sample Test Query

```javascript
// Test: Get all fantasy squads for a user
db.collection("fantasySquads")
  .where("uid", "==", "current-user-uid")
  .where("leagueId", "==", "league-001")
  .get()
```

---

## Next Steps

1. ✅ Create all 11 collections using steps above
2. ⏳ Deploy Firestore Security Rules (FIRESTORE_SECURITY_RULES.md)
3. ⏳ Create required Indexes (FIRESTORE_INDEXES.json)
4. ⏳ Test read/write permissions for each collection
5. ⏳ Add seed data using SEED_DATA_INSTRUCTIONS.md

---

## Collection Relationship Diagram

```
users (root)
├── owns → leagues
│         ├── members (subcollection)
│         ├── feed (subcollection)
│         └── matchups (subcollection)
├── owns → fantasySquads
│         └── references → players
├── references → teams
└── references → players

teams (root)
└── referenced by → players, matches, transfers, seasonHistory

players (root)
├── reference → teams
└── referenced by → fantasySquads, matches, transfers, seasonHistory

leagues (root)
├── references → users (creator)
├── contains → members subcollection
├── contains → feed subcollection
└── contains → matchups subcollection

matches (root)
└── reference → teams (home/away)

transfers (root)
├── reference → players
└── reference → teams (from/to)

seasonHistory (root)
└── reference → teams, players

fantasySquads (root)
├── reference → users (owner)
├── reference → leagues
└── contains → players array with references
```

---

## Troubleshooting

### Issue: Reference fields not validating
**Solution:** Make sure the referenced document exists before creating the reference. You can create empty documents first, then add references.

### Issue: Timestamp fields showing wrong time
**Solution:** Ensure your timezone is set correctly in Firestore Console. Timestamps are stored in UTC.

### Issue: Array of maps not displaying correctly
**Solution:** Make sure each map in the array has the same field structure. Firestore requires consistency.

### Issue: Write operations being blocked
**Solution:** Check that your security rules are deployed and your user is authenticated in Firestore Console.

---

## Summary

All 11 collections are now properly structured with:
- ✅ Complete schemas with field types
- ✅ Sample data for testing
- ✅ Reference relationships established
- ✅ Security rules for access control (next file)
- ✅ Indexes for query performance (next file)

**Total Implementation Time:** ~45-60 minutes (including data entry)

---

**Last Updated:** December 3, 2025
**Status:** Complete - Ready for Security Rules and Indexes Deployment

