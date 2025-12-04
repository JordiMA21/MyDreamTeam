import Foundation
import FirebaseFirestore

// MARK: - Firebase Player DTO

struct FirebasePlayerDTO: Codable {
    @DocumentID var id: String?
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
    let currentTeamName: String?
    let status: String // active, injured, suspended, loaned
    let season: Int
    let stats: PlayerStatsDTO?
    let photo: String?
    let marketValue: Double

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, nationality, dateOfBirth
        case position, number, height, weight, foot
        case currentTeamId, currentTeamName, status, season, stats, photo, marketValue
    }
}

// MARK: - Player Stats DTO

struct PlayerStatsDTO: Codable {
    let played: Int
    let goals: Int
    let assists: Int
    let yellowCards: Int
    let redCards: Int
    let cleanSheets: Int
    let minutes: Int
    let averageRating: Double
}

// MARK: - Mappers to Domain

extension FirebasePlayerDTO {
    func toDomain() -> PlayerEntity {
        PlayerEntity(
            id: id ?? UUID().uuidString,
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
            currentTeamName: currentTeamName,
            status: status,
            season: season,
            stats: stats?.toDomain(),
            photo: photo.flatMap(URL.init),
            marketValue: marketValue
        )
    }
}

extension PlayerStatsDTO {
    func toDomain() -> PlayerStatsEntity {
        PlayerStatsEntity(
            played: played,
            goals: goals,
            assists: assists,
            yellowCards: yellowCards,
            redCards: redCards,
            cleanSheets: cleanSheets,
            minutes: minutes,
            averageRating: averageRating
        )
    }
}

// MARK: - Reverse Mappers (Domain to DTO)

extension PlayerEntity {
    func toFirebaseDTO() -> FirebasePlayerDTO {
        FirebasePlayerDTO(
            id: id,
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
            currentTeamName: currentTeamName,
            status: status,
            season: season,
            stats: stats?.toDTO(),
            photo: photo?.absoluteString,
            marketValue: marketValue
        )
    }
}

extension PlayerStatsEntity {
    func toDTO() -> PlayerStatsDTO {
        PlayerStatsDTO(
            played: played,
            goals: goals,
            assists: assists,
            yellowCards: yellowCards,
            redCards: redCards,
            cleanSheets: cleanSheets,
            minutes: minutes,
            averageRating: averageRating
        )
    }
}
