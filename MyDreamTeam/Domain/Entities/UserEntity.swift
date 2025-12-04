import Foundation

// MARK: - User Entity

struct UserEntity: Identifiable, Equatable {
    let id: String
    let uid: String
    let email: String
    let displayName: String
    let profileImage: URL?
    let bio: String?
    let createdAt: Date
    let updatedAt: Date
    let preferences: UserPreferences?
    let stats: UserStats?
    let status: String // active, inactive, suspended
}

// MARK: - User Preferences

struct UserPreferences: Equatable {
    let favoriteTeam: String?
    let favoriteLeagues: [String]
    let notifications: Bool
    let language: String
}

// MARK: - User Stats

struct UserStats: Equatable {
    let leaguesCreated: Int
    let leaguesJoined: Int
    let totalPoints: Int
    let rank: Int
}
