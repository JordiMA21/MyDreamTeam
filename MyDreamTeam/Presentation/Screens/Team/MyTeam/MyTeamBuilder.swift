//
//  MyTeamBuilder.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - My Team Builder

enum MyTeamBuilder {
    @MainActor
    static func build() -> some View {
        let router = MyTeamRouter()
        let viewModel = MyTeamViewModel(router: router)
        return MyTeamView(viewModel: viewModel)
    }
}
