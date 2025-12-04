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

    // MARK: - Conversion to PlayerEntity

    func toPlayerEntity() -> PlayerEntity {
        let nameParts = name.components(separatedBy: " ")
        let firstName = nameParts.first ?? name
        let lastName = nameParts.dropFirst().joined(separator: " ")

        let dateOfBirth = Calendar.current.date(byAdding: .year, value: -age, to: Date()) ?? Date()

        let heightValue = Double(height.replacingOccurrences(of: "cm", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
        let weightValue = Double(weight.replacingOccurrences(of: "kg", with: "").trimmingCharacters(in: .whitespaces)) ?? 0

        return PlayerEntity(
            id: String(id),
            firstName: firstName,
            lastName: lastName,
            nationality: nationality,
            dateOfBirth: dateOfBirth,
            position: position,
            number: number,
            height: heightValue,
            weight: weightValue,
            foot: foot.lowercased(),
            currentTeamId: team,
            currentTeamName: team,
            status: "active",
            season: Calendar.current.component(.year, from: Date()),
            stats: PlayerStatsEntity(
                played: matchesPlayed,
                goals: goals,
                assists: assists,
                yellowCards: yellowCards,
                redCards: redCards,
                cleanSheets: 0,
                minutes: minutesPlayed,
                averageRating: averageRating
            ),
            photo: URL(string: image),
            marketValue: marketValue
        )
    }
}
