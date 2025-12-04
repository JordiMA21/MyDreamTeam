import Foundation

// MARK: - League Entity

struct LeagueEntity: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String?
    let createdBy: String
    let createdAt: Date
    let season: Int
    let status: String // active, ended, draft
    let maxPlayers: Int
    let scoringFormat: String // ppr, standard, custom
    let scoringRules: ScoringRulesEntity?
    let settings: LeagueSettingsEntity?
    let totalPlayers: Int
    let image: URL?
    let rules: String?
}

// MARK: - Scoring Rules Entity

struct ScoringRulesEntity: Equatable {
    let goalScore: Int
    let assistScore: Int
    let cleanSheetScore: Int
    let yellowCardScore: Int
    let redCardScore: Int
}

// MARK: - League Settings Entity

struct LeagueSettingsEntity: Equatable {
    let startDate: Date
    let endDate: Date
    let isPublic: Bool
    let allowTransfers: Bool
    let transferDeadline: Date?
}

// MARK: - League Member Entity

struct LeagueMemberEntity: Identifiable, Equatable {
    let id: String // Combinación de leagueId + userId
    let leagueId: String
    let userId: String
    let joinedAt: Date
    let teamName: String
    let totalPoints: Int
    let rank: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let matchesPlayed: Int
    let transfersRemaining: Int
    let status: String // active, inactive, removed
    let squad: [String] // playerIds
}

// MARK: - League Info (para mostrar en listas)

struct LeagueInfoEntity: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String?
    let season: Int
    let status: String
    let totalPlayers: Int
    let image: URL?
    let createdBy: String
    let isUserMember: Bool
}
