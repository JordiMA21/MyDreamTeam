import Foundation

struct MockTeamData {
    static let sampleTeam = Team(
        id: 1,
        name: "Real Madrid",
        logo: "https://example.com/logo.png",
        city: "Madrid",
        country: "España",
        foundedYear: 1902,
        coach: "Carlo Ancelotti",
        coachImage: "https://example.com/coach.png",
        stadium: "Santiago Bernabéu",
        capacity: 81044,
        league: "La Liga",
        position: 1,
        points: 76,
        wins: 24,
        draws: 4,
        losses: 2,
        goalsFor: 78,
        goalsAgainst: 18
    )

    static let samplePlayers: [Player] = [
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
        Player(
            id: 4, name: "Luka Modrić", position: "Centrocampista", team: "Real Madrid", number: 10,
            image: "https://example.com/modric.png", nationality: "Croacia", age: 38,
            goals: 2, assists: 4, marketValue: 20.0, yellowCards: 1, redCards: 0,
            minutesPlayed: 1560, matchesPlayed: 19, height: "172 cm", weight: "68 kg", foot: "Right",
            fantasyPoints: 165.0, averageRating: 7.0
        ),
        Player(
            id: 5, name: "Toni Kroos", position: "Centrocampista", team: "Real Madrid", number: 8,
            image: "https://example.com/kroos.png", nationality: "Alemania", age: 33,
            goals: 2, assists: 3, marketValue: 30.0, yellowCards: 2, redCards: 0,
            minutesPlayed: 1440, matchesPlayed: 18, height: "183 cm", weight: "76 kg", foot: "Right",
            fantasyPoints: 155.0, averageRating: 6.9
        ),
        Player(
            id: 6, name: "Sergio Ramos", position: "Defensa", team: "Real Madrid", number: 4,
            image: "https://example.com/ramos.png", nationality: "España", age: 37,
            goals: 1, assists: 0, marketValue: 15.0, yellowCards: 4, redCards: 0,
            minutesPlayed: 1350, matchesPlayed: 16, height: "184 cm", weight: "82 kg", foot: "Right",
            fantasyPoints: 145.0, averageRating: 6.8
        ),
        Player(
            id: 7, name: "Éder Militão", position: "Defensa", team: "Real Madrid", number: 3,
            image: "https://example.com/militao.png", nationality: "Brasil", age: 25,
            goals: 1, assists: 0, marketValue: 60.0, yellowCards: 1, redCards: 0,
            minutesPlayed: 1680, matchesPlayed: 21, height: "186 cm", weight: "79 kg", foot: "Right",
            fantasyPoints: 175.0, averageRating: 7.1
        ),
        Player(
            id: 8, name: "Nacho Fernández", position: "Defensa", team: "Real Madrid", number: 6,
            image: "https://example.com/nacho.png", nationality: "España", age: 33,
            goals: 0, assists: 0, marketValue: 12.0, yellowCards: 2, redCards: 0,
            minutesPlayed: 890, matchesPlayed: 12, height: "179 cm", weight: "75 kg", foot: "Right",
            fantasyPoints: 105.0, averageRating: 6.7
        ),
        Player(
            id: 9, name: "Andriy Lunin", position: "Portero", team: "Real Madrid", number: 13,
            image: "https://example.com/lunin.png", nationality: "Ucrania", age: 25,
            goals: 0, assists: 0, marketValue: 25.0, yellowCards: 0, redCards: 0,
            minutesPlayed: 1260, matchesPlayed: 15, height: "186 cm", weight: "84 kg", foot: "Right",
            fantasyPoints: 195.0, averageRating: 7.3
        ),
    ]
}
