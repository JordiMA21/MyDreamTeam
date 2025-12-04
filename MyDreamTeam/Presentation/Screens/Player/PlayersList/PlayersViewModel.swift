//
//  PlayersViewModel.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Players ViewModel

@MainActor
final class PlayersViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var searchText: String = ""
    @Published var players: [Player] = []
    @Published var selectedPosition: String? = nil

    // MARK: - Computed Properties

    var filteredPlayers: [Player] {
        var result = players

        if !searchText.isEmpty {
            result = result.filter { player in
                player.name.localizedCaseInsensitiveContains(searchText) ||
                player.team.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let selectedPosition, !selectedPosition.isEmpty {
            result = result.filter { $0.position == selectedPosition }
        }

        return result.sorted { $0.fantasyPoints > $1.fantasyPoints }
    }

    // MARK: - Private Properties

    private let router: PlayersRouter

    // MARK: - Initialization

    init(router: PlayersRouter) {
        self.router = router
        setupMockData()
    }

    // MARK: - Public Methods

    func didSelectPlayer(_ player: Player) {
        router.navigateToPlayerDetail(player.id)
    }

    func didAddPlayerToTeam(_ player: Player) {
        router.showToastWithCloseAction(with: "\(player.name) added to team!", closeAction: {})
    }

    // MARK: - Private Methods

    private func setupMockData() {
        players = [
            Player(id: 1, name: "Cristiano Ronaldo", position: "ST", team: "Manchester United", number: 7, image: "cr7", nationality: "Portuguese", age: 38, goals: 50, assists: 15, marketValue: 50000000, yellowCards: 5, redCards: 0, minutesPlayed: 2500, matchesPlayed: 35, height: "187cm", weight: "84kg", foot: "Right", fantasyPoints: 850, averageRating: 8.5),
            Player(id: 2, name: "Lionel Messi", position: "LW", team: "Inter Miami", number: 10, image: "messi", nationality: "Argentine", age: 36, goals: 45, assists: 20, marketValue: 45000000, yellowCards: 3, redCards: 0, minutesPlayed: 2400, matchesPlayed: 34, height: "170cm", weight: "72kg", foot: "Left", fantasyPoints: 920, averageRating: 8.9),
            Player(id: 3, name: "Lamine Yamal", position: "RW", team: "Barcelona", number: 19, image: "yamal", nationality: "Spanish", age: 16, goals: 12, assists: 8, marketValue: 80000000, yellowCards: 2, redCards: 0, minutesPlayed: 1200, matchesPlayed: 22, height: "175cm", weight: "70kg", foot: "Left", fantasyPoints: 680, averageRating: 7.8),
            Player(id: 4, name: "Jude Bellingham", position: "CM", team: "Real Madrid", number: 5, image: "bellingham", nationality: "English", age: 20, goals: 18, assists: 10, marketValue: 120000000, yellowCards: 4, redCards: 0, minutesPlayed: 2200, matchesPlayed: 32, height: "186cm", weight: "82kg", foot: "Right", fantasyPoints: 760, averageRating: 8.2),
            Player(id: 5, name: "Florian Wirtz", position: "LW", team: "Bayer Leverkusen", number: 10, image: "wirtz", nationality: "German", age: 21, goals: 28, assists: 14, marketValue: 100000000, yellowCards: 3, redCards: 0, minutesPlayed: 2100, matchesPlayed: 31, height: "179cm", weight: "76kg", foot: "Left", fantasyPoints: 820, averageRating: 8.4),
            Player(id: 6, name: "Antonio Rüdiger", position: "CB", team: "Real Madrid", number: 2, image: "rudiger", nationality: "German", age: 30, goals: 3, assists: 1, marketValue: 35000000, yellowCards: 6, redCards: 0, minutesPlayed: 2800, matchesPlayed: 35, height: "191cm", weight: "86kg", foot: "Right", fantasyPoints: 650, averageRating: 7.6),
            Player(id: 7, name: "Kyle Walker", position: "RB", team: "Manchester City", number: 2, image: "walker", nationality: "English", age: 33, goals: 2, assists: 3, marketValue: 25000000, yellowCards: 4, redCards: 0, minutesPlayed: 2300, matchesPlayed: 32, height: "183cm", weight: "79kg", foot: "Right", fantasyPoints: 720, averageRating: 7.9),
            Player(id: 8, name: "Dani Alves", position: "RB", team: "Pumas UNAM", number: 13, image: "alves", nationality: "Brazilian", age: 40, goals: 1, assists: 2, marketValue: 5000000, yellowCards: 2, redCards: 0, minutesPlayed: 900, matchesPlayed: 15, height: "180cm", weight: "77kg", foot: "Right", fantasyPoints: 540, averageRating: 7.0),
            Player(id: 9, name: "Manuel Neuer", position: "GK", team: "Bayern Munich", number: 1, image: "neuer", nationality: "German", age: 37, goals: 0, assists: 0, marketValue: 20000000, yellowCards: 1, redCards: 0, minutesPlayed: 2700, matchesPlayed: 30, height: "193cm", weight: "90kg", foot: "Right", fantasyPoints: 780, averageRating: 8.1),
            Player(id: 10, name: "Ederson", position: "GK", team: "Manchester City", number: 31, image: "ederson", nationality: "Brazilian", age: 29, goals: 0, assists: 1, marketValue: 30000000, yellowCards: 2, redCards: 0, minutesPlayed: 2600, matchesPlayed: 32, height: "188cm", weight: "87kg", foot: "Right", fantasyPoints: 800, averageRating: 8.3),
            Player(id: 11, name: "Ángel Di María", position: "RW", team: "Benfica", number: 11, image: "dimaria", nationality: "Argentine", age: 35, goals: 8, assists: 6, marketValue: 15000000, yellowCards: 3, redCards: 0, minutesPlayed: 1500, matchesPlayed: 24, height: "180cm", weight: "75kg", foot: "Left", fantasyPoints: 620, averageRating: 7.4),
            Player(id: 12, name: "Vinícius Júnior", position: "LW", team: "Real Madrid", number: 20, image: "vini", nationality: "Brazilian", age: 23, goals: 35, assists: 12, marketValue: 90000000, yellowCards: 5, redCards: 0, minutesPlayed: 2400, matchesPlayed: 34, height: "176cm", weight: "73kg", foot: "Left", fantasyPoints: 900, averageRating: 8.7),
        ]
    }
}
