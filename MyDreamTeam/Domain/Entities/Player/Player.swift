import Foundation

struct Player: Identifiable, Equatable {
    let id: Int
    let name: String
    let position: String
    let team: String
    let number: Int
    let image: String
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
    let foot: String // Left, Right, Ambidextrous

    // Fantasy stats
    let fantasyPoints: Double
    let averageRating: Double
}
