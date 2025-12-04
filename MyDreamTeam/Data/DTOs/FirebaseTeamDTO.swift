import Foundation
import FirebaseFirestore

// MARK: - Firebase Team DTO

struct FirebaseTeamDTO: Codable {
    @DocumentID var id: String?
    let name: String
    let country: String
    let city: String
    let founded: Int
    let league: String
    let coach: String?
    let stadium: String?
    let logo: String?
    let colors: TeamColorsDTO?
    let season: Int
    let stats: TeamStatsDTO?

    enum CodingKeys: String, CodingKey {
        case id, name, country, city, founded
        case league, coach, stadium, logo, colors, season, stats
    }
}

// MARK: - Team Colors DTO

struct TeamColorsDTO: Codable {
    let primary: String
    let secondary: String?
}

// MARK: - Team Stats DTO

struct TeamStatsDTO: Codable {
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let points: Int
    let position: Int
}

// MARK: - Mappers to Domain

extension FirebaseTeamDTO {
    func toDomain() -> TeamEntity {
        TeamEntity(
            id: id ?? UUID().uuidString,
            name: name,
            country: country,
            city: city,
            founded: founded,
            league: league,
            coach: coach,
            stadium: stadium,
            logo: logo.flatMap(URL.init),
            colors: colors?.toDomain(),
            season: season,
            stats: stats?.toDomain()
        )
    }
}

extension TeamColorsDTO {
    func toDomain() -> TeamColorsEntity {
        TeamColorsEntity(
            primary: primary,
            secondary: secondary
        )
    }
}

extension TeamStatsDTO {
    func toDomain() -> TeamStatsEntity {
        TeamStatsEntity(
            played: played,
            won: won,
            drawn: drawn,
            lost: lost,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
            points: points,
            position: position
        )
    }
}

// MARK: - Reverse Mappers (Domain to DTO)

extension TeamEntity {
    func toFirebaseDTO() -> FirebaseTeamDTO {
        FirebaseTeamDTO(
            id: id,
            name: name,
            country: country,
            city: city,
            founded: founded,
            league: league,
            coach: coach,
            stadium: stadium,
            logo: logo?.absoluteString,
            colors: colors?.toDTO(),
            season: season,
            stats: stats?.toDTO()
        )
    }
}

extension TeamColorsEntity {
    func toDTO() -> TeamColorsDTO {
        TeamColorsDTO(
            primary: primary,
            secondary: secondary
        )
    }
}

extension TeamStatsEntity {
    func toDTO() -> TeamStatsDTO {
        TeamStatsDTO(
            played: played,
            won: won,
            drawn: drawn,
            lost: lost,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
            points: points,
            position: position
        )
    }
}
