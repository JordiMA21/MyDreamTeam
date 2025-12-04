//
//  ClassificationViewModel.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Standing Model

struct Standing: Identifiable {
    let id: String
    let teamName: String
    let points: Int
    let matches: Int
}

// MARK: - Classification ViewModel

@MainActor
final class ClassificationViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var standings: [Standing] = []
    @Published var isLoading = false

    // MARK: - Private Properties

    private let router: ClassificationRouter

    // MARK: - Initialization

    init(router: ClassificationRouter) {
        self.router = router
    }

    // MARK: - Public Methods

    func loadStandings(leagueId: String) {
        Task {
            isLoading = true
            // Simulate loading standings
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay

            standings = generateMockStandings()
            isLoading = false
        }
    }

    // MARK: - Private Methods

    private func generateMockStandings() -> [Standing] {
        [
            Standing(id: "1", teamName: "Team Alpha", points: 920, matches: 12),
            Standing(id: "2", teamName: "Team Beta", points: 890, matches: 12),
            Standing(id: "3", teamName: "Team Gamma", points: 850, matches: 12),
            Standing(id: "4", teamName: "Team Delta", points: 820, matches: 12),
            Standing(id: "5", teamName: "Team Epsilon", points: 780, matches: 12),
            Standing(id: "6", teamName: "Team Zeta", points: 750, matches: 12),
            Standing(id: "7", teamName: "Team Eta", points: 720, matches: 12),
            Standing(id: "8", teamName: "Team Theta", points: 680, matches: 12),
        ]
    }
}
