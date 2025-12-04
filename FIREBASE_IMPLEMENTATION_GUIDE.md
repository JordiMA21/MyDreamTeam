# Firebase Implementation Guide - MyDreamTeam

## 📋 Table of Contents

1. [Phase 0: Firebase Setup](#phase-0-firebase-setup)
2. [Phase 1: Authentication (Firebase Auth)](#phase-1-authentication-firebase-auth)
3. [Phase 2: Users Collection](#phase-2-users-collection)
4. [Phase 3: Sports Data (Teams, Players, Matches)](#phase-3-sports-data)
5. [Phase 4: Leagues & Fantasy Squads](#phase-4-leagues--fantasy-squads)
6. [Phase 5: Advanced Features](#phase-5-advanced-features)
7. [Phase 6: Security Rules & Indexes](#phase-6-security-rules--indexes)
8. [Testing & Firebase Emulator](#testing--firebase-emulator)

---

## PHASE 0: Firebase Setup

### Step 0.1: Install Firebase SDK via CocoaPods

Edit your `Podfile`:

```ruby
platform :ios, '16.0'

target 'MyDreamTeam' do
  use_frameworks!

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Functions'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'

end
```

Then run:
```bash
cd /Users/jordimiguelaguado/Desktop/Jordi/MyDreamTeam
pod install
```

### Step 0.2: Add GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing: `MyDreamTeam`
3. Download `GoogleService-Info.plist`
4. Drag into Xcode under `MyDreamTeam` folder
5. Check "Copy items if needed"
6. Select target `MyDreamTeam`

### Step 0.3: Configure Firebase in MyDreamTeamApp.swift

Add at the top of your app initialization:

```swift
import Firebase

@main
struct MyDreamTeamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

### Step 0.4: Create Firebase Directory Structure

```
MyDreamTeam/
├── Data/
│   ├── Services/
│   │   └── Firebase/
│   │       ├── Authentication/
│   │       ├── Users/
│   │       ├── Teams/
│   │       ├── Players/
│   │       ├── Matches/
│   │       ├── Leagues/
│   │       ├── Transfers/
│   │       └── Feed/
│   └── Repositories/
├── Domain/
│   ├── Entities/
│   ├── Repositories/
│   └── UseCases/
├── DI/
│   └── Containers/
└── Shared/
```

---

# PHASE 1: Authentication (Firebase Auth)

## Overview
Implement Firebase Authentication to manage user sign-up, sign-in, and session management.

## Architecture Flow
```
View (LoginView)
  → ViewModel (LoginViewModel)
    → Router (AuthRouter)
      → UseCase (AuthenticationUseCase)
        → Repository (AuthenticationRepository)
          → DataSource (FirebaseAuthDataSource)
            → Firebase Auth
```

## Files to Create: 7

### File 1: Domain/Entities/AuthenticatedUser.swift

```swift
import Foundation

struct AuthenticatedUser {
    let id: String
    let email: String
    let displayName: String
    let photoURL: URL?
    let isEmailVerified: Bool
    let createdAt: Date
}
```

### File 2: Data/Services/Firebase/Authentication/FirebaseAuthDataSource.swift

```swift
import Foundation
import FirebaseAuth

protocol FirebaseAuthDataSourceProtocol: AnyObject {
    func signUp(email: String, password: String) async throws -> AuthUserDTO
    func signIn(email: String, password: String) async throws -> AuthUserDTO
    func signOut() async throws
    func getCurrentUser() -> AuthUserDTO?
    func deleteAccount() async throws
}

final class FirebaseAuthDataSource: FirebaseAuthDataSourceProtocol {
    private let auth = Auth.auth()

    func signUp(email: String, password: String) async throws -> AuthUserDTO {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return AuthUserDTO(from: result.user)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthUserDTO {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return AuthUserDTO(from: result.user)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func signOut() async throws {
        do {
            try auth.signOut()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    func getCurrentUser() -> AuthUserDTO? {
        guard let user = auth.currentUser else { return nil }
        return AuthUserDTO(from: user)
    }

    func deleteAccount() async throws {
        do {
            try await auth.currentUser?.delete()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    private func mapFirebaseError(_ error: NSError) -> AppError {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .generalError(message: error.localizedDescription)
        }

        switch code {
        case .invalidEmail:
            return .inputError(message: "Email inválido")
        case .weakPassword:
            return .inputError(message: "La contraseña es demasiado débil (mínimo 6 caracteres)")
        case .emailAlreadyInUse:
            return .customError(message: "El email ya está registrado")
        case .userNotFound:
            return .badCredentials
        case .wrongPassword:
            return .badCredentials
        case .networkError:
            return .noInternet
        default:
            return .generalError(message: error.localizedDescription)
        }
    }
}
```

### File 3: Data/Services/Firebase/Authentication/AuthenticationDTO.swift

```swift
import Foundation
import FirebaseAuth

struct AuthUserDTO {
    let id: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    let isEmailVerified: Bool
    let createdDate: Date

    init(from user: User) {
        self.id = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL
        self.isEmailVerified = user.isEmailVerified
        self.createdDate = user.metadata.creationDate ?? Date()
    }
}

extension AuthUserDTO {
    func toDomain() -> AuthenticatedUser {
        AuthenticatedUser(
            id: id,
            email: email ?? "",
            displayName: displayName ?? "",
            photoURL: photoURL,
            isEmailVerified: isEmailVerified,
            createdAt: createdDate
        )
    }
}
```

### File 4: Domain/Repositories/AuthenticationRepositoryProtocol.swift

```swift
import Foundation

protocol AuthenticationRepositoryProtocol: AnyObject {
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() async throws
    func getCurrentUser() -> AuthenticatedUser?
    func deleteAccount() async throws
}
```

### File 5: Data/Repositories/AuthenticationRepository.swift

```swift
import Foundation

final class AuthenticationRepository: AuthenticationRepositoryProtocol {
    private let dataSource: FirebaseAuthDataSourceProtocol

    init(dataSource: FirebaseAuthDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        let dto = try await dataSource.signUp(email: email, password: password)
        return dto.toDomain()
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        let dto = try await dataSource.signIn(email: email, password: password)
        return dto.toDomain()
    }

    func signOut() async throws {
        try await dataSource.signOut()
    }

    func getCurrentUser() -> AuthenticatedUser? {
        dataSource.getCurrentUser()?.toDomain()
    }

    func deleteAccount() async throws {
        try await dataSource.deleteAccount()
    }
}
```

### File 6: Domain/UseCases/AuthenticationUseCase.swift

```swift
import Foundation

protocol AuthenticationUseCaseProtocol: AnyObject {
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() async throws
    func getCurrentUser() -> AuthenticatedUser?
    func deleteAccount() async throws
}

final class AuthenticationUseCase: AuthenticationUseCaseProtocol {
    private let repository: AuthenticationRepositoryProtocol

    init(repository: AuthenticationRepositoryProtocol) {
        self.repository = repository
    }

    func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        try await repository.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        try await repository.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await repository.signOut()
    }

    func getCurrentUser() -> AuthenticatedUser? {
        repository.getCurrentUser()
    }

    func deleteAccount() async throws {
        try await repository.deleteAccount()
    }
}
```

### File 7: DI/Containers/AuthenticationContainer.swift

```swift
import Foundation

final class AuthenticationContainer {
    static let shared = AuthenticationContainer()
    private init() {}

    func makeUseCase() -> AuthenticationUseCaseProtocol {
        let dataSource = FirebaseAuthDataSource()
        let repository = AuthenticationRepository(dataSource: dataSource)
        return AuthenticationUseCase(repository: repository)
    }
}
```

---

## Phase 1: Implementation Checklist

- [ ] Step 0.1: Install Firebase SDK
- [ ] Step 0.2: Add GoogleService-Info.plist
- [ ] Step 0.3: Configure Firebase in AppDelegate
- [ ] Step 0.4: Create Firebase directory structure
- [ ] Create File 1: AuthenticatedUser.swift
- [ ] Create File 2: FirebaseAuthDataSource.swift
- [ ] Create File 3: AuthenticationDTO.swift
- [ ] Create File 4: AuthenticationRepositoryProtocol.swift
- [ ] Create File 5: AuthenticationRepository.swift
- [ ] Create File 6: AuthenticationUseCase.swift
- [ ] Create File 7: AuthenticationContainer.swift
- [ ] Build project and verify no compilation errors
- [ ] Test Firebase connection with Firebase Emulator

---

# PHASE 2: Users Collection

> **Status:** Pending
> **Start after:** Phase 1 completes

## Overview
Create the `users` Firestore collection to store user profiles.

## Files to Create: 7

### File 8: Domain/Entities/User.swift

```swift
import Foundation

struct User: Identifiable, Codable {
    let id: String
    let uid: String
    let email: String
    let displayName: String
    let profileImage: String?
    let bio: String?
    let createdAt: Date
    let updatedAt: Date
    let preferences: UserPreferences
    let stats: UserStats
    let status: UserStatus
}

struct UserPreferences: Codable {
    let favoriteTeamId: String?
    let favoriteLeagues: [String]
    let notifications: NotificationSettings
    let language: String
    let theme: String
}

struct NotificationSettings: Codable {
    let email: Bool
    let push: Bool
    let leagueUpdates: Bool
    let playerNews: Bool
}

struct UserStats: Codable {
    let leaguesCreated: Int
    let leaguesJoined: Int
    let totalPoints: Int
    let highestRank: Int
    let seasonsPlayed: Int
}

enum UserStatus: String, Codable {
    case active
    case inactive
    case suspended
}
```

### File 9: Data/Services/Firebase/Users/UserDTO.swift

```swift
import Foundation
import FirebaseFirestore

struct UserDTO: Codable {
    let uid: String
    let email: String
    let displayName: String
    let profileImage: String?
    let bio: String?
    let createdAt: Timestamp
    let updatedAt: Timestamp
    let preferences: UserPreferencesDTO
    let stats: UserStatsDTO
    let status: String
}

struct UserPreferencesDTO: Codable {
    let favoriteTeamId: String?
    let favoriteLeagues: [String]?
    let notifications: NotificationSettingsDTO
    let language: String
    let theme: String
}

struct NotificationSettingsDTO: Codable {
    let email: Bool
    let push: Bool
    let leagueUpdates: Bool
    let playerNews: Bool
}

struct UserStatsDTO: Codable {
    let leaguesCreated: Int
    let leaguesJoined: Int
    let totalPoints: Int
    let highestRank: Int
    let seasonsPlayed: Int
}

extension UserDTO {
    func toDomain(documentId: String) -> User {
        User(
            id: documentId,
            uid: uid,
            email: email,
            displayName: displayName,
            profileImage: profileImage,
            bio: bio,
            createdAt: createdAt.dateValue(),
            updatedAt: updatedAt.dateValue(),
            preferences: preferences.toDomain(),
            stats: stats.toDomain(),
            status: UserStatus(rawValue: status) ?? .active
        )
    }
}

extension UserPreferencesDTO {
    func toDomain() -> UserPreferences {
        UserPreferences(
            favoriteTeamId: favoriteTeamId,
            favoriteLeagues: favoriteLeagues ?? [],
            notifications: notifications.toDomain(),
            language: language,
            theme: theme
        )
    }
}

extension NotificationSettingsDTO {
    func toDomain() -> NotificationSettings {
        NotificationSettings(
            email: email,
            push: push,
            leagueUpdates: leagueUpdates,
            playerNews: playerNews
        )
    }
}

extension UserStatsDTO {
    func toDomain() -> UserStats {
        UserStats(
            leaguesCreated: leaguesCreated,
            leaguesJoined: leaguesJoined,
            totalPoints: totalPoints,
            highestRank: highestRank,
            seasonsPlayed: seasonsPlayed
        )
    }
}

// Helper extension for domain to DTO
extension User {
    func toDTO() -> UserDTO {
        UserDTO(
            uid: uid,
            email: email,
            displayName: displayName,
            profileImage: profileImage,
            bio: bio,
            createdAt: Timestamp(date: createdAt),
            updatedAt: Timestamp(date: updatedAt),
            preferences: preferences.toDTO(),
            stats: stats.toDTO(),
            status: status.rawValue
        )
    }
}

extension UserPreferences {
    func toDTO() -> UserPreferencesDTO {
        UserPreferencesDTO(
            favoriteTeamId: favoriteTeamId,
            favoriteLeagues: favoriteLeagues,
            notifications: notifications.toDTO(),
            language: language,
            theme: theme
        )
    }
}

extension NotificationSettings {
    func toDTO() -> NotificationSettingsDTO {
        NotificationSettingsDTO(
            email: email,
            push: push,
            leagueUpdates: leagueUpdates,
            playerNews: playerNews
        )
    }
}

extension UserStats {
    func toDTO() -> UserStatsDTO {
        UserStatsDTO(
            leaguesCreated: leaguesCreated,
            leaguesJoined: leaguesJoined,
            totalPoints: totalPoints,
            highestRank: highestRank,
            seasonsPlayed: seasonsPlayed
        )
    }
}
```

### File 10: Data/Services/Firebase/Users/FirebaseUsersDataSource.swift

```swift
import Foundation
import FirebaseFirestore

protocol FirebaseUsersDataSourceProtocol: AnyObject {
    func observeUser(_ userId: String) -> AsyncStream<UserDTO>
    func fetchUser(_ userId: String) async throws -> UserDTO
    func createUser(_ user: UserDTO) async throws
    func updateUser(_ userId: String, data: [String: Any]) async throws
    func deleteUser(_ userId: String) async throws
}

final class FirebaseUsersDataSource: FirebaseUsersDataSourceProtocol {
    private let db = Firestore.firestore()
    private let collectionPath = "users"

    func observeUser(_ userId: String) -> AsyncStream<UserDTO> {
        AsyncStream { continuation in
            let listener = db.collection(collectionPath).document(userId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error observing user: \(error)")
                        continuation.finish()
                        return
                    }

                    guard let snapshot = snapshot, snapshot.exists else {
                        continuation.finish()
                        return
                    }

                    do {
                        let user = try snapshot.data(as: UserDTO.self)
                        continuation.yield(user)
                    } catch {
                        print("Error decoding user: \(error)")
                        continuation.finish()
                    }
                }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    func fetchUser(_ userId: String) async throws -> UserDTO {
        do {
            let document = try await db.collection(collectionPath).document(userId).getDocument()
            guard document.exists else {
                throw AppError.customError(message: "Usuario no encontrado")
            }
            return try document.data(as: UserDTO.self)
        } catch {
            throw AppError.generalError(message: "Error al obtener usuario: \(error.localizedDescription)")
        }
    }

    func createUser(_ user: UserDTO) async throws {
        do {
            try db.collection(collectionPath).document(user.uid).setData(from: user)
        } catch {
            throw AppError.generalError(message: "Error al crear usuario: \(error.localizedDescription)")
        }
    }

    func updateUser(_ userId: String, data: [String: Any]) async throws {
        do {
            try await db.collection(collectionPath).document(userId).updateData(data)
        } catch {
            throw AppError.generalError(message: "Error al actualizar usuario: \(error.localizedDescription)")
        }
    }

    func deleteUser(_ userId: String) async throws {
        do {
            try await db.collection(collectionPath).document(userId).delete()
        } catch {
            throw AppError.generalError(message: "Error al eliminar usuario: \(error.localizedDescription)")
        }
    }
}
```

### File 11: Domain/Repositories/UserRepositoryProtocol.swift

```swift
import Foundation

protocol UserRepositoryProtocol: AnyObject {
    func observeUser(_ userId: String) -> AsyncStream<User>
    func fetchUser(_ userId: String) async throws -> User
    func createUser(_ user: User) async throws
    func updateUser(_ userId: String, user: User) async throws
    func deleteUser(_ userId: String) async throws
}
```

### File 12: Data/Repositories/UserRepository.swift

```swift
import Foundation

final class UserRepository: UserRepositoryProtocol {
    private let dataSource: FirebaseUsersDataSourceProtocol

    init(dataSource: FirebaseUsersDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func observeUser(_ userId: String) -> AsyncStream<User> {
        AsyncStream { continuation in
            Task {
                for await dto in dataSource.observeUser(userId) {
                    continuation.yield(dto.toDomain(documentId: userId))
                }
            }
        }
    }

    func fetchUser(_ userId: String) async throws -> User {
        let dto = try await dataSource.fetchUser(userId)
        return dto.toDomain(documentId: userId)
    }

    func createUser(_ user: User) async throws {
        let dto = user.toDTO()
        try await dataSource.createUser(dto)
    }

    func updateUser(_ userId: String, user: User) async throws {
        let dto = user.toDTO()
        let data: [String: Any] = [
            "displayName": dto.displayName,
            "profileImage": dto.profileImage ?? NSNull(),
            "bio": dto.bio ?? NSNull(),
            "updatedAt": Timestamp(date: Date()),
            "preferences": [
                "favoriteTeamId": dto.preferences.favoriteTeamId ?? NSNull(),
                "favoriteLeagues": dto.preferences.favoriteLeagues,
                "notifications": [
                    "email": dto.preferences.notifications.email,
                    "push": dto.preferences.notifications.push,
                    "leagueUpdates": dto.preferences.notifications.leagueUpdates,
                    "playerNews": dto.preferences.notifications.playerNews
                ],
                "language": dto.preferences.language,
                "theme": dto.preferences.theme
            ],
            "stats": [
                "leaguesCreated": dto.stats.leaguesCreated,
                "leaguesJoined": dto.stats.leaguesJoined,
                "totalPoints": dto.stats.totalPoints,
                "highestRank": dto.stats.highestRank,
                "seasonsPlayed": dto.stats.seasonsPlayed
            ]
        ]
        try await dataSource.updateUser(userId, data: data)
    }

    func deleteUser(_ userId: String) async throws {
        try await dataSource.deleteUser(userId)
    }
}
```

### File 13: Domain/UseCases/UserUseCase.swift

```swift
import Foundation

protocol UserUseCaseProtocol: AnyObject {
    func observeUser(_ userId: String) -> AsyncStream<User>
    func fetchUser(_ userId: String) async throws -> User
    func createUser(_ user: User) async throws
    func updateUserProfile(userId: String, displayName: String?, bio: String?, profileImage: String?) async throws
    func deleteUser(_ userId: String) async throws
}

final class UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func observeUser(_ userId: String) -> AsyncStream<User> {
        repository.observeUser(userId)
    }

    func fetchUser(_ userId: String) async throws -> User {
        try await repository.fetchUser(userId)
    }

    func createUser(_ user: User) async throws {
        try await repository.createUser(user)
    }

    func updateUserProfile(userId: String, displayName: String?, bio: String?, profileImage: String?) async throws {
        var user = try await repository.fetchUser(userId)

        if let displayName = displayName {
            user = User(
                id: user.id,
                uid: user.uid,
                email: user.email,
                displayName: displayName,
                profileImage: profileImage ?? user.profileImage,
                bio: bio ?? user.bio,
                createdAt: user.createdAt,
                updatedAt: Date(),
                preferences: user.preferences,
                stats: user.stats,
                status: user.status
            )
        }

        try await repository.updateUser(userId, user: user)
    }

    func deleteUser(_ userId: String) async throws {
        try await repository.deleteUser(userId)
    }
}
```

### File 14: DI/Containers/UserContainer.swift

```swift
import Foundation

final class UserContainer {
    static let shared = UserContainer()
    private init() {}

    func makeUseCase() -> UserUseCaseProtocol {
        let dataSource = FirebaseUsersDataSource()
        let repository = UserRepository(dataSource: dataSource)
        return UserUseCase(repository: repository)
    }
}
```

---

## Phase 2: Implementation Checklist

- [ ] Create File 8: User.swift
- [ ] Create File 9: UserDTO.swift
- [ ] Create File 10: FirebaseUsersDataSource.swift
- [ ] Create File 11: UserRepositoryProtocol.swift
- [ ] Create File 12: UserRepository.swift
- [ ] Create File 13: UserUseCase.swift
- [ ] Create File 14: UserContainer.swift
- [ ] Build project and verify no compilation errors
- [ ] Test with Firebase Emulator

---

# PHASE 3: Sports Data (Teams, Players, Matches)

> **Status:** Pending
> **Start after:** Phase 2 completes

[To be completed with detailed implementation guides for Team, Player, and Match entities]

---

# PHASE 4: Leagues & Fantasy Squads

> **Status:** Pending
> **Start after:** Phase 3 completes

[To be completed with detailed implementation guides for League, Member, and FantasySquad entities]

---

# PHASE 5: Advanced Features

> **Status:** Pending
> **Start after:** Phase 4 completes

[To be completed with Transfers, Feed, and Matchups]

---

# PHASE 6: Security Rules & Indexes

## Security Rules

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if true; // Public read (basic profile info)
      allow write: if isOwner(userId);
    }

    // Teams collection (public read, admin write)
    match /teams/{teamId} {
      allow read: if true;
      allow write: if false; // Admin only via Cloud Functions
    }

    // Players collection (public read, admin write)
    match /players/{playerId} {
      allow read: if true;
      allow write: if false; // Admin only
    }

    // Matches collection (public read, admin write)
    match /matches/{matchId} {
      allow read: if true;
      allow write: if false; // Admin only
    }

    // Leagues collection
    match /leagues/{leagueId} {
      allow read: if true; // Public leagues readable
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.createdBy);

      // League members subcollection
      match /members/{memberId} {
        allow read: if true;
        allow write: if isOwner(memberId) || isOwner(get(/databases/$(database)/documents/leagues/$(leagueId)).data.createdBy);
      }

      // League feed subcollection
      match /feed/{postId} {
        allow read: if true;
        allow create: if isAuthenticated();
        allow update, delete: if isOwner(resource.data.authorId);
      }

      // Matchups subcollection
      match /matchups/{matchupId} {
        allow read: if true;
        allow write: if false; // System only
      }
    }

    // Fantasy squads collection
    match /fantasySquads/{squadId} {
      allow read: if true;
      allow write: if isOwner(resource.data.userId);
    }

    // Transfers collection (public read, admin write)
    match /transfers/{transferId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
  }
}
```

## Firestore Indexes

Deploy indexes from `FIREBASE_SCHEMA.md` (lines 1170-1358).

---

# Testing & Firebase Emulator

### Setup Emulator

```bash
npm install -g firebase-tools
firebase login
firebase init emulators
# Select: Firestore, Authentication
firebase emulators:start
```

---

## Progress Tracking

### Phase 1: Authentication ✅ (In Progress)
- [x] Steps 0.1-0.4: Setup
- [ ] Files 1-7: Implementation
- [ ] Testing: Complete

### Phase 2: Users Collection 🔲
- [ ] Files 8-14: Implementation

### Phase 3: Sports Data 🔲
- [ ] Teams, Players, Matches

### Phase 4: Leagues 🔲
- [ ] Leagues, Members, Squads

### Phase 5: Advanced 🔲
- [ ] Transfers, Feed, Matchups

### Phase 6: Security 🔲
- [ ] Rules & Indexes

---

## Useful Commands

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize Firebase
firebase init

# Start emulators
firebase emulators:start

# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# View Firebase logs
firebase functions:log
```

---

## Next Steps

👉 **Start implementing Phase 1 files 1-7 now!**

