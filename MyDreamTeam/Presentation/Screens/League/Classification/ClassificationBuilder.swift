//
//  ClassificationBuilder.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Classification Builder

enum ClassificationBuilder {
    @MainActor
    static func build() -> some View {
        let router = ClassificationRouter()
        let viewModel = ClassificationViewModel(router: router)
        return ClassificationView(viewModel: viewModel)
    }
}
