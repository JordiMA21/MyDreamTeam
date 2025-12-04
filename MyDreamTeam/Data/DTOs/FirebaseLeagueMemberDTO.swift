import Foundation
import FirebaseFirestore

// MARK: - Firebase League Member DTO

struct FirebaseLeagueMemberDTO: Codable {
    @DocumentID var id: String?
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

    enum CodingKeys: String, CodingKey {
        case id, leagueId, userId, joinedAt, teamName
        case totalPoints, rank, wins, draws, losses, matchesPlayed
        case transfersRemaining, status, squad
    }
}

// MARK: - Mapper to Domain

extension FirebaseLeagueMemberDTO {
    func toDomain() -> LeagueMemberEntity {
        LeagueMemberEntity(
            id: id ?? "\(leagueId)_\(userId)",
            leagueId: leagueId,
            userId: userId,
            joinedAt: joinedAt,
            teamName: teamName,
            totalPoints: totalPoints,
            rank: rank,
            wins: wins,
            draws: draws,
            losses: losses,
            matchesPlayed: matchesPlayed,
            transfersRemaining: transfersRemaining,
            status: status,
            squad: squad
        )
    }
}

// MARK: - Reverse Mapper (Domain to DTO)

extension LeagueMemberEntity {
    func toFirebaseDTO() -> FirebaseLeagueMemberDTO {
        FirebaseLeagueMemberDTO(
            id: id,
            leagueId: leagueId,
            userId: userId,
            joinedAt: joinedAt,
            teamName: teamName,
            totalPoints: totalPoints,
            rank: rank,
            wins: wins,
            draws: draws,
            losses: losses,
            matchesPlayed: matchesPlayed,
            transfersRemaining: transfersRemaining,
            status: status,
            squad: squad
        )
    }
}
