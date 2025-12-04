import Foundation
import FirebaseFirestore

// MARK: - Seed Data Manager

class SeedDataManager {
    static let shared = SeedDataManager()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Public Methods

    func seedAllData() async throws {
        print("🌱 Starting seed data...")
        try await seedTeams()
        try await seedPlayers()
        print("✅ Seed data completed!")
    }

    // MARK: - Seed Teams

    private func seedTeams() async throws {
        print("📋 Seeding teams...")

        let teams = [
            // La Liga (Spain)
            createTeamDTO(
                id: "team_real_madrid",
                name: "Real Madrid",
                country: "Spain",
                city: "Madrid",
                founded: 1902,
                league: "La Liga",
                coach: "Carlo Ancelotti",
                stadium: "Santiago Bernabéu",
                logo: "https://example.com/rm.png",
                colors: TeamColorsDTO(primary: "#FFFFFF", secondary: "#FFB81C"),
                season: 2024,
                stats: TeamStatsDTO(
                    played: 20, won: 14, drawn: 4, lost: 2,
                    goalsFor: 48, goalsAgainst: 18, points: 46, position: 1
                )
            ),
            createTeamDTO(
                id: "team_barcelona",
                name: "FC Barcelona",
                country: "Spain",
                city: "Barcelona",
                founded: 1899,
                league: "La Liga",
                coach: "Xavi Hernández",
                stadium: "Camp Nou",
                logo: "https://example.com/fcb.png",
                colors: TeamColorsDTO(primary: "#004D98", secondary: "#FFB81C"),
                season: 2024,
                stats: TeamStatsDTO(
                    played: 20, won: 13, drawn: 3, lost: 4,
                    goalsFor: 45, goalsAgainst: 22, points: 42, position: 2
                )
            ),
            createTeamDTO(
                id: "team_atletico_madrid",
                name: "Atlético Madrid",
                country: "Spain",
                city: "Madrid",
                founded: 1903,
                league: "La Liga",
                coach: "Diego Simeone",
                stadium: "Civitas Metropolitano",
                logo: "https://example.com/am.png",
                colors: TeamColorsDTO(primary: "#E23B33", secondary: "#FFFFFF"),
                season: 2024,
                stats: TeamStatsDTO(
                    played: 20, won: 12, drawn: 5, lost: 3,
                    goalsFor: 38, goalsAgainst: 20, points: 41, position: 3
                )
            ),

            // Premier League (England)
            createTeamDTO(
                id: "team_manchester_city",
                name: "Manchester City",
                country: "England",
                city: "Manchester",
                founded: 1880,
                league: "Premier League",
                coach: "Pep Guardiola",
                stadium: "Etihad Stadium",
                logo: "https://example.com/mci.png",
                colors: TeamColorsDTO(primary: "#6CABDE", secondary: "#FFFFFF"),
                season: 2024,
                stats: TeamStatsDTO(
                    played: 20, won: 15, drawn: 4, lost: 1,
                    goalsFor: 52, goalsAgainst: 15, points: 49, position: 1
                )
            ),
            createTeamDTO(
                id: "team_liverpool",
                name: "Liverpool FC",
                country: "England",
                city: "Liverpool",
                founded: 1892,
                league: "Premier League",
                coach: "Arne Slot",
                stadium: "Anfield",
                logo: "https://example.com/lfc.png",
                colors: TeamColorsDTO(primary: "#EC1C24", secondary: "#FFFFFF"),
                season: 2024,
                stats: TeamStatsDTO(
                    played: 20, won: 14, drawn: 3, lost: 3,
                    goalsFor: 47, goalsAgainst: 19, points: 45, position: 2
                )
            ),
            createTeamDTO(
                id: "team_arsenal",
                name: "Arsenal FC",
                country: "England",
                city: "London",
                founded: 1886,
                league: "Premier League",
                coach: "Mikel Arteta",
                stadium: "Emirates Stadium",
                logo: "https://example.com/afc.png",
                colors: TeamColorsDTO(primary: "#EF0107", secondary: "#FFFFFF"),
                season: 2024,
                stats: TeamStatsDTO(
                    played: 20, won: 13, drawn: 4, lost: 3,
                    goalsFor: 45, goalsAgainst: 21, points: 43, position: 3
                )
            ),
        ]

        for team in teams {
            try await db.collection("teams").document(team.id ?? "").setData(team.asDictionary())
        }

        print("✅ Teams seeded: \(teams.count)")
    }

    // MARK: - Seed Players

    private func seedPlayers() async throws {
        print("📋 Seeding players...")

        let players = [
            // Real Madrid Players
            createPlayerDTO(
                id: "player_vinicius",
                firstName: "Vinicius",
                lastName: "Junior",
                nationality: "Brazil",
                dateOfBirth: Date(timeIntervalSince1970: 892080000),
                position: "FWD",
                number: 7,
                height: 1.76,
                weight: 73,
                foot: "left",
                currentTeamId: "team_real_madrid",
                currentTeamName: "Real Madrid",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 18, goals: 12, assists: 5,
                    yellowCards: 3, redCards: 0, cleanSheets: 0,
                    minutes: 1485, averageRating: 8.4
                ),
                marketValue: 85.0
            ),
            createPlayerDTO(
                id: "player_benzema",
                firstName: "Karim",
                lastName: "Benzema",
                nationality: "France",
                dateOfBirth: Date(timeIntervalSince1970: 707011200),
                position: "FWD",
                number: 9,
                height: 1.85,
                weight: 81,
                foot: "right",
                currentTeamId: "team_real_madrid",
                currentTeamName: "Real Madrid",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 16, goals: 10, assists: 3,
                    yellowCards: 2, redCards: 0, cleanSheets: 0,
                    minutes: 1280, averageRating: 8.2
                ),
                marketValue: 35.0
            ),
            createPlayerDTO(
                id: "player_modric",
                firstName: "Luka",
                lastName: "Modrić",
                nationality: "Croatia",
                dateOfBirth: Date(timeIntervalSince1970: 595689600),
                position: "MID",
                number: 10,
                height: 1.72,
                weight: 70,
                foot: "right",
                currentTeamId: "team_real_madrid",
                currentTeamName: "Real Madrid",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 19, goals: 3, assists: 6,
                    yellowCards: 1, redCards: 0, cleanSheets: 0,
                    minutes: 1520, averageRating: 8.1
                ),
                marketValue: 28.0
            ),

            // Barcelona Players
            createPlayerDTO(
                id: "player_lewandowski",
                firstName: "Robert",
                lastName: "Lewandowski",
                nationality: "Poland",
                dateOfBirth: Date(timeIntervalSince1970: 681206400),
                position: "FWD",
                number: 9,
                height: 1.84,
                weight: 81,
                foot: "right",
                currentTeamId: "team_barcelona",
                currentTeamName: "FC Barcelona",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 20, goals: 14, assists: 4,
                    yellowCards: 2, redCards: 0, cleanSheets: 0,
                    minutes: 1680, averageRating: 8.3
                ),
                marketValue: 50.0
            ),
            createPlayerDTO(
                id: "player_gavi",
                firstName: "Pablo",
                lastName: "Gavi",
                nationality: "Spain",
                dateOfBirth: Date(timeIntervalSince1970: 1060560000),
                position: "MID",
                number: 6,
                height: 1.73,
                weight: 72,
                foot: "right",
                currentTeamId: "team_barcelona",
                currentTeamName: "FC Barcelona",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 18, goals: 2, assists: 5,
                    yellowCards: 3, redCards: 0, cleanSheets: 0,
                    minutes: 1440, averageRating: 7.8
                ),
                marketValue: 60.0
            ),

            // Manchester City Players
            createPlayerDTO(
                id: "player_haaland",
                firstName: "Erling",
                lastName: "Haaland",
                nationality: "Norway",
                dateOfBirth: Date(timeIntervalSince1970: 1007289600),
                position: "FWD",
                number: 9,
                height: 1.94,
                weight: 88,
                foot: "right",
                currentTeamId: "team_manchester_city",
                currentTeamName: "Manchester City",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 19, goals: 18, assists: 3,
                    yellowCards: 1, redCards: 0, cleanSheets: 0,
                    minutes: 1520, averageRating: 8.9
                ),
                marketValue: 180.0
            ),
            createPlayerDTO(
                id: "player_de_bruyne",
                firstName: "Kevin",
                lastName: "De Bruyne",
                nationality: "Belgium",
                dateOfBirth: Date(timeIntervalSince1970: 833923200),
                position: "MID",
                number: 17,
                height: 1.81,
                weight: 76,
                foot: "right",
                currentTeamId: "team_manchester_city",
                currentTeamName: "Manchester City",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 18, goals: 5, assists: 8,
                    yellowCards: 2, redCards: 0, cleanSheets: 0,
                    minutes: 1485, averageRating: 8.6
                ),
                marketValue: 75.0
            ),

            // Liverpool Players
            createPlayerDTO(
                id: "player_salah",
                firstName: "Mohamed",
                lastName: "Salah",
                nationality: "Egypt",
                dateOfBirth: Date(timeIntervalSince1970: 836601600),
                position: "FWD",
                number: 11,
                height: 1.75,
                weight: 71,
                foot: "left",
                currentTeamId: "team_liverpool",
                currentTeamName: "Liverpool FC",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 20, goals: 13, assists: 6,
                    yellowCards: 2, redCards: 0, cleanSheets: 0,
                    minutes: 1680, averageRating: 8.5
                ),
                marketValue: 70.0
            ),

            // Arsenal Players
            createPlayerDTO(
                id: "player_saka",
                firstName: "Bukayo",
                lastName: "Saka",
                nationality: "England",
                dateOfBirth: Date(timeIntervalSince1970: 1008412800),
                position: "FWD",
                number: 7,
                height: 1.78,
                weight: 74,
                foot: "left",
                currentTeamId: "team_arsenal",
                currentTeamName: "Arsenal FC",
                status: "active",
                season: 2024,
                stats: PlayerStatsDTO(
                    played: 19, goals: 8, assists: 7,
                    yellowCards: 1, redCards: 0, cleanSheets: 0,
                    minutes: 1520, averageRating: 8.0
                ),
                marketValue: 55.0
            ),
        ]

        for player in players {
            try await db.collection("players").document(player.id ?? "").setData(player.asDictionary())
        }

        print("✅ Players seeded: \(players.count)")
    }

    // MARK: - Helper Methods

    private func createTeamDTO(
        id: String,
        name: String,
        country: String,
        city: String,
        founded: Int,
        league: String,
        coach: String?,
        stadium: String?,
        logo: String?,
        colors: TeamColorsDTO?,
        season: Int,
        stats: TeamStatsDTO?
    ) -> FirebaseTeamDTO {
        FirebaseTeamDTO(
            id: id,
            name: name,
            country: country,
            city: city,
            founded: founded,
            league: league,
            coach: coach,
            stadium: stadium,
            logo: logo,
            colors: colors,
            season: season,
            stats: stats
        )
    }

    private func createPlayerDTO(
        id: String,
        firstName: String,
        lastName: String,
        nationality: String,
        dateOfBirth: Date,
        position: String,
        number: Int,
        height: Double?,
        weight: Double?,
        foot: String?,
        currentTeamId: String,
        currentTeamName: String?,
        status: String,
        season: Int,
        stats: PlayerStatsDTO?,
        marketValue: Double
    ) -> FirebasePlayerDTO {
        FirebasePlayerDTO(
            id: id,
            firstName: firstName,
            lastName: lastName,
            nationality: nationality,
            dateOfBirth: dateOfBirth,
            position: position,
            number: number,
            height: height,
            weight: weight,
            foot: foot,
            currentTeamId: currentTeamId,
            currentTeamName: currentTeamName,
            status: status,
            season: season,
            stats: stats,
            photo: nil,
            marketValue: marketValue
        )
    }
}

// MARK: - Helper Extension to convert DTO to Dictionary

extension FirebaseTeamDTO {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "name": name,
            "country": country,
            "city": city,
            "founded": founded,
            "league": league,
            "season": season,
        ]

        if let coach = coach {
            dict["coach"] = coach
        }
        if let stadium = stadium {
            dict["stadium"] = stadium
        }
        if let logo = logo {
            dict["logo"] = logo
        }

        if let colors = colors {
            dict["colors"] = [
                "primary": colors.primary,
                "secondary": colors.secondary ?? "",
            ]
        }

        if let stats = stats {
            dict["stats"] = [
                "played": stats.played,
                "won": stats.won,
                "drawn": stats.drawn,
                "lost": stats.lost,
                "goalsFor": stats.goalsFor,
                "goalsAgainst": stats.goalsAgainst,
                "points": stats.points,
                "position": stats.position,
            ]
        }

        return dict
    }
}

extension FirebasePlayerDTO {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "firstName": firstName,
            "lastName": lastName,
            "nationality": nationality,
            "dateOfBirth": Timestamp(date: dateOfBirth),
            "position": position,
            "number": number,
            "currentTeamId": currentTeamId,
            "status": status,
            "season": season,
            "marketValue": marketValue,
        ]

        if let height = height {
            dict["height"] = height
        }
        if let weight = weight {
            dict["weight"] = weight
        }
        if let foot = foot {
            dict["foot"] = foot
        }
        if let currentTeamName = currentTeamName {
            dict["currentTeamName"] = currentTeamName
        }
        if let photo = photo {
            dict["photo"] = photo
        }

        if let stats = stats {
            dict["stats"] = [
                "played": stats.played,
                "goals": stats.goals,
                "assists": stats.assists,
                "yellowCards": stats.yellowCards,
                "redCards": stats.redCards,
                "cleanSheets": stats.cleanSheets,
                "minutes": stats.minutes,
                "averageRating": stats.averageRating,
            ]
        }

        return dict
    }
}
