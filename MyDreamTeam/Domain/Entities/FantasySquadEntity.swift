import Foundation

// MARK: - Fantasy Squad Entity

struct FantasySquadEntity: Identifiable, Equatable {
    let id: String
    let leagueId: String
    let userId: String
    let leagueName: String
    let teamName: String
    let createdAt: Date
    let updatedAt: Date
    let formation: String // 4-3-3, 3-5-2, etc.
    let players: [FantasyPlayerEntity]
    let bench: [FantasyPlayerEntity]
    let budget: BudgetEntity
    let totalValue: Double
}

// MARK: - Fantasy Player Entity (Player en el equipo fantasy)

struct FantasyPlayerEntity: Identifiable, Equatable {
    let id: String // ID del jugador real
    let firstName: String
    let lastName: String
    let position: String // GK, DEF, MID, FWD
    let currentTeam: String
    let number: Int
    let marketValue: Double
    let weekPoints: Int
    let totalPoints: Int
    var isCaptain: Bool
    var isViceCaptain: Bool
    let addedAt: Date
}

// MARK: - Budget Entity

struct BudgetEntity: Equatable {
    let total: Double
    let spent: Double
    let remaining: Double
    let currency: String // EUR, USD, etc.

    var percentageUsed: Double {
        guard total > 0 else { return 0 }
        return (spent / total) * 100
    }
}

// MARK: - Transfer History Entity

struct TransferEntity: Identifiable, Equatable {
    let id: String
    let squadId: String
    let playerOutId: String
    let playerOutName: String
    let playerInId: String
    let playerInName: String
    let transferFee: Double
    let date: Date
    let gameweek: Int
    let pointsChange: Int // Puede ser positivo o negativo
}

// MARK: - Squad Statistics Entity

struct SquadStatsEntity: Equatable {
    let totalSquadValue: Double
    let averagePlayerValue: Double
    let totalTransfers: Int
    let transfersRemaining: Int
    let weekPoints: Int
    let totalPoints: Int
    let captainChoice: String?
    let benchStrength: Double // 0-100
    let formationCompliance: Bool // Si respeta la formación
}
