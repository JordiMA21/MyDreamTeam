import Foundation

struct MockPlayerData {
    static let samplePlayer = Player(
        id: 1,
        name: "Vinícius Júnior",
        position: "Delantero",
        team: "Real Madrid",
        number: 7,
        image: "https://example.com/vinicius.png",
        nationality: "Brasil",
        age: 24,
        goals: 18,
        assists: 8,
        marketValue: 120.0,
        yellowCards: 3,
        redCards: 0,
        minutesPlayed: 2340,
        matchesPlayed: 26,
        height: "180 cm",
        weight: "73 kg",
        foot: "Left",
        fantasyPoints: 285.5,
        averageRating: 7.8
    )

    static let allPlayers: [Player] = [
        Player(
            id: 1, name: "Vinícius Júnior", position: "Delantero", team: "Real Madrid", number: 7,
            image: "https://example.com/vinicius.png", nationality: "Brasil", age: 24,
            goals: 18, assists: 8, marketValue: 120.0, yellowCards: 3, redCards: 0,
            minutesPlayed: 2340, matchesPlayed: 26, height: "180 cm", weight: "73 kg", foot: "Left",
            fantasyPoints: 285.5, averageRating: 7.8
        ),
        Player(
            id: 2, name: "Karim Benzema", position: "Delantero", team: "Real Madrid", number: 9,
            image: "https://example.com/benzema.png", nationality: "Francia", age: 36,
            goals: 15, assists: 5, marketValue: 80.0, yellowCards: 2, redCards: 0,
            minutesPlayed: 1890, matchesPlayed: 22, height: "185 cm", weight: "80 kg", foot: "Right",
            fantasyPoints: 245.0, averageRating: 7.5
        ),
        Player(
            id: 3, name: "Federico Valverde", position: "Centrocampista", team: "Real Madrid", number: 15,
            image: "https://example.com/valverde.png", nationality: "Uruguay", age: 25,
            goals: 3, assists: 2, marketValue: 85.0, yellowCards: 1, redCards: 0,
            minutesPlayed: 1650, matchesPlayed: 20, height: "176 cm", weight: "70 kg", foot: "Right",
            fantasyPoints: 195.0, averageRating: 7.2
        ),
    ]
}
