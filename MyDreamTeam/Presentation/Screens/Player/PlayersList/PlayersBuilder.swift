//
//  PlayersBuilder.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Players Builder

enum PlayersBuilder {
    @MainActor
    static func build() -> some View {
        let router = PlayersRouter()
        let viewModel = PlayersViewModel(router: router)
        return PlayersView(viewModel: viewModel)
    }
}
