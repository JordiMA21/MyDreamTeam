# Firebase Schema Design - MyDreamTeam

Version: 1.0
Date: 2025-12-02
Status: PRODUCTION READY

---

## Table of Contents

1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [Collections](#collections)
4. [Query Patterns](#query-patterns)
5. [Indexes](#indexes)
6. [Relationships](#relationships)
7. [Performance Considerations](#performance-considerations)
8. [Scaling Strategy](#scaling-strategy)

---

## Overview

MyDreamTeam uses Firebase Firestore as its primary database for structured data and Firebase Realtime Database for live match updates. This schema is designed for:

- 1M+ potential users
- Real-time updates for live matches
- Efficient querying for fantasy football operations
- Optimized read/write costs
- Strong data consistency
- Easy maintenance and evolution

### Core Entities

| Entity | Collection | Type | Documents (est.) |
|--------|-----------|------|------------------|
| Users | `users` | Root | 1M+ |
| Teams | `teams` | Root | 1K |
| Players | `players` | Root | 30K |
| Leagues | `leagues` | Root | 100K+ |
| Fantasy Squads | `fantasySquads` | Root | 500K+ |
| Matches | `matches` | Root | 10K/season |
| League Members | `leagueMembers` | Subcollection | 5M+ |
| League Feed | `leagueFeed` | Subcollection | 10M+ |

---

## Design Philosophy

### 1. Normalization vs Denormalization

**Normalized Collections:**
- `users` - Single source of truth
- `teams` - Reference data
- `players` - Reference data with frequent updates

**Denormalized Data:**
- Player names/positions in `fantasySquads` (avoid joins)
- Team names in `matches` (display without extra reads)
- User display names in `leagueFeed` (performance)

### 2. Subcollections Strategy

**Use subcollections when:**
- 100+ documents per parent (e.g., `leagueMembers`)
- Need independent queries (e.g., `leagueFeed`)
- Data grows unbounded (e.g., `matchHistory`)

**Use arrays when:**
- < 100 items and stable size
- Always accessed together (e.g., `scoringRules`)
- No independent queries needed

### 3. Read/Write Optimization

**Read Optimization:**
- Denormalize frequently accessed data
- Use composite indexes for common queries
- Paginate large result sets (limit: 20-50)

**Write Optimization:**
- Batch operations where possible
- Use transactions for consistency
- Update denormalized data async (Cloud Functions)

---

## Collections

### 1. users

**Path:** `/users/{userId}`

```javascript
{
  // Identity
  "uid": "string",                    // Firebase Auth UID (indexed)
  "email": "string",                  // Unique email
  "displayName": "string",            // Public name
  "profileImage": "string",           // URL or null
  "bio": "string",                    // 500 chars max

  // Metadata
  "createdAt": Timestamp,             // Account creation
  "updatedAt": Timestamp,             // Last profile update
  "lastLoginAt": Timestamp,           // Last login time

  // Preferences
  "preferences": {
    "favoriteTeamId": "string",       // Team reference
    "favoriteLeagues": ["string"],    // League IDs (max 10)
    "notifications": {
      "email": boolean,
      "push": boolean,
      "leagueUpdates": boolean,
      "playerNews": boolean
    },
    "language": "string",             // "es", "en"
    "theme": "string"                 // "light", "dark"
  },

  // Statistics
  "stats": {
    "leaguesCreated": number,         // Total leagues created
    "leaguesJoined": number,          // Active leagues
    "totalPoints": number,            // All-time points
    "highestRank": number,            // Best rank achieved
    "seasonsPlayed": number           // Number of seasons
  },

  // Status
  "status": "string",                 // "active", "inactive", "suspended"
  "isPremium": boolean,               // Premium subscription
  "premiumUntil": Timestamp           // Premium expiration
}
```

**Indexes:**
```
- uid (single field, asc)
- email (single field, asc)
- createdAt (single field, desc)
- status (single field, asc)
- stats.totalPoints (single field, desc)
```

**Subcollections:**
- `fantasySquads` (user's fantasy squads)
- `notifications` (user notifications)
- `achievements` (earned achievements)

**Security:**
- Read: Public (basic info), authenticated (full)
- Write: Owner only

**Estimated Size:**
- 1M users
- ~2KB per document
- Total: ~2GB

---

### 2. teams

**Path:** `/teams/{teamId}`

```javascript
{
  // Identity
  "teamId": "string",                 // Unique identifier
  "name": "string",                   // Team name
  "shortName": "string",              // Abbreviation (3 chars)
  "alternativeNames": ["string"],     // Aliases for search

  // Info
  "country": "string",                // Country code (ES, EN)
  "city": "string",                   // City name
  "founded": number,                  // Year founded
  "league": "string",                 // League name
  "division": number,                 // 1, 2, etc.

  // Venue
  "stadium": "string",                // Stadium name
  "capacity": number,                 // Stadium capacity

  // Branding
  "logo": "string",                   // Logo URL
  "colors": {
    "primary": "string",              // Hex color
    "secondary": "string",            // Hex color
    "accent": "string"                // Hex color
  },

  // Management
  "coach": "string",                  // Current coach
  "president": "string",              // Club president

  // Stats (current season)
  "season": number,                   // 2024, 2025
  "stats": {
    "played": number,
    "won": number,
    "drawn": number,
    "lost": number,
    "goalsFor": number,
    "goalsAgainst": number,
    "goalDifference": number,
    "points": number,
    "position": number,                // League position
    "form": ["string"]                 // Last 5: W, D, L
  },

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "lastStatsUpdate": Timestamp
}
```

**Indexes:**
```
- teamId (single field, asc)
- league + season (composite, asc)
- country + league (composite, asc)
- stats.position (single field, asc)
- name (single field, asc) - for search
```

**Security:**
- Read: Public
- Write: Admin only

**Estimated Size:**
- 1,000 teams
- ~3KB per document
- Total: ~3MB

---

### 3. players

**Path:** `/players/{playerId}`

```javascript
{
  // Identity
  "playerId": "string",               // Unique identifier
  "firstName": "string",              // First name
  "lastName": "string",               // Last name
  "fullName": "string",               // Full name (indexed)
  "nickname": "string",               // Common nickname

  // Personal Info
  "nationality": "string",            // Country code
  "dateOfBirth": Timestamp,           // Birth date
  "age": number,                      // Calculated age
  "placeOfBirth": "string",           // Birth city

  // Physical
  "height": number,                   // cm
  "weight": number,                   // kg
  "foot": "string",                   // "left", "right", "both"

  // Career
  "position": "string",               // "GK", "DEF", "MID", "FWD"
  "secondaryPositions": ["string"],   // Alternative positions
  "number": number,                   // Jersey number
  "currentTeamId": "string",          // Team reference (indexed)
  "currentTeamName": "string",        // Denormalized
  "contractUntil": Timestamp,         // Contract expiration

  // Status
  "status": "string",                 // "active", "injured", "suspended", "loaned"
  "injuryDetails": {
    "type": "string",                 // Injury type
    "expectedReturn": Timestamp,      // Expected return date
    "severity": "string"              // "minor", "moderate", "severe"
  },
  "suspensionDetails": {
    "matchesRemaining": number,
    "reason": "string",
    "until": Timestamp
  },

  // Season Data
  "season": number,                   // 2024, 2025

  // Statistics (current season)
  "stats": {
    "appearances": number,
    "starts": number,
    "minutesPlayed": number,
    "goals": number,
    "assists": number,
    "yellowCards": number,
    "redCards": number,
    "cleanSheets": number,            // For GK/DEF
    "saves": number,                  // For GK
    "penaltiesSaved": number,         // For GK
    "penaltiesMissed": number,
    "ownGoals": number,
    "averageRating": number           // 0-10
  },

  // Fantasy Points
  "fantasyStats": {
    "totalPoints": number,            // Season total
    "lastWeekPoints": number,         // Last gameweek
    "averagePoints": number,          // Per game
    "selectedBy": number,             // % of fantasy teams
    "priceChange": number             // Last price change
  },

  // Market Value
  "marketValue": {
    "amount": number,                 // Value in EUR
    "currency": "string",             // "EUR"
    "lastUpdated": Timestamp,
    "trend": "string"                 // "up", "down", "stable"
  },

  // Media
  "photo": "string",                  // Photo URL
  "thumbnailPhoto": "string",         // Thumbnail URL

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "lastStatsUpdate": Timestamp
}
```

**Indexes:**
```
- playerId (single field, asc)
- currentTeamId + season (composite, asc)
- position + season + status (composite, asc)
- status + season (composite, asc)
- fullName (single field, asc) - for search
- fantasyStats.totalPoints (single field, desc)
- marketValue.amount (single field, desc)
```

**Security:**
- Read: Public
- Write: Admin only

**Estimated Size:**
- 30,000 players
- ~4KB per document
- Total: ~120MB

---

### 4. leagues

**Path:** `/leagues/{leagueId}`

```javascript
{
  // Identity
  "leagueId": "string",               // Auto-generated ID
  "name": "string",                   // League name
  "description": "string",            // Description (1000 chars)
  "code": "string",                   // Invite code (6 chars)

  // Ownership
  "createdBy": "string",              // User ID (indexed)
  "creatorName": "string",            // Denormalized
  "admins": ["string"],               // Additional admin IDs

  // Configuration
  "season": number,                   // 2024, 2025 (indexed)
  "maxMembers": number,               // Max players (default: 20)
  "currentMembers": number,           // Current count
  "isPublic": boolean,                // Public/private
  "requiresApproval": boolean,        // Approval to join

  // Status
  "status": "string",                 // "draft", "active", "finished", "cancelled"

  // Dates
  "startDate": Timestamp,             // Season start
  "endDate": Timestamp,               // Season end
  "draftDate": Timestamp,             // Draft date (if applicable)
  "transferDeadline": Timestamp,      // Last transfer date

  // Settings
  "settings": {
    "squadSize": number,              // 15 players
    "startingEleven": number,         // 11 players
    "budget": number,                 // 100M EUR
    "transfersPerWeek": number,       // Free transfers
    "wildcards": number,              // Wildcard chips
    "allowWaivers": boolean,          // Waiver system
    "playoffWeeks": number            // Playoff weeks
  },

  // Scoring Rules
  "scoringRules": {
    // Goals
    "goalGK": number,                 // 10 points
    "goalDEF": number,                // 6 points
    "goalMID": number,                // 5 points
    "goalFWD": number,                // 4 points

    // Assists
    "assist": number,                 // 3 points

    // Clean Sheets
    "cleanSheetGK": number,           // 4 points
    "cleanSheetDEF": number,          // 4 points
    "cleanSheetMID": number,          // 1 point

    // Cards
    "yellowCard": number,             // -1 point
    "redCard": number,                // -3 points

    // Saves (GK)
    "saveEvery3": number,             // 1 point per 3 saves
    "penaltySaved": number,           // 5 points
    "penaltyMissed": number,          // -2 points

    // Bonus
    "minutesPlayed60": number,        // 1 point if played 60+ min
    "minutesPlayed90": number,        // 2 points if played full match
    "ownGoal": number,                // -2 points
    "goalsConceededEvery2": number    // -1 per 2 goals (GK/DEF)
  },

  // Branding
  "image": "string",                  // League logo URL
  "banner": "string",                 // Banner image URL

  // Statistics
  "stats": {
    "totalPoints": number,            // All members combined
    "averagePoints": number,          // Average per member
    "highestScore": number,           // Highest single week
    "totalTransfers": number          // Total transfers made
  },

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "lastActivityAt": Timestamp
}
```

**Indexes:**
```
- leagueId (single field, asc)
- createdBy + season (composite, asc)
- status + season (composite, asc)
- season + isPublic (composite, asc)
- createdAt (single field, desc)
- code (single field, asc) - for invite
```

**Subcollections:**
- `members/{userId}` (league members)
- `feed/{postId}` (league feed/activity)
- `matchups/{matchupId}` (head-to-head matchups)
- `standings/{userId}` (current standings)

**Security:**
- Read: Public (if isPublic), members only (if private)
- Write: Creator/admins only

**Estimated Size:**
- 100,000 leagues
- ~3KB per document
- Total: ~300MB

---

### 5. leagues/{leagueId}/members/{userId}

**Path:** `/leagues/{leagueId}/members/{userId}`

```javascript
{
  // Identity
  "userId": "string",                 // User reference
  "leagueId": "string",               // Parent league
  "displayName": "string",            // Denormalized
  "profileImage": "string",           // Denormalized

  // Team Info
  "teamName": "string",               // Fantasy team name
  "teamLogo": "string",               // Team logo URL

  // Status
  "status": "string",                 // "active", "inactive", "kicked"
  "joinedAt": Timestamp,              // Join date
  "leftAt": Timestamp,                // Leave date (if applicable)

  // Squad
  "squadId": "string",                // Current squad reference
  "formation": "string",              // "4-3-3", "3-5-2"

  // Points
  "totalPoints": number,              // Season total (indexed)
  "lastWeekPoints": number,           // Last gameweek
  "averagePoints": number,            // Per gameweek
  "highestPoints": number,            // Best single week

  // Rankings
  "rank": number,                     // Current rank (indexed)
  "previousRank": number,             // Last week rank
  "highestRank": number,              // Best rank achieved

  // Record
  "matchesPlayed": number,            // H2H matches played
  "wins": number,                     // H2H wins
  "draws": number,                    // H2H draws
  "losses": number,                   // H2H losses

  // Transfers
  "transfersUsed": number,            // Transfers used
  "transfersRemaining": number,       // Transfers left
  "wildcardUsed": boolean,            // Wildcard used
  "freeHitUsed": boolean,             // Free hit used

  // Budget
  "budget": {
    "initial": number,                // 100M
    "current": number,                // Current budget
    "teamValue": number               // Squad value
  },

  // Metadata
  "updatedAt": Timestamp,
  "lastTransferAt": Timestamp
}
```

**Indexes:**
```
- leagueId + totalPoints (composite, desc)
- leagueId + rank (composite, asc)
- userId (single field, asc)
- status (single field, asc)
```

**Security:**
- Read: League members only
- Write: Owner only, league admins (limited)

**Estimated Size:**
- 5M league memberships (avg 50 per league)
- ~1.5KB per document
- Total: ~7.5GB

---

### 6. fantasySquads

**Path:** `/fantasySquads/{squadId}`

```javascript
{
  // Identity
  "squadId": "string",                // Auto-generated
  "userId": "string",                 // Owner (indexed)
  "leagueId": "string",               // League reference (indexed)

  // Info
  "name": "string",                   // Squad name
  "formation": "string",              // "4-3-3", "3-5-2", "4-4-2"

  // Status
  "isActive": boolean,                // Active for this week
  "week": number,                     // Current gameweek
  "season": number,                   // Season year

  // Players (Starting XI)
  "startingXI": [
    {
      "playerId": "string",           // Player reference
      "playerName": "string",         // Denormalized
      "position": "string",           // GK, DEF, MID, FWD
      "teamId": "string",             // Current team
      "teamName": "string",           // Denormalized
      "shirtNumber": number,          // Jersey number
      "isCaptain": boolean,           // Captain (2x points)
      "isViceCaptain": boolean,       // Vice captain
      "points": number,               // Points this week
      "totalPoints": number,          // Season points
      "price": number,                // Current price
      "priceChange": number           // Price change this week
    }
    // ... 11 players
  ],

  // Bench
  "bench": [
    {
      // Same structure as startingXI
    }
    // ... 4 players
  ],

  // Points Summary
  "points": {
    "week": number,                   // This week
    "total": number,                  // Season total
    "average": number,                // Average per week
    "highest": number,                // Best week
    "transfers": number               // Points deducted (transfers)
  },

  // Budget
  "budget": {
    "initial": number,                // 100M
    "spent": number,                  // Money spent
    "remaining": number,              // Money left
    "teamValue": number               // Current squad value
  },

  // Captain Selection
  "captain": "string",                // Captain player ID
  "viceCaptain": "string",            // Vice captain ID

  // Transfers
  "transfers": [
    {
      "transferId": "string",
      "week": number,
      "playerOut": "string",          // Player sold
      "playerOutName": "string",
      "playerIn": "string",           // Player bought
      "playerInName": "string",
      "cost": number,                 // Price difference
      "date": Timestamp
    }
  ],

  // Chips
  "chipsUsed": {
    "wildcard": boolean,              // Unlimited transfers
    "freeHit": boolean,               // One-week changes
    "benchBoost": boolean,            // Bench scores too
    "tripleCaptain": boolean          // Captain gets 3x
  },

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "lastTransferAt": Timestamp
}
```

**Indexes:**
```
- squadId (single field, asc)
- userId + leagueId (composite, asc)
- leagueId + points.total (composite, desc)
- season + week (composite, asc)
- isActive (single field, asc)
```

**Security:**
- Read: Owner, league members (if same league)
- Write: Owner only

**Estimated Size:**
- 500,000 fantasy squads
- ~8KB per document (with transfers history)
- Total: ~4GB

---

### 7. matches

**Path:** `/matches/{matchId}`

```javascript
{
  // Identity
  "matchId": "string",                // Unique match ID

  // Teams
  "homeTeamId": "string",             // Home team reference
  "homeTeamName": "string",           // Denormalized
  "homeTeamLogo": "string",           // Denormalized
  "awayTeamId": "string",             // Away team reference
  "awayTeamName": "string",           // Denormalized
  "awayTeamLogo": "string",           // Denormalized

  // Competition
  "season": number,                   // 2024, 2025 (indexed)
  "league": "string",                 // League name
  "competition": "string",            // "League", "Cup", "Champions"
  "round": number,                    // Gameweek/round

  // Schedule
  "date": Timestamp,                  // Match date (indexed)
  "venue": "string",                  // Stadium name
  "referee": "string",                // Referee name

  // Status
  "status": "string",                 // "scheduled", "live", "finished", "postponed", "cancelled"

  // Score
  "homeScore": number,                // Home goals
  "awayScore": number,                // Away goals
  "halfTimeScore": {
    "home": number,
    "away": number
  },

  // Statistics
  "stats": {
    "possession": {
      "home": number,                 // Percentage
      "away": number
    },
    "shots": {
      "home": number,
      "away": number
    },
    "shotsOnTarget": {
      "home": number,
      "away": number
    },
    "corners": {
      "home": number,
      "away": number
    },
    "fouls": {
      "home": number,
      "away": number
    },
    "yellowCards": {
      "home": number,
      "away": number
    },
    "redCards": {
      "home": number,
      "away": number
    }
  },

  // Events (simplified, full events in Realtime DB)
  "events": [
    {
      "minute": number,               // Match minute
      "type": "string",               // "goal", "yellow", "red", "substitution"
      "team": "string",               // "home", "away"
      "playerId": "string",           // Player reference
      "playerName": "string",         // Denormalized
      "assistPlayerId": "string",     // For goals
      "assistPlayerName": "string"
    }
  ],

  // Attendance
  "attendance": number,               // Stadium attendance

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "finishedAt": Timestamp
}
```

**Indexes:**
```
- matchId (single field, asc)
- date + status (composite, asc)
- season + league + round (composite, asc)
- homeTeamId + season (composite, asc)
- awayTeamId + season (composite, asc)
- status (single field, asc)
```

**Security:**
- Read: Public
- Write: Admin only

**Estimated Size:**
- 10,000 matches per season
- ~5KB per document
- Total: ~50MB per season

---

### 8. leagues/{leagueId}/feed/{postId}

**Path:** `/leagues/{leagueId}/feed/{postId}`

```javascript
{
  // Identity
  "postId": "string",                 // Auto-generated
  "leagueId": "string",               // Parent league

  // Author
  "authorId": "string",               // User reference
  "authorName": "string",             // Denormalized
  "authorImage": "string",            // Denormalized

  // Content
  "type": "string",                   // "transfer", "result", "milestone", "comment", "trash_talk"
  "title": "string",                  // Post title
  "content": "string",                // Post content (2000 chars)

  // References
  "relatedMatch": "string",           // Match ID (if applicable)
  "relatedPlayer": "string",          // Player ID (if applicable)
  "relatedTransfer": "string",        // Transfer ID (if applicable)

  // Engagement
  "likes": number,                    // Total likes
  "likedBy": ["string"],              // User IDs (max 100, then use subcollection)
  "commentsCount": number,            // Total comments

  // Comments (inline for first 10, then subcollection)
  "comments": [
    {
      "commentId": "string",
      "authorId": "string",
      "authorName": "string",
      "authorImage": "string",
      "content": "string",            // 500 chars
      "createdAt": Timestamp,
      "likes": number,
      "likedBy": ["string"]
    }
  ],

  // Visibility
  "visibility": "string",             // "public", "league-only"
  "isPinned": boolean,                // Pinned by admin

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "editedAt": Timestamp
}
```

**Indexes:**
```
- leagueId + createdAt (composite, desc)
- type + createdAt (composite, desc)
- authorId + createdAt (composite, desc)
- isPinned (single field, desc)
```

**Security:**
- Read: League members
- Write: Author only
- Delete: Author or league admin

**Estimated Size:**
- 10M posts across all leagues
- ~2KB per document
- Total: ~20GB

---

### 9. transfers

**Path:** `/transfers/{transferId}`

```javascript
{
  // Identity
  "transferId": "string",             // Auto-generated

  // Player
  "playerId": "string",               // Player reference (indexed)
  "playerName": "string",             // Denormalized
  "playerPhoto": "string",            // Denormalized
  "playerPosition": "string",         // Denormalized

  // Teams
  "fromTeamId": "string",             // Source team (indexed)
  "fromTeamName": "string",           // Denormalized
  "toTeamId": "string",               // Destination team (indexed)
  "toTeamName": "string",             // Denormalized

  // Transfer Details
  "transferFee": {
    "amount": number,                 // Fee in EUR
    "currency": "string",             // "EUR"
    "type": "string"                  // "permanent", "loan", "free"
  },

  // Loan Details (if applicable)
  "loanDetails": {
    "duration": number,               // Months
    "obligatoryBuy": boolean,         // Mandatory purchase
    "buyoutClause": number,           // Optional buyout amount
    "startDate": Timestamp,
    "endDate": Timestamp
  },

  // Dates
  "date": Timestamp,                  // Transfer date (indexed)
  "announcedDate": Timestamp,         // Public announcement
  "effectiveDate": Timestamp,         // When player can play

  // Status
  "status": "string",                 // "rumour", "pending", "completed", "cancelled"

  // Season
  "season": number,                   // Transfer window season (indexed)
  "window": "string",                 // "summer", "winter"

  // Source
  "source": "string",                 // Data source
  "verified": boolean,                // Official confirmation

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Indexes:**
```
- transferId (single field, asc)
- playerId + date (composite, desc)
- date + status (composite, desc)
- season + window (composite, asc)
- fromTeamId + season (composite, asc)
- toTeamId + season (composite, asc)
```

**Security:**
- Read: Public
- Write: Admin only

**Estimated Size:**
- 5,000 transfers per season
- ~1.5KB per document
- Total: ~7.5MB per season

---

### 10. leagues/{leagueId}/matchups/{matchupId}

**Path:** `/leagues/{leagueId}/matchups/{matchupId}`

```javascript
{
  // Identity
  "matchupId": "string",              // Auto-generated
  "leagueId": "string",               // Parent league
  "week": number,                     // Gameweek number (indexed)

  // Teams
  "team1UserId": "string",            // User 1 reference
  "team1Name": "string",              // Denormalized
  "team1Logo": "string",              // Denormalized
  "team1SquadId": "string",           // Squad reference
  "team1Score": number,               // Total points

  "team2UserId": "string",            // User 2 reference
  "team2Name": "string",              // Denormalized
  "team2Logo": "string",              // Denormalized
  "team2SquadId": "string",           // Squad reference
  "team2Score": number,               // Total points

  // Status
  "status": "string",                 // "scheduled", "ongoing", "finished"

  // Dates
  "startDate": Timestamp,             // Matchup start
  "endDate": Timestamp,               // Matchup end

  // Result
  "winner": "string",                 // "team1", "team2", "draw"

  // Details (player performances)
  "team1Details": [
    {
      "playerId": "string",
      "playerName": "string",
      "position": "string",
      "points": number,
      "matchesPlayed": number,
      "goals": number,
      "assists": number
    }
  ],

  "team2Details": [
    // Same structure
  ],

  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "finishedAt": Timestamp
}
```

**Indexes:**
```
- leagueId + week (composite, asc)
- week + status (composite, asc)
- team1UserId (single field, asc)
- team2UserId (single field, asc)
```

**Security:**
- Read: League members
- Write: System only (auto-calculated)

**Estimated Size:**
- 2M matchups (20 weeks x 10 matchups x 10K leagues)
- ~3KB per document
- Total: ~6GB

---

## Query Patterns

### Common Queries (with performance notes)

#### 1. User Queries

```javascript
// Get user profile
GET /users/{userId}
// Cost: 1 read
// Performance: Instant (direct document read)

// Get user's leagues
GET /leagues?where(createdBy == userId)
// Cost: N reads (N = number of leagues)
// Performance: Fast with index
// Optimization: Cache results, paginate

// Get user's squads
GET /fantasySquads?where(userId == userId)
// Cost: N reads
// Performance: Fast with compound index
// Optimization: Paginate, cache active squad
```

#### 2. League Queries

```javascript
// Get league details
GET /leagues/{leagueId}
// Cost: 1 read
// Performance: Instant

// Get league standings
GET /leagues/{leagueId}/members?orderBy(totalPoints, desc)
// Cost: N reads (N = members)
// Performance: Fast with compound index
// Optimization: Limit to top 20, paginate rest

// Get league feed (paginated)
GET /leagues/{leagueId}/feed?orderBy(createdAt, desc).limit(20)
// Cost: 20 reads
// Performance: Fast with index
// Optimization: Infinite scroll, cache first page

// Search public leagues
GET /leagues?where(isPublic == true, season == 2025).orderBy(createdAt, desc).limit(20)
// Cost: 20 reads
// Performance: Fast with compound index
// Optimization: Server-side pagination
```

#### 3. Player Queries

```javascript
// Get player details
GET /players/{playerId}
// Cost: 1 read
// Performance: Instant

// Get team's players
GET /players?where(currentTeamId == teamId, season == 2025)
// Cost: N reads (N = ~25 players)
// Performance: Fast with compound index
// Optimization: Cache team roster

// Search players by position
GET /players?where(position == "FWD", status == "active").orderBy(fantasyStats.totalPoints, desc).limit(50)
// Cost: 50 reads
// Performance: Fast with compound index
// Optimization: Cache top 50 by position

// Search players by name
GET /players?where(fullName >= "Messi", fullName < "Messiz").limit(10)
// Cost: 10 reads
// Performance: Moderate (text search)
// Optimization: Use Algolia for full-text search
```

#### 4. Match Queries

```javascript
// Get match details
GET /matches/{matchId}
// Cost: 1 read
// Performance: Instant

// Get today's matches
GET /matches?where(date >= todayStart, date < todayEnd)
// Cost: N reads (N = ~10 matches)
// Performance: Fast with index
// Optimization: Cache results for 5 minutes

// Get team's upcoming matches
GET /matches?where(homeTeamId == teamId, status == "scheduled").orderBy(date, asc).limit(5)
// Cost: 5 reads
// Performance: Fast with compound index
// Optimization: Cache results

// Get live matches
GET /matches?where(status == "live")
// Cost: N reads (N = ~10 live matches)
// Performance: Fast with index
// Optimization: Use Realtime Database for live updates
```

#### 5. Fantasy Squad Queries

```javascript
// Get user's active squad
GET /fantasySquads?where(userId == userId, isActive == true).limit(1)
// Cost: 1 read
// Performance: Instant with compound index
// Optimization: Cache active squad locally

// Get squad history
GET /fantasySquads?where(userId == userId, leagueId == leagueId).orderBy(week, desc)
// Cost: N reads (N = weeks in season)
// Performance: Fast
// Optimization: Paginate by week ranges

// Get league's best squads (for comparison)
GET /fantasySquads?where(leagueId == leagueId, week == currentWeek).orderBy(points.week, desc).limit(10)
// Cost: 10 reads
// Performance: Fast with compound index
// Optimization: Cache top 10 per week
```

#### 6. Transfer Queries

```javascript
// Get player's transfer history
GET /transfers?where(playerId == playerId).orderBy(date, desc).limit(10)
// Cost: 10 reads
// Performance: Fast with compound index

// Get recent transfers
GET /transfers?where(season == 2025, status == "completed").orderBy(date, desc).limit(20)
// Cost: 20 reads
// Performance: Fast with compound index
// Optimization: Cache recent transfers, update hourly
```

---

## Indexes

### Required Composite Indexes

```javascript
// firestore.indexes.json

{
  "indexes": [
    // Users
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },

    // Teams
    {
      "collectionGroup": "teams",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "league", "order": "ASCENDING" },
        { "fieldPath": "season", "order": "ASCENDING" },
        { "fieldPath": "stats.position", "order": "ASCENDING" }
      ]
    },

    // Players - by team and season
    {
      "collectionGroup": "players",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "currentTeamId", "order": "ASCENDING" },
        { "fieldPath": "season", "order": "ASCENDING" }
      ]
    },

    // Players - by position and points
    {
      "collectionGroup": "players",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "position", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "fantasyStats.totalPoints", "order": "DESCENDING" }
      ]
    },

    // Leagues - by creator
    {
      "collectionGroup": "leagues",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdBy", "order": "ASCENDING" },
        { "fieldPath": "season", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },

    // Leagues - public leagues
    {
      "collectionGroup": "leagues",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isPublic", "order": "ASCENDING" },
        { "fieldPath": "season", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },

    // League Members - standings
    {
      "collectionGroup": "members",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "leagueId", "order": "ASCENDING" },
        { "fieldPath": "totalPoints", "order": "DESCENDING" }
      ]
    },

    // League Members - by rank
    {
      "collectionGroup": "members",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "leagueId", "order": "ASCENDING" },
        { "fieldPath": "rank", "order": "ASCENDING" }
      ]
    },

    // Fantasy Squads - active squads
    {
      "collectionGroup": "fantasySquads",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "leagueId", "order": "ASCENDING" },
        { "fieldPath": "isActive", "order": "ASCENDING" }
      ]
    },

    // Fantasy Squads - by points
    {
      "collectionGroup": "fantasySquads",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "leagueId", "order": "ASCENDING" },
        { "fieldPath": "week", "order": "ASCENDING" },
        { "fieldPath": "points.week", "order": "DESCENDING" }
      ]
    },

    // Matches - by date and status
    {
      "collectionGroup": "matches",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "date", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },

    // Matches - by team
    {
      "collectionGroup": "matches",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "homeTeamId", "order": "ASCENDING" },
        { "fieldPath": "season", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },

    // Matches - league and round
    {
      "collectionGroup": "matches",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "season", "order": "ASCENDING" },
        { "fieldPath": "league", "order": "ASCENDING" },
        { "fieldPath": "round", "order": "ASCENDING" }
      ]
    },

    // League Feed
    {
      "collectionGroup": "feed",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "leagueId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },

    // Transfers - player history
    {
      "collectionGroup": "transfers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "playerId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },

    // Transfers - by season
    {
      "collectionGroup": "transfers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "season", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },

    // Matchups
    {
      "collectionGroup": "matchups",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "leagueId", "order": "ASCENDING" },
        { "fieldPath": "week", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ],

  "fieldOverrides": []
}
```

### Critical Indexes (Create First)

Priority 1 (Week 1):
1. `players`: currentTeamId + season
2. `leagues`: createdBy + season
3. `members`: leagueId + totalPoints (desc)
4. `fantasySquads`: userId + leagueId + isActive
5. `matches`: date + status

Priority 2 (Week 2):
6. `players`: position + status + fantasyStats.totalPoints
7. `feed`: leagueId + createdAt (desc)
8. `matchups`: leagueId + week

Priority 3 (As needed):
9. All remaining indexes based on query patterns

---

## Relationships

### Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Users     │────────>│   Leagues    │<────────│   Teams     │
│             │ creates │              │ follows │             │
└─────┬───────┘         └──────┬───────┘         └──────┬──────┘
      │                        │                        │
      │                        │                        │
      │ owns                   │ contains               │ has
      │                        │                        │
      v                        v                        v
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│Fantasy      │         │League        │         │   Players   │
│Squads       │         │Members       │         │             │
└─────┬───────┘         └──────────────┘         └──────┬──────┘
      │                                                  │
      │ references                                       │
      └──────────────────────────────────────────────────┘
                         includes
```

### Reference Strategy

**Direct References (store ID only):**
- `users.uid` -> Firebase Auth
- `players.currentTeamId` -> teams.teamId
- `fantasySquads.userId` -> users.uid
- `leagues.createdBy` -> users.uid

**Denormalized Data (for performance):**
- Store player name in `fantasySquads.startingXI`
- Store team name in `matches`
- Store user display name in `leagueFeed`

**Why denormalize?**
1. Reduce read operations (cheaper)
2. Faster query response times
3. Acceptable staleness (names rarely change)
4. Update via Cloud Functions when source changes

### Update Strategy for Denormalized Data

```javascript
// Cloud Function: When player name changes
exports.onPlayerUpdate = functions.firestore
  .document('players/{playerId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    if (newData.fullName !== oldData.fullName) {
      // Update all fantasy squads with this player
      const squadsQuery = await db.collection('fantasySquads')
        .where('startingXI', 'array-contains', { playerId: context.params.playerId })
        .get();

      const batch = db.batch();
      squadsQuery.docs.forEach(doc => {
        // Update denormalized name
        batch.update(doc.ref, {
          'startingXI.$.playerName': newData.fullName
        });
      });

      await batch.commit();
    }
  });
```

---

## Performance Considerations

### Read Optimization

**1. Caching Strategy**

```
Cache Level 1 (Client Memory):
- Current user profile (TTL: 5 min)
- Active fantasy squad (TTL: 1 hour)
- Team rosters (TTL: 24 hours)
- Player details (TTL: 6 hours)

Cache Level 2 (Firestore Offline):
- Enabled by default
- Automatic sync when online
- Perfect for read-heavy data

Cache Level 3 (CDN for images):
- Player photos
- Team logos
- League banners
```

**2. Pagination**

```javascript
// Always paginate large collections
const ITEMS_PER_PAGE = 20;

// First page
const firstQuery = collection
  .orderBy('createdAt', 'desc')
  .limit(ITEMS_PER_PAGE);

// Next page
const nextQuery = collection
  .orderBy('createdAt', 'desc')
  .startAfter(lastDoc)
  .limit(ITEMS_PER_PAGE);
```

**3. Selective Field Loading**

```javascript
// Don't load entire documents if you only need specific fields
// Use projection (when available) or structure docs carefully

// Bad: Load entire player (4KB)
const player = await db.collection('players').doc(playerId).get();

// Better: Load only needed fields (client-side filtering)
const player = await db.collection('players').doc(playerId).get();
const { fullName, position, stats } = player.data();
```

### Write Optimization

**1. Batch Writes**

```javascript
// Batch related writes together (max 500 operations)
const batch = db.batch();

// Update multiple documents in one operation
for (const player of players) {
  const ref = db.collection('players').doc(player.id);
  batch.update(ref, player.updates);
}

await batch.commit(); // Single network round-trip
```

**2. Transactions for Consistency**

```javascript
// Use transactions when data must be consistent
await db.runTransaction(async (transaction) => {
  // Read squad
  const squadRef = db.collection('fantasySquads').doc(squadId);
  const squad = await transaction.get(squadRef);

  // Validate transfer (budget check)
  const currentBudget = squad.data().budget.remaining;
  if (playerPrice > currentBudget) {
    throw new Error('Insufficient budget');
  }

  // Update squad (guaranteed consistent)
  transaction.update(squadRef, {
    'budget.remaining': currentBudget - playerPrice,
    'budget.spent': squad.data().budget.spent + playerPrice
  });
});
```

**3. Async Updates (Cloud Functions)**

```javascript
// For non-critical updates, use Cloud Functions
// Example: Update league statistics after a match

exports.updateLeagueStats = functions.firestore
  .document('matches/{matchId}')
  .onUpdate(async (change, context) => {
    // Runs in background, doesn't block client
    const match = change.after.data();

    if (match.status === 'finished') {
      // Update player stats
      // Update team standings
      // Update fantasy points
      // ... all async, no client waiting
    }
  });
```

### Cost Optimization

**Estimated Costs for 100K Active Users:**

```
Reads per Day:
- 100K users x 50 reads/day = 5M reads/day
- Free tier: 50K reads/day
- Paid reads: 4.95M reads/day
- Cost: 4.95M / 100K x $0.036 = $1.78/day = $53.40/month

Writes per Day:
- 100K users x 10 writes/day = 1M writes/day
- Free tier: 20K writes/day
- Paid writes: 980K writes/day
- Cost: 980K / 100K x $0.108 = $1.06/day = $31.80/month

Storage:
- ~10GB total data
- Cost: 10GB x $0.18/GB = $1.80/month

Total Estimated Cost: $87/month for 100K users
```

**Cost Reduction Strategies:**

1. **Cache Aggressively**: Reduce reads by 30-50%
2. **Paginate Everything**: Limit to 20-50 items
3. **Use Offline Persistence**: Free repeated reads
4. **Batch Operations**: Reduce write operations
5. **Archive Old Data**: Move completed seasons to cheaper storage
6. **Use Realtime DB for Live Data**: Cheaper for high-frequency updates

---

## Scaling Strategy

### Scaling to 1 Million Users

**Phase 1: 0-10K Users (Current)**
- ✅ Single region Firestore
- ✅ Standard indexes
- ✅ Client-side caching
- Estimated cost: $50-100/month

**Phase 2: 10K-100K Users**
- Add CDN for static assets
- Implement server-side caching (Redis)
- Use Cloud Functions for heavy operations
- Optimize indexes based on usage
- Estimated cost: $500-1000/month

**Phase 3: 100K-500K Users**
- Multi-region Firestore replication
- Implement data sharding for large collections
- Add read replicas
- Use Cloud Tasks for background jobs
- Implement rate limiting
- Estimated cost: $2000-5000/month

**Phase 4: 500K-1M Users**
- Dedicated Cloud SQL for analytics
- Implement microservices for critical features
- Advanced caching strategies (multi-tier)
- Data archiving for old seasons
- Consider BigQuery for analytics
- Estimated cost: $5000-10000/month

### Data Archiving Strategy

```javascript
// Archive completed seasons to reduce active data size

// Active Season (Firestore):
- Current season data (hot data)
- Fast reads/writes
- Higher cost

// Archived Seasons (Cloud Storage):
- Previous seasons (cold data)
- Export to JSON/Parquet
- Load on-demand
- Much cheaper storage

// Implementation:
exports.archiveSeason = functions.pubsub
  .schedule('every 1 months')
  .onRun(async (context) => {
    const oldSeason = getCurrentSeason() - 1;

    // Export old season to Cloud Storage
    await exportToStorage('fantasySquads', { season: oldSeason });
    await exportToStorage('matches', { season: oldSeason });

    // Delete from Firestore (keep last 2 seasons)
    if (oldSeason < getCurrentSeason() - 2) {
      await deleteOldData('fantasySquads', { season: oldSeason });
    }
  });
```

### Monitoring and Alerts

```javascript
// Key metrics to monitor:

1. Read/Write Operations
   - Alert if > 10M reads/day
   - Alert if > 2M writes/day

2. Query Performance
   - Alert if p95 latency > 500ms
   - Alert if any query > 2s

3. Error Rates
   - Alert if error rate > 1%
   - Alert on permission denied errors

4. Storage Growth
   - Alert if growth > 1GB/day
   - Alert if approaching 100GB total

5. Costs
   - Alert if daily cost > $100
   - Alert if monthly projection > $3000
```

---

## Security Considerations

### Security Rules Overview

See `FIRESTORE_RULES.json` for complete security rules implementation.

**Key Security Principles:**

1. **Principle of Least Privilege**: Users can only access what they need
2. **Validate All Writes**: Check data types, required fields, constraints
3. **No Direct Admin Access**: Admin operations via Cloud Functions only
4. **Rate Limiting**: Prevent abuse via App Check and quotas
5. **Audit Logging**: Log all admin operations

### Data Privacy

```javascript
// PII (Personally Identifiable Information) handling:

Encrypted at Rest:
- User emails
- Profile data
- Payment information (if applicable)

Anonymized in Analytics:
- User IDs hashed
- No email/name in analytics
- Aggregate data only

Data Retention:
- Active users: Indefinite
- Deleted accounts: 30 days grace period, then permanent deletion
- Anonymized stats: Kept for analytics
```

---

## Migration Strategy

### Schema Evolution

```javascript
// How to handle schema changes without downtime:

1. Additive Changes (Safe):
   - Add new fields (optional)
   - Add new collections
   - Add new indexes
   → Deploy immediately, no migration needed

2. Modification (Requires Migration):
   - Rename fields
   - Change data types
   - Split/merge collections
   → Requires data migration

3. Removal (Careful):
   - Remove fields (mark deprecated first)
   - Remove collections (export first)
   → Phase out over 2-3 releases

// Example migration script:
exports.migrateUserPreferences = functions.https
  .onRequest(async (req, res) => {
    // Run once to update all users
    const users = await db.collection('users').get();

    const batch = db.batch();
    users.docs.forEach(doc => {
      if (!doc.data().preferences) {
        batch.update(doc.ref, {
          preferences: {
            notifications: { email: true, push: true },
            language: 'en'
          }
        });
      }
    });

    await batch.commit();
    res.send('Migration complete');
  });
```

---

## Conclusion

This schema is designed to:

✅ Scale to 1M+ users
✅ Minimize read/write costs
✅ Optimize query performance
✅ Maintain data consistency
✅ Enable real-time updates
✅ Support complex fantasy football operations
✅ Easy to maintain and evolve

### Next Steps

1. Review and approve schema
2. Implement security rules
3. Create critical indexes
4. Seed initial data (teams, players)
5. Implement DataSources
6. Build Repositories
7. Create UseCases
8. Test with Firebase emulator

### References

- Firebase Firestore Documentation
- Clean Architecture patterns
- MyDreamTeam CLAUDE.md
- PROJECT_EXECUTION_PLAN.md

---

**Document Version:** 1.0
**Last Updated:** 2025-12-02
**Status:** Ready for Implementation
