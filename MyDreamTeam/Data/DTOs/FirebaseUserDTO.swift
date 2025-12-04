import Foundation
import FirebaseFirestore

// MARK: - Firebase User DTO

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
        case id, uid, email, displayName, profileImage, bio
        case createdAt, updatedAt, preferences, stats, status
    }
}

// MARK: - User Preferences DTO

struct UserPreferencesDTO: Codable {
    let favoriteTeam: String?
    let favoriteLeagues: [String]?
    let notifications: Bool
    let language: String
}

// MARK: - User Stats DTO

struct UserStatsDTO: Codable {
    let leaguesCreated: Int
    let leaguesJoined: Int
    let totalPoints: Int
    let rank: Int
}

// MARK: - Mapper to Domain

extension FirebaseUserDTO {
    func toDomain() -> UserEntity {
        UserEntity(
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

// MARK: - Reverse Mapper (Domain to DTO)

extension UserEntity {
    func toFirebaseDTO() -> FirebaseUserDTO {
        FirebaseUserDTO(
            id: id,
            uid: uid,
            email: email,
            displayName: displayName,
            profileImage: profileImage?.absoluteString,
            bio: bio,
            createdAt: createdAt,
            updatedAt: updatedAt,
            preferences: preferences?.toDTO(),
            stats: stats?.toDTO(),
            status: status
        )
    }
}

extension UserPreferences {
    func toDTO() -> UserPreferencesDTO {
        UserPreferencesDTO(
            favoriteTeam: favoriteTeam,
            favoriteLeagues: favoriteLeagues,
            notifications: notifications,
            language: language
        )
    }
}

extension UserStats {
    func toDTO() -> UserStatsDTO {
        UserStatsDTO(
            leaguesCreated: leaguesCreated,
            leaguesJoined: leaguesJoined,
            totalPoints: totalPoints,
            rank: rank
        )
    }
}
