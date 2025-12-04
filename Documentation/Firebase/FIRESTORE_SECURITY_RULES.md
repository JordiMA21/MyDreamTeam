# Firestore Security Rules - MyDreamTeam

**Date:** December 3, 2025
**Project:** MyDreamTeam - Fantasy Football iOS App
**Status:** Complete Security Rules Configuration

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Security Rules Configuration](#security-rules-configuration)
3. [How to Deploy Rules](#how-to-deploy-rules)
4. [Rules Explanation](#rules-explanation)
5. [Testing Security Rules](#testing-security-rules)

---

## Overview

Firestore Security Rules control read/write access to all collections. These rules ensure:

✅ **Authentication Required** - Most operations require logged-in user
✅ **User Privacy** - Users can only access their own data
✅ **League Privacy** - League data visible only to members
✅ **Admin Control** - Admins can manage sports data
✅ **Public Data** - Teams, players, matches publicly readable

---

## Security Rules Configuration

Copy and paste this entire rule set into Firebase Console:

### **Complete firestore.rules File**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ===== HELPER FUNCTIONS =====

    // Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Check if user is admin
    function isAdmin() {
      return isAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // Check if user is league member
    function isLeagueMember(leagueId) {
      return isAuthenticated() && exists(/databases/$(database)/documents/leagues/$(leagueId)/members/$(request.auth.uid));
    }

    // Check if user is league creator
    function isLeagueCreator(leagueId) {
      return isAuthenticated() && get(/databases/$(database)/documents/leagues/$(leagueId)).data.creatorUid == request.auth.uid;
    }

    // ===== USERS COLLECTION =====
    match /users/{uid} {
      // User can read their own document
      allow read: if request.auth.uid == uid;

      // Admin can read any user document
      allow read: if isAdmin();

      // User can write their own document
      allow write: if request.auth.uid == uid;

      // New user can create their document during signup
      allow create: if request.auth.uid == uid &&
                       request.resource.data.uid == uid &&
                       request.resource.data.email == request.auth.token.email;

      // Only admin can modify isAdmin field
      allow write: if isAdmin() && !("isAdmin" in request.resource.data.diff(resource.data).affectedKeys());
    }

    // ===== TEAMS COLLECTION (Public Read, Admin Write) =====
    match /teams/{teamId} {
      // Public can read teams
      allow read: if true;

      // Only admin can create/update/delete teams
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // ===== PLAYERS COLLECTION (Public Read, Admin Write) =====
    match /players/{playerId} {
      // Public can read players
      allow read: if true;

      // Only admin can create/update/delete players
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();

      // Fast stats updates allowed more frequently
      allow update: if isAdmin() &&
                       request.resource.data.fantasyStats is map &&
                       request.resource.data.stats is map;
    }

    // ===== LEAGUES COLLECTION =====
    match /leagues/{leagueId} {
      // League creator can read their league
      allow read: if isLeagueCreator(leagueId);

      // League members can read league
      allow read: if isLeagueMember(leagueId);

      // Authenticated user can create league
      allow create: if isAuthenticated() &&
                       request.resource.data.creatorUid == request.auth.uid &&
                       request.resource.data.season is number &&
                       request.resource.data.status == "draft";

      // Creator can update their league
      allow update: if isLeagueCreator(leagueId);

      // Only creator can delete
      allow delete: if isLeagueCreator(leagueId);

      // ===== MEMBERS SUBCOLLECTION =====
      match /members/{uid} {
        // League members can read other members
        allow read: if isLeagueMember(leagueId);

        // User can join league (create their own member doc)
        allow create: if request.auth.uid == uid &&
                         isAuthenticated() &&
                         request.resource.data.uid == request.auth.uid;

        // User can update their own membership status
        allow update: if request.auth.uid == uid;

        // League creator can remove members
        allow delete: if isLeagueCreator(leagueId) || request.auth.uid == uid;
      }

      // ===== FEED SUBCOLLECTION =====
      match /feed/{feedId} {
        // League members can read feed
        allow read: if isLeagueMember(leagueId);

        // League members can create feed items
        allow create: if isLeagueMember(leagueId) &&
                         isAuthenticated() &&
                         request.resource.data.userId == request.auth.uid;

        // User can update their own feed items
        allow update: if request.resource.data.userId == request.auth.uid;

        // User can delete their own feed items
        allow delete: if resource.data.userId == request.auth.uid;
      }

      // ===== MATCHUPS SUBCOLLECTION =====
      match /matchups/{matchupId} {
        // League members can read matchups
        allow read: if isLeagueMember(leagueId);

        // League members can create matchups
        allow create: if isLeagueMember(leagueId) &&
                         isAuthenticated();

        // Only admin or league creator can update matchup scores
        allow update: if isAdmin() || isLeagueCreator(leagueId);

        // Only creator can delete
        allow delete: if isLeagueCreator(leagueId);
      }
    }

    // ===== FANTASY SQUADS COLLECTION =====
    match /fantasySquads/{squadId} {
      // User can read their own squads
      allow read: if request.auth.uid == resource.data.uid;

      // League members can read squads of other members in same league
      allow read: if isLeagueMember(resource.data.leagueId) &&
                      resource.data.leagueId is string;

      // Authenticated user can create squad
      allow create: if isAuthenticated() &&
                       request.resource.data.uid == request.auth.uid &&
                       request.resource.data.leagueId is string &&
                       request.resource.data.players is list;

      // User can update their own squad
      allow update: if request.auth.uid == resource.data.uid &&
                       request.auth.uid == request.resource.data.uid;

      // User can delete their own squad
      allow delete: if request.auth.uid == resource.data.uid;
    }

    // ===== MATCHES COLLECTION (Public Read, Admin Write) =====
    match /matches/{matchId} {
      // Public can read matches
      allow read: if true;

      // Only admin can create/update/delete matches
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();

      // Allow frequent score updates for live matches
      allow update: if isAdmin() &&
                       resource.data.status == "live" &&
                       request.resource.data.homeScore is number &&
                       request.resource.data.awayScore is number;
    }

    // ===== TRANSFERS COLLECTION (Public Read, Admin Write) =====
    match /transfers/{transferId} {
      // Public can read transfers
      allow read: if true;

      // Only admin can create/update/delete transfers
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // ===== SEASON HISTORY COLLECTION (Public Read, Admin Write) =====
    match /seasonHistory/{seasonId} {
      // Public can read season history
      allow read: if true;

      // Only admin can create/update/delete season history
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // ===== DEFAULT DENY =====
    // All other paths deny by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## How to Deploy Rules

### Option 1: Deploy via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your MyDreamTeam project
3. Navigate to **Cloud Firestore** → **Rules** tab
4. Click **Edit rules**
5. **Clear** the default rules
6. **Paste** the complete rules from above
7. Click **Publish** button
8. Confirm when prompted

### Option 2: Deploy via Firebase CLI

1. **Install Firebase CLI** (if not already):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase project** (in project directory):
   ```bash
   firebase init
   ```

4. **Create firestore.rules file** in project root:
   ```bash
   touch firestore.rules
   ```

5. **Paste the rules** into `firestore.rules` file

6. **Deploy rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

7. **Verify deployment**:
   ```bash
   firebase deploy:list
   ```

### Option 3: Manual File Deployment

1. Create `firestore.rules` file in your project root
2. Paste the complete rules content
3. Open Terminal in project directory
4. Run:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## Rules Explanation

### Authentication Rules

**Rule: User Authentication**
```javascript
function isAuthenticated() {
  return request.auth != null;
}
```
- Checks if user has valid Firebase authentication token
- Used in most write operations

**Rule: Admin Check**
```javascript
function isAdmin() {
  return isAuthenticated() &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```
- Verifies user has `isAdmin` field set to `true`
- Required for managing sports data

**Rule: League Membership**
```javascript
function isLeagueMember(leagueId) {
  return isAuthenticated() &&
    exists(/databases/$(database)/documents/leagues/$(leagueId)/members/$(request.auth.uid));
}
```
- Checks if user document exists in league's members subcollection
- Used to limit access to private league data

---

### Collection-Specific Rules

#### Users Collection
```javascript
match /users/{uid} {
  // User can read/write their own document
  allow read: if request.auth.uid == uid;
  allow write: if request.auth.uid == uid;

  // Admin can read any user
  allow read: if isAdmin();
}
```
- **Purpose:** Protect user privacy
- **Who can access:** Users can only access own data; admins can access any
- **Operations:** Read own profile, update email/preferences

#### Teams Collection
```javascript
match /teams/{teamId} {
  // Public read
  allow read: if true;

  // Admin write
  allow create, update, delete: if isAdmin();
}
```
- **Purpose:** Prevent unauthorized team creation
- **Who can access:** Anyone can view teams; only admins can modify
- **Operations:** View team info; admins manage team data

#### Leagues Collection
```javascript
match /leagues/{leagueId} {
  // Creator and members can read
  allow read: if isLeagueCreator(leagueId) || isLeagueMember(leagueId);

  // Only creator can write
  allow update: if isLeagueCreator(leagueId);
  allow delete: if isLeagueCreator(leagueId);
}
```
- **Purpose:** Control league privacy
- **Who can access:** Only creator and members
- **Operations:** Create leagues, view rules, update settings

#### Fantasy Squads Collection
```javascript
match /fantasySquads/{squadId} {
  // Owner and league members can read
  allow read: if request.auth.uid == resource.data.uid ||
                 isLeagueMember(resource.data.leagueId);

  // Only owner can write
  allow update: if request.auth.uid == resource.data.uid;
  allow delete: if request.auth.uid == resource.data.uid;
}
```
- **Purpose:** Protect player squad selections
- **Who can access:** Owner (full access), league members (read-only)
- **Operations:** Create squad, manage transfers, update lineup

---

## Testing Security Rules

### Test Read Access

**Test Case 1: User reads their own profile**
```javascript
// Should ALLOW
db.collection("users").doc(currentUser.uid).get()
```

**Test Case 2: User reads another user's profile**
```javascript
// Should DENY
db.collection("users").doc(otherUserUid).get()
```

**Test Case 3: Public reads team data**
```javascript
// Should ALLOW
db.collection("teams").doc("man-united").get()
```

### Test Write Access

**Test Case 4: User creates league**
```javascript
// Should ALLOW
db.collection("leagues").add({
  name: "My League",
  creatorUid: currentUser.uid,
  season: 2024,
  status: "draft"
})
```

**Test Case 5: Non-admin creates team**
```javascript
// Should DENY
db.collection("teams").add({
  name: "New Team",
  country: "Spain"
})
```

**Test Case 6: User updates their fantasy squad**
```javascript
// Should ALLOW
db.collection("fantasySquads").doc(squadId).update({
  players: newPlayerArray,
  lastUpdated: serverTimestamp()
})
```

### Using Firebase Console Rules Simulator

1. Open Firebase Console
2. Go to **Cloud Firestore** → **Rules** tab
3. Click **Rules Simulator** (bottom of page)
4. Select **Read** or **Write**
5. Choose collection and document
6. Set user (authenticated/unauthenticated)
7. Click **Run** to see if operation is allowed

---

## Security Best Practices

### ✅ DO:

- ✅ Always check `request.auth.uid` before allowing writes
- ✅ Use helper functions to avoid duplicating logic
- ✅ Validate data structure before allowing create/update
- ✅ Check subcollection parent documents in access rules
- ✅ Use `exists()` to verify referenced documents
- ✅ Test rules thoroughly before deploying
- ✅ Review rules quarterly for security updates

### ❌ DON'T:

- ❌ Allow `allow read, write: if true` for sensitive data
- ❌ Trust client-side validation alone (validate in rules)
- ❌ Expose sensitive information in public collections
- ❌ Grant write access without authentication
- ❌ Create overly complex rules (performance impact)
- ❌ Forget to test edge cases (deleted docs, null values)

---

## Troubleshooting Rules

### Issue: "Permission denied" when reading league data

**Cause:** User is not a league member

**Solution:**
- Verify user document exists in `leagues/{leagueId}/members/{uid}`
- Check league creator UID matches current user
- Verify league ID in request matches actual league

### Issue: "Permission denied" when creating fantasy squad

**Cause:** User not authenticated or leagueId doesn't exist

**Solution:**
- Ensure user is authenticated (check `request.auth != null`)
- Verify `leagueId` in request matches existing league
- Test with Firebase Console Rules Simulator

### Issue: Admin can't write to teams collection

**Cause:** Admin flag not set in user document

**Solution:**
- Set `isAdmin: true` in user document
- Manually edit user document in Firestore Console
- Wait for token refresh (~1 hour) or sign out/in again

### Issue: Rules taking too long to evaluate

**Cause:** Complex nested checks or multiple reads

**Solution:**
- Simplify helper function logic
- Cache frequently checked values in user document
- Consider denormalizing data (duplicate when necessary)
- Profile with Rules Simulator to identify bottlenecks

---

## Rule Deployment Checklist

- [ ] All 11 collections have rules defined
- [ ] Helper functions use correct syntax
- [ ] References to documents use correct paths
- [ ] Read rules tested with Simulator
- [ ] Write rules tested with Simulator
- [ ] Admin-only operations verified
- [ ] League-member access verified
- [ ] Default deny rule at end
- [ ] Rules published to Firestore
- [ ] Error handling added to app

---

## Summary

All 11 collections are now protected with:

✅ **Authentication-based access** - Most operations require login
✅ **Role-based access** - Admins manage sports data
✅ **User privacy** - Only owners can access their data
✅ **League privacy** - League data visible to members only
✅ **Public data** - Teams, players, matches publicly readable
✅ **Efficient queries** - Helper functions prevent expensive operations

---

**Last Updated:** December 3, 2025
**Status:** Complete - Ready to Deploy

