//
//  HomeBuilder.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Home Builder

enum HomeBuilder {
    @MainActor
    static func build() -> some View {
        let router = HomeRouter()
        let viewModel = HomeViewModel(router: router)
        return HomeView(viewModel: viewModel)
    }
}
