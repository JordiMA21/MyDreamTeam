//
//  MyTeamViewModel.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - My Team ViewModel

@MainActor
final class MyTeamViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var teamId: Int = 1 // Mock user's team ID

    // MARK: - Private Properties

    private let router: MyTeamRouter

    // MARK: - Initialization

    init(router: MyTeamRouter) {
        self.router = router
    }

    // MARK: - Public Methods

    func didTapPlayersList() {
        router.navigateToPlayerTeam(teamId: teamId)
    }

    func didTapLineup() {
        router.navigateToLineup(teamId: teamId)
    }
}
