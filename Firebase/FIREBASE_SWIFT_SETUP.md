# Firebase Swift Implementation - MyDreamTeam

Complete guide to implement Firebase in your MyDreamTeam app with proper architecture.

---

## 1. FIREBASE CONFIGURATION

### Step 1: Install Dependencies

Add to your `Podfile`:

```ruby
platform :ios, '14.0'

target 'MyDreamTeam' do
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Storage'
end
```

Or use Swift Package Manager:
1. Xcode → File → Add Packages
2. Enter: `https://github.com/firebase/firebase-ios-sdk.git`
3. Select version (13.0.0 or later)
4. Add to MyDreamTeam target

### Step 2: Configure Firebase

Create `MyDreamTeam/Shared/Configuration/ConfigFirebase.swift`:

```swift
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAnalytics

class FirebaseConfig {
    static let shared = FirebaseConfig()

    private init() {}

    func configure() {
        FirebaseApp.configure()

        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings

        // Enable crash reporting
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

        // Enable analytics
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    func getFirestore() -> Firestore {
        return Firestore.firestore()
    }

    func getDatabase() -> Database {
        return Database.database()
    }

    func getAuth() -> Auth {
        return Auth.auth()
    }
}
```

### Step 3: Initialize in App

Update `MyDreamTeamApp.swift`:

```swift
import SwiftUI
import FirebaseCore

@main
struct MyDreamTeamApp: App {

    init() {
        FirebaseConfig.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigatorRootView(root: HomeBuilder.build())
        }
    }
}
```

---

## 2. DTOs (Data Transfer Objects)

Create data models matching Firestore structure.

### User DTO

`MyDreamTeam/Data/DTOs/FirebaseUserDTO.swift`:

```swift
import Foundation
import FirebaseFirestoreSwift

struct FirebaseUserDTO: Codable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    let displayName: String
    let profileImage: String?
    let bio: String?
    let createdAt: Date
    let updatedAt: Date
    let preferences: UserPreferencesDTO?
    let stats: UserStatsDTO?
    let status: String // active, inactive, suspended

    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case email
        case displayName
        case profileImage
        case bio
        case createdAt
        case updatedAt
        case preferences
        case stats
        case status
    }
}

struct UserPreferencesDTO: Codable {
    let favoriteTeam: String?
    let favoriteLeagues: [String]?
    let notifications: Bool
    let language: String
}

struct UserStatsDTO: Codable {
    let leaguesCreated: Int
    let leaguesJoined: Int
    let totalPoints: Int
    let rank: Int
}

// MARK: - Mapper to Domain

extension FirebaseUserDTO {
    func toDomain() -> User {
        User(
            id: id ?? uid,
            uid: uid,
            email: email,
            displayName: displayName,
            profileImage: profileImage.flatMap(URL.init),
            bio: bio,
            createdAt: createdAt,
            updatedAt: updatedAt,
            preferences: preferences?.toDomain(),
            stats: stats?.toDomain(),
            status: status
        )
    }
}

extension UserPreferencesDTO {
    func toDomain() -> UserPreferences {
        UserPreferences(
            favoriteTeam: favoriteTeam,
            favoriteLeagues: favoriteLeagues ?? [],
            notifications: notifications,
            language: language
        )
    }
}

extension UserStatsDTO {
    func toDomain() -> UserStats {
        UserStats(
            leaguesCreated: leaguesCreated,
            leaguesJoined: leaguesJoined,
            totalPoints: totalPoints,
            rank: rank
        )
    }
}
```

### League DTO

`MyDreamTeam/Data/DTOs/FirebaseLeagueDTO.swift`:

```swift
import Foundation
import FirebaseFirestoreSwift

struct FirebaseLeagueDTO: Codable {
    @DocumentID var id: String?
    let name: String
    let description: String?
    let createdBy: String
    let createdAt: Date
    let season: Int
    let status: String // active, ended, draft
    let maxPlayers: Int
    let scoringFormat: String // ppr, standard, custom
    let scoringRules: ScoringRulesDTO?
    let settings: LeagueSettingsDTO?
    let totalPlayers: Int
    let image: String?
    let rules: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, createdBy, createdAt, season
        case status, maxPlayers, scoringFormat, scoringRules, settings
        case totalPlayers, image, rules
    }
}

struct ScoringRulesDTO: Codable {
    let goalScore: Int
    let assistScore: Int
    let cleanSheetScore: Int
    let yellowCardScore: Int
    let redCardScore: Int
}

struct LeagueSettingsDTO: Codable {
    let startDate: Date
    let endDate: Date
    let isPublic: Bool
    let allowTransfers: Bool
    let transferDeadline: Date?
}

extension FirebaseLeagueDTO {
    func toDomain() -> League {
        League(
            id: id ?? UUID().uuidString,
            name: name,
            description: description,
            createdBy: createdBy,
            createdAt: createdAt,
            season: season,
            status: status,
            maxPlayers: maxPlayers,
            scoringFormat: scoringFormat,
            scoringRules: scoringRules?.toDomain(),
            settings: settings?.toDomain(),
            totalPlayers: totalPlayers,
            image: image.flatMap(URL.init),
            rules: rules
        )
    }
}
```

### Player DTO

`MyDreamTeam/Data/DTOs/FirebasePlayerDTO.swift`:

```swift
import Foundation
import FirebaseFirestoreSwift

struct FirebasePlayerDTO: Codable {
    @DocumentID var id: String?
    let playerId: String
    let firstName: String
    let lastName: String
    let nationality: String
    let dateOfBirth: Date
    let position: String // GK, DEF, MID, FWD
    let number: Int
    let height: Double?
    let weight: Double?
    let foot: String? // left, right, both
    let currentTeamId: String
    let status: String // active, injured, suspended, loaned
    let season: Int
    let stats: PlayerStatsDTO?
    let photo: String?
    let marketValue: MarketValueDTO?

    enum CodingKeys: String, CodingKey {
        case id, playerId, firstName, lastName, nationality, dateOfBirth
        case position, number, height, weight, foot, currentTeamId
        case status, season, stats, photo, marketValue
    }
}

struct PlayerStatsDTO: Codable {
    let played: Int
    let goals: Int
    let assists: Int
    let yellowCards: Int
    let redCards: Int
    let cleanSheets: Int
    let minutes: Int
    let averageRating: Double?
}

struct MarketValueDTO: Codable {
    let amount: Double
    let currency: String
    let lastUpdated: Date
}

extension FirebasePlayerDTO {
    func toDomain() -> Player {
        Player(
            id: id ?? playerId,
            firstName: firstName,
            lastName: lastName,
            nationality: nationality,
            dateOfBirth: dateOfBirth,
            position: position,
            number: number,
            height: height,
            weight: weight,
            foot: foot,
            currentTeamId: currentTeamId,
            status: status,
            season: season,
            stats: stats?.toDomain(),
            photo: photo.flatMap(URL.init),
            marketValue: marketValue?.toDomain()
        )
    }
}

extension PlayerStatsDTO {
    func toDomain() -> PlayerStats {
        PlayerStats(
            played: played,
            goals: goals,
            assists: assists,
            yellowCards: yellowCards,
            redCards: redCards,
            cleanSheets: cleanSheets,
            minutes: minutes,
            averageRating: averageRating ?? 0
        )
    }
}

extension MarketValueDTO {
    func toDomain() -> MarketValue {
        MarketValue(
            amount: amount,
            currency: currency,
            lastUpdated: lastUpdated
        )
    }
}
```

---

## 3. FIRESTORE DATA SOURCES

### User DataSource

`MyDreamTeam/Data/DataSources/Firestore/UserFirestoreDataSource.swift`:

```swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol UserFirestoreDataSourceProtocol: AnyObject {
    func createUser(user: FirebaseUserDTO) async throws
    func getUser(uid: String) async throws -> FirebaseUserDTO
    func updateUser(uid: String, data: [String: Any]) async throws
    func deleteUser(uid: String) async throws
    func observeUser(uid: String) -> AsyncStream<FirebaseUserDTO>
}

final class UserFirestoreDataSource: UserFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let collectionPath = "users"

    func createUser(user: FirebaseUserDTO) async throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(user)
        try await db.collection(collectionPath).document(user.uid).setData(data)
    }

    func getUser(uid: String) async throws -> FirebaseUserDTO {
        let snapshot = try await db.collection(collectionPath).document(uid).getDocument()
        return try snapshot.data(as: FirebaseUserDTO.self)
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        try await db.collection(collectionPath).document(uid).updateData(data)
    }

    func deleteUser(uid: String) async throws {
        try await db.collection(collectionPath).document(uid).delete()
    }

    func observeUser(uid: String) -> AsyncStream<FirebaseUserDTO> {
        AsyncStream { continuation in
            let listener = db.collection(collectionPath).document(uid)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }

                    if let snapshot = snapshot, let user = try? snapshot.data(as: FirebaseUserDTO.self) {
                        continuation.yield(user)
                    }
                }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}
```

### League DataSource

`MyDreamTeam/Data/DataSources/Firestore/LeagueFirestoreDataSource.swift`:

```swift
import Foundation
import FirebaseFirestore

protocol LeagueFirestoreDataSourceProtocol: AnyObject {
    func createLeague(league: FirebaseLeagueDTO) async throws -> String
    func getLeague(leagueId: String) async throws -> FirebaseLeagueDTO
    func updateLeague(leagueId: String, data: [String: Any]) async throws
    func deleteLeague(leagueId: String) async throws
    func getUserLeagues(userId: String) async throws -> [FirebaseLeagueDTO]
    func getActiveLeagues() async throws -> [FirebaseLeagueDTO]
    func addMember(leagueId: String, userId: String, memberData: [String: Any]) async throws
    func removeMember(leagueId: String, userId: String) async throws
    func getLeagueMembers(leagueId: String) async throws -> [[String: Any]]
}

final class LeagueFirestoreDataSource: LeagueFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let leaguesPath = "leagues"
    private let membersPath = "members"

    func createLeague(league: FirebaseLeagueDTO) async throws -> String {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(league)
        let docRef = try await db.collection(leaguesPath).addDocument(data: data)
        return docRef.documentID
    }

    func getLeague(leagueId: String) async throws -> FirebaseLeagueDTO {
        let snapshot = try await db.collection(leaguesPath).document(leagueId).getDocument()
        return try snapshot.data(as: FirebaseLeagueDTO.self)
    }

    func updateLeague(leagueId: String, data: [String: Any]) async throws {
        try await db.collection(leaguesPath).document(leagueId).updateData(data)
    }

    func deleteLeague(leagueId: String) async throws {
        try await db.collection(leaguesPath).document(leagueId).delete()
    }

    func getUserLeagues(userId: String) async throws -> [FirebaseLeagueDTO] {
        let snapshot = try await db.collection(leaguesPath)
            .whereField("createdBy", isEqualTo: userId)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: FirebaseLeagueDTO.self)
        }
    }

    func getActiveLeagues() async throws -> [FirebaseLeagueDTO] {
        let snapshot = try await db.collection(leaguesPath)
            .whereField("status", isEqualTo: "active")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: FirebaseLeagueDTO.self)
        }
    }

    func addMember(leagueId: String, userId: String, memberData: [String: Any]) async throws {
        try await db.collection(leaguesPath)
            .document(leagueId)
            .collection(membersPath)
            .document(userId)
            .setData(memberData)
    }

    func removeMember(leagueId: String, userId: String) async throws {
        try await db.collection(leaguesPath)
            .document(leagueId)
            .collection(membersPath)
            .document(userId)
            .delete()
    }

    func getLeagueMembers(leagueId: String) async throws -> [[String: Any]] {
        let snapshot = try await db.collection(leaguesPath)
            .document(leagueId)
            .collection(membersPath)
            .getDocuments()

        return snapshot.documents.map { $0.data() }
    }
}
```

### Player DataSource

`MyDreamTeam/Data/DataSources/Firestore/PlayerFirestoreDataSource.swift`:

```swift
import Foundation
import FirebaseFirestore

protocol PlayerFirestoreDataSourceProtocol: AnyObject {
    func getPlayer(playerId: String) async throws -> FirebasePlayerDTO
    func getTeamPlayers(teamId: String, season: Int) async throws -> [FirebasePlayerDTO]
    func searchPlayers(query: String, position: String?) async throws -> [FirebasePlayerDTO]
    func getPlayersByPosition(position: String, season: Int) async throws -> [FirebasePlayerDTO]
}

final class PlayerFirestoreDataSource: PlayerFirestoreDataSourceProtocol {
    private let db = FirebaseConfig.shared.getFirestore()
    private let playersPath = "players"

    func getPlayer(playerId: String) async throws -> FirebasePlayerDTO {
        let snapshot = try await db.collection(playersPath).document(playerId).getDocument()
        return try snapshot.data(as: FirebasePlayerDTO.self)
    }

    func getTeamPlayers(teamId: String, season: Int) async throws -> [FirebasePlayerDTO] {
        let snapshot = try await db.collection(playersPath)
            .whereField("currentTeamId", isEqualTo: teamId)
            .whereField("season", isEqualTo: season)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: FirebasePlayerDTO.self)
        }
    }

    func searchPlayers(query: String, position: String? = nil) async throws -> [FirebasePlayerDTO] {
        var q = db.collection(playersPath)
            .whereField("firstName", isGreaterThanOrEqualTo: query)
            .whereField("firstName", isLessThan: query + "z")

        if let position = position {
            q = q.whereField("position", isEqualTo: position)
        }

        let snapshot = try await q.getDocuments()
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: FirebasePlayerDTO.self)
        }
    }

    func getPlayersByPosition(position: String, season: Int) async throws -> [FirebasePlayerDTO] {
        let snapshot = try await db.collection(playersPath)
            .whereField("position", isEqualTo: position)
            .whereField("season", isEqualTo: season)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: FirebasePlayerDTO.self)
        }
    }
}
```

---

## 4. FIRESTORE REPOSITORIES

### User Repository

`MyDreamTeam/Data/Repositories/UserRepository.swift`:

```swift
import Foundation

protocol UserRepositoryProtocol: AnyObject {
    func createUser(user: User) async throws
    func getUser(uid: String) async throws -> User
    func updateUser(uid: String, data: [String: Any]) async throws
    func deleteUser(uid: String) async throws
    func observeUser(uid: String) -> AsyncStream<User>
}

final class UserRepository: UserRepositoryProtocol {
    private let dataSource: UserFirestoreDataSourceProtocol
    private let errorHandler: ErrorHandlerManagerProtocol

    init(
        dataSource: UserFirestoreDataSourceProtocol,
        errorHandler: ErrorHandlerManagerProtocol = ErrorHandlerManager.shared
    ) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    func createUser(user: User) async throws {
        do {
            let dto = FirebaseUserDTO(
                id: user.id,
                uid: user.uid,
                email: user.email,
                displayName: user.displayName,
                profileImage: user.profileImage?.absoluteString,
                bio: user.bio,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt,
                preferences: user.preferences.flatMap { UserPreferencesDTO(
                    favoriteTeam: $0.favoriteTeam,
                    favoriteLeagues: $0.favoriteLeagues,
                    notifications: $0.notifications,
                    language: $0.language
                )},
                stats: user.stats.flatMap { UserStatsDTO(
                    leaguesCreated: $0.leaguesCreated,
                    leaguesJoined: $0.leaguesJoined,
                    totalPoints: $0.totalPoints,
                    rank: $0.rank
                )},
                status: user.status
            )
            try await dataSource.createUser(user: dto)
        } catch {
            throw AppError.generalError(message: "Failed to create user")
        }
    }

    func getUser(uid: String) async throws -> User {
        do {
            let dto = try await dataSource.getUser(uid: uid)
            return dto.toDomain()
        } catch {
            throw AppError.generalError(message: "Failed to fetch user")
        }
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        do {
            try await dataSource.updateUser(uid: uid, data: data)
        } catch {
            throw AppError.generalError(message: "Failed to update user")
        }
    }

    func deleteUser(uid: String) async throws {
        do {
            try await dataSource.deleteUser(uid: uid)
        } catch {
            throw AppError.generalError(message: "Failed to delete user")
        }
    }

    func observeUser(uid: String) -> AsyncStream<User> {
        AsyncStream { continuation in
            Task {
                for await dto in dataSource.observeUser(uid: uid) {
                    continuation.yield(dto.toDomain())
                }
            }
        }
    }
}
```

---

## 5. USE CASES

### User UseCase

`MyDreamTeam/Domain/UseCases/UserUseCase.swift`:

```swift
import Foundation

protocol UserUseCaseProtocol: AnyObject {
    func getCurrentUser() async throws -> User
    func updateUserProfile(displayName: String, bio: String) async throws
    func setFavoriteTeam(teamId: String) async throws
    func observeUserProfile() -> AsyncStream<User>
}

final class UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func getCurrentUser() async throws -> User {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials
        }
        return try await repository.getUser(uid: uid)
    }

    func updateUserProfile(displayName: String, bio: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials
        }

        let data: [String: Any] = [
            "displayName": displayName,
            "bio": bio,
            "updatedAt": Date()
        ]

        try await repository.updateUser(uid: uid, data: data)
    }

    func setFavoriteTeam(teamId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.badCredentials
        }

        let data: [String: Any] = [
            "preferences.favoriteTeam": teamId,
            "updatedAt": Date()
        ]

        try await repository.updateUser(uid: uid, data: data)
    }

    func observeUserProfile() -> AsyncStream<User> {
        guard let uid = Auth.auth().currentUser?.uid else {
            return AsyncStream { continuation in
                continuation.finish(throwing: AppError.badCredentials)
            }
        }

        return repository.observeUser(uid: uid)
    }
}
```

---

## 6. CONFIGURATION (NEXT STEP)

1. Add GoogleService-Info.plist to Xcode project
2. Create Security Rules in Firebase Console
3. Create Firestore indexes (Firebase will prompt)
4. Test with sample data

---

## 7. ERROR MAPPING

Map Firestore errors to AppError in Repository layer:

```swift
private func mapFirestoreError(_ error: Error) -> AppError {
    let nsError = error as NSError

    if nsError.domain == FIRFirestoreErrorDomain {
        switch nsError.code {
        case FirestoreErrorCode.permissionDenied.rawValue:
            return .customError(message: "No tienes permisos para acceder")
        case FirestoreErrorCode.notFound.rawValue:
            return .customError(message: "No encontrado")
        case FirestoreErrorCode.unavailable.rawValue:
            return .noInternet
        case FirestoreErrorCode.unauthenticated.rawValue:
            return .badCredentials
        default:
            return .generalError(message: "Error de Firestore: \(nsError.localizedDescription)")
        }
    }

    return .generalError(message: error.localizedDescription)
}
```

---

Continúa en el siguiente documento con:
- Realtime Database implementation
- League management
- League feed/comments
- Authentication integration

