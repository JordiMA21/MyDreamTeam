import Foundation
import FirebaseFirestore

// MARK: - Firebase Fantasy Squad DTO

struct FirebaseFantasySquadDTO: Codable {
    @DocumentID var id: String?
    let leagueId: String
    let userId: String
    let leagueName: String
    let teamName: String
    let createdAt: Date
    let updatedAt: Date
    let formation: String // 4-3-3, 3-5-2, etc.
    let players: [FantasyPlayerDTO]
    let bench: [FantasyPlayerDTO]
    let budget: BudgetDTO
    let totalValue: Double

    enum CodingKeys: String, CodingKey {
        case id, leagueId, userId, leagueName, teamName
        case createdAt, updatedAt, formation, players, bench
        case budget, totalValue
    }
}

// MARK: - Fantasy Player DTO

struct FantasyPlayerDTO: Codable {
    let id: String // ID del jugador real
    let firstName: String
    let lastName: String
    let position: String // GK, DEF, MID, FWD
    let currentTeam: String
    let number: Int
    let marketValue: Double
    let weekPoints: Int
    let totalPoints: Int
    let isCaptain: Bool
    let isViceCaptain: Bool
    let addedAt: Date
}

// MARK: - Budget DTO

struct BudgetDTO: Codable {
    let total: Double
    let spent: Double
    let remaining: Double
    let currency: String
}

// MARK: - Transfer History DTO

struct FirebaseTransferDTO: Codable {
    @DocumentID var id: String?
    let squadId: String
    let playerOutId: String
    let playerOutName: String
    let playerInId: String
    let playerInName: String
    let transferFee: Double
    let date: Date
    let gameweek: Int
    let pointsChange: Int
}

// MARK: - Mappers to Domain

extension FirebaseFantasySquadDTO {
    func toDomain() -> FantasySquadEntity {
        FantasySquadEntity(
            id: id ?? UUID().uuidString,
            leagueId: leagueId,
            userId: userId,
            leagueName: leagueName,
            teamName: teamName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            formation: formation,
            players: players.map { $0.toDomain() },
            bench: bench.map { $0.toDomain() },
            budget: budget.toDomain(),
            totalValue: totalValue
        )
    }
}

extension FantasyPlayerDTO {
    func toDomain() -> FantasyPlayerEntity {
        FantasyPlayerEntity(
            id: id,
            firstName: firstName,
            lastName: lastName,
            position: position,
            currentTeam: currentTeam,
            number: number,
            marketValue: marketValue,
            weekPoints: weekPoints,
            totalPoints: totalPoints,
            isCaptain: isCaptain,
            isViceCaptain: isViceCaptain,
            addedAt: addedAt
        )
    }
}

extension BudgetDTO {
    func toDomain() -> BudgetEntity {
        BudgetEntity(
            total: total,
            spent: spent,
            remaining: remaining,
            currency: currency
        )
    }
}

extension FirebaseTransferDTO {
    func toDomain() -> TransferEntity {
        TransferEntity(
            id: id ?? UUID().uuidString,
            squadId: squadId,
            playerOutId: playerOutId,
            playerOutName: playerOutName,
            playerInId: playerInId,
            playerInName: playerInName,
            transferFee: transferFee,
            date: date,
            gameweek: gameweek,
            pointsChange: pointsChange
        )
    }
}

// MARK: - Reverse Mappers (Domain to DTO)

extension FantasySquadEntity {
    func toFirebaseDTO() -> FirebaseFantasySquadDTO {
        FirebaseFantasySquadDTO(
            id: id,
            leagueId: leagueId,
            userId: userId,
            leagueName: leagueName,
            teamName: teamName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            formation: formation,
            players: players.map { $0.toDTO() },
            bench: bench.map { $0.toDTO() },
            budget: budget.toDTO(),
            totalValue: totalValue
        )
    }
}

extension FantasyPlayerEntity {
    func toDTO() -> FantasyPlayerDTO {
        FantasyPlayerDTO(
            id: id,
            firstName: firstName,
            lastName: lastName,
            position: position,
            currentTeam: currentTeam,
            number: number,
            marketValue: marketValue,
            weekPoints: weekPoints,
            totalPoints: totalPoints,
            isCaptain: isCaptain,
            isViceCaptain: isViceCaptain,
            addedAt: addedAt
        )
    }
}

extension BudgetEntity {
    func toDTO() -> BudgetDTO {
        BudgetDTO(
            total: total,
            spent: spent,
            remaining: remaining,
            currency: currency
        )
    }
}

extension TransferEntity {
    func toFirebaseDTO() -> FirebaseTransferDTO {
        FirebaseTransferDTO(
            id: id,
            squadId: squadId,
            playerOutId: playerOutId,
            playerOutName: playerOutName,
            playerInId: playerInId,
            playerInName: playerInName,
            transferFee: transferFee,
            date: date,
            gameweek: gameweek,
            pointsChange: pointsChange
        )
    }
}
