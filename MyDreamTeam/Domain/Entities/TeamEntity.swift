import Foundation

// MARK: - Team Entity

struct TeamEntity: Identifiable, Equatable {
    let id: String
    let name: String
    let country: String
    let city: String
    let founded: Int
    let league: String
    let coach: String?
    let stadium: String?
    let logo: URL?
    let colors: TeamColorsEntity?
    let season: Int
    let stats: TeamStatsEntity?
}

// MARK: - Team Colors Entity

struct TeamColorsEntity: Equatable {
    let primary: String // hex color
    let secondary: String? // hex color
}

// MARK: - Team Stats Entity

struct TeamStatsEntity: Equatable {
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let points: Int
    let position: Int

    var goalDifference: Int {
        goalsFor - goalsAgainst
    }

    var winPercentage: Double {
        guard played > 0 else { return 0 }
        return (Double(won) / Double(played)) * 100
    }
}

// MARK: - Player Entity

struct PlayerEntity: Identifiable, Equatable {
    let id: String
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
    let stats: PlayerStatsEntity?
    let photo: URL?
    let marketValue: Double
}

// MARK: - Player Stats Entity

struct PlayerStatsEntity: Equatable {
    let played: Int
    let goals: Int
    let assists: Int
    let yellowCards: Int
    let redCards: Int
    let cleanSheets: Int
    let minutes: Int
    let averageRating: Double

    var goalsPerGame: Double {
        guard played > 0 else { return 0 }
        return Double(goals) / Double(played)
    }

    var assistsPerGame: Double {
        guard played > 0 else { return 0 }
        return Double(assists) / Double(played)
    }
}

// MARK: - Computed Properties

extension PlayerEntity {
    var displayName: String {
        "\(firstName) \(lastName)"
    }

    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }

    var isActive: Bool {
        status == "active"
    }
}

extension TeamEntity {
    var displayName: String {
        "\(name) (\(country))"
    }

    var isLeading: Bool {
        stats?.position == 1
    }
}
