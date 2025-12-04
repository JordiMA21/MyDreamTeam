import Foundation

struct TeamDTO: Codable {
    let id: Int
    let name: String
    let logo: String?
    let city: String
    let country: String
    let foundedYear: Int
    let coach: String
    let coachImage: String?
    let stadium: String
    let capacity: Int
    let league: String
    let position: Int
    let points: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logo
        case city
        case country
        case foundedYear = "founded_year"
        case coach
        case coachImage = "coach_image"
        case stadium
        case capacity
        case league
        case position
        case points
        case wins
        case draws
        case losses
        case goalsFor = "goals_for"
        case goalsAgainst = "goals_against"
    }
}

// MARK: - Mapper to Domain
extension TeamDTO {
    func toDomain() -> Team {
        Team(
            id: self.id,
            name: self.name,
            logo: self.logo ?? "",
            city: self.city,
            country: self.country,
            foundedYear: self.foundedYear,
            coach: self.coach,
            coachImage: self.coachImage ?? "",
            stadium: self.stadium,
            capacity: self.capacity,
            league: self.league,
            position: self.position,
            points: self.points,
            wins: self.wins,
            draws: self.draws,
            losses: self.losses,
            goalsFor: self.goalsFor,
            goalsAgainst: self.goalsAgainst
        )
    }
}
