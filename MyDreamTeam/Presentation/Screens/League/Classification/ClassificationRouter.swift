//
//  ClassificationRouter.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI
import Foundation

// MARK: - Classification Router

final class ClassificationRouter: Router {
    // Navigation methods
    func showTeamDetails(_ teamId: String) {
        navigator.push(to: Page(from: Text("Team Details: \(teamId)")))
    }
}
