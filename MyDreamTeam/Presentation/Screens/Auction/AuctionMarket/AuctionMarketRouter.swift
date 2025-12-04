//
//  AuctionMarketRouter.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI
import Foundation

// MARK: - Auction Market Router

final class AuctionMarketRouter: Router {
    // Navigation methods
    func showAuctionDetails(_ auction: Auction) {
        navigator.push(to: Page(from: Text("Detalles de Subasta: \(auction.playerName)")))
    }
}
