import Foundation

struct Team: Identifiable, Equatable {
    let id: Int
    let name: String
    let logo: String
    let city: String
    let country: String
    let foundedYear: Int
    let coach: String
    let coachImage: String
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
}
