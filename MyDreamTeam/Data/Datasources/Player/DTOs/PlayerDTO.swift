import Foundation

struct PlayerDTO: Codable {
    let id: Int
    let name: String
    let position: String
    let team: String
    let number: Int
    let image: String?
    let nationality: String
    let age: Int

    // Statistics
    let goals: Int
    let assists: Int
    let marketValue: Double
    let yellowCards: Int
    let redCards: Int
    let minutesPlayed: Int
    let matchesPlayed: Int

    // Additional info
    let height: String
    let weight: String
    let foot: String

    // Fantasy stats
    let fantasyPoints: Double
    let averageRating: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case position
        case team
        case number
        case image
        case nationality
        case age
        case goals
        case assists
        case marketValue = "market_value"
        case yellowCards = "yellow_cards"
        case redCards = "red_cards"
        case minutesPlayed = "minutes_played"
        case matchesPlayed = "matches_played"
        case height
        case weight
        case foot
        case fantasyPoints = "fantasy_points"
        case averageRating = "average_rating"
    }
}

// MARK: - Mapper to Domain
extension PlayerDTO {
    func toDomain() -> Player {
        Player(
            id: self.id,
            name: self.name,
            position: self.position,
            team: self.team,
            number: self.number,
            image: self.image ?? "",
            nationality: self.nationality,
            age: self.age,
            goals: self.goals,
            assists: self.assists,
            marketValue: self.marketValue,
            yellowCards: self.yellowCards,
            redCards: self.redCards,
            minutesPlayed: self.minutesPlayed,
            matchesPlayed: self.matchesPlayed,
            height: self.height,
            weight: self.weight,
            foot: self.foot,
            fantasyPoints: self.fantasyPoints,
            averageRating: self.averageRating
        )
    }
}
