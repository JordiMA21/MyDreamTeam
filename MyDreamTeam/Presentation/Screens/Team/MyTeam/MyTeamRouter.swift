//
//  MyTeamRouter.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI
import Foundation

// MARK: - My Team Router

final class MyTeamRouter: Router {
    // MARK: - Navigation Methods

    func navigateToPlayerTeam(teamId: Int) {
        let router = PlayerTeamRouter()
        let lineupUseCase = LineupUseCase(repository: LineupLocalRepository())
        let viewModel = PlayerTeamViewModel(
            router: router,
            lineupUseCase: lineupUseCase,
            teamId: teamId
        )
        navigator.push(to: Page(from: PlayerTeamView(viewModel: viewModel)))
    }

    func navigateToLineup(teamId: Int) {
        let router = LineupRouter()
        let lineupUseCase = LineupUseCase(repository: LineupLocalRepository())
        let teamUseCase = TeamDetailContainer.makeUseCase()
        let viewModel = LineupViewModel(
            router: router,
            lineupUseCase: lineupUseCase,
            teamUseCase: teamUseCase,
            teamId: teamId
        )
        navigator.push(to: Page(from: LineupView(viewModel: viewModel)))
    }
}
