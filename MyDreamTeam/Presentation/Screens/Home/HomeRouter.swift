//
//  HomeRouter.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Home Router

final class HomeRouter: Router {
    // MARK: - Navigation Methods

    func navigateToLogin() {
        // TODO: Implement login navigation when auth feature is ready
        showToastWithCloseAction(with: "Login feature coming soon")
    }

    func navigateToSignUp() {
        // TODO: Implement sign up navigation when auth feature is ready
        showToastWithCloseAction(with: "Sign Up feature coming soon")
    }

    func navigateToAuctionMarket(leagueId: String) {
        Task { @MainActor in
            navigator.push(to: Page(from: AuctionMarketBuilder.build(leagueId: leagueId)))
        }
    }
}
