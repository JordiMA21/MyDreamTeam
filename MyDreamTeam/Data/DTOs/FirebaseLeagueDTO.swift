import Foundation
import FirebaseFirestore

// MARK: - Firebase League DTO

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

// MARK: - Scoring Rules DTO

struct ScoringRulesDTO: Codable {
    let goalScore: Int
    let assistScore: Int
    let cleanSheetScore: Int
    let yellowCardScore: Int
    let redCardScore: Int
}

// MARK: - League Settings DTO

struct LeagueSettingsDTO: Codable {
    let startDate: Date
    let endDate: Date
    let isPublic: Bool
    let allowTransfers: Bool
    let transferDeadline: Date?
}

// MARK: - Mappers to Domain

extension FirebaseLeagueDTO {
    func toDomain() -> LeagueEntity {
        LeagueEntity(
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

extension ScoringRulesDTO {
    func toDomain() -> ScoringRulesEntity {
        ScoringRulesEntity(
            goalScore: goalScore,
            assistScore: assistScore,
            cleanSheetScore: cleanSheetScore,
            yellowCardScore: yellowCardScore,
            redCardScore: redCardScore
        )
    }
}

extension LeagueSettingsDTO {
    func toDomain() -> LeagueSettingsEntity {
        LeagueSettingsEntity(
            startDate: startDate,
            endDate: endDate,
            isPublic: isPublic,
            allowTransfers: allowTransfers,
            transferDeadline: transferDeadline
        )
    }
}

// MARK: - Reverse Mappers (Domain to DTO)

extension LeagueEntity {
    func toFirebaseDTO() -> FirebaseLeagueDTO {
        FirebaseLeagueDTO(
            id: id,
            name: name,
            description: description,
            createdBy: createdBy,
            createdAt: createdAt,
            season: season,
            status: status,
            maxPlayers: maxPlayers,
            scoringFormat: scoringFormat,
            scoringRules: scoringRules?.toDTO(),
            settings: settings?.toDTO(),
            totalPlayers: totalPlayers,
            image: image?.absoluteString,
            rules: rules
        )
    }
}

extension ScoringRulesEntity {
    func toDTO() -> ScoringRulesDTO {
        ScoringRulesDTO(
            goalScore: goalScore,
            assistScore: assistScore,
            cleanSheetScore: cleanSheetScore,
            yellowCardScore: yellowCardScore,
            redCardScore: redCardScore
        )
    }
}

extension LeagueSettingsEntity {
    func toDTO() -> LeagueSettingsDTO {
        LeagueSettingsDTO(
            startDate: startDate,
            endDate: endDate,
            isPublic: isPublic,
            allowTransfers: allowTransfers,
            transferDeadline: transferDeadline
        )
    }
}
