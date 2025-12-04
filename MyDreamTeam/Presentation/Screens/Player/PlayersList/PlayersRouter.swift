//
//  PlayersRouter.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI
import Foundation

// MARK: - Players Router

final class PlayersRouter: Router {
    // MARK: - Navigation Methods

    func navigateToPlayerDetail(_ playerId: Int) {
        navigator.push(to: Page(from: PlayerDetailBuilder().build(playerId: playerId)))
    }
}
