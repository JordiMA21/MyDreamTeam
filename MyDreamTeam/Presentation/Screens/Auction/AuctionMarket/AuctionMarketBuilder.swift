//
//  AuctionMarketBuilder.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Auction Market Builder

enum AuctionMarketBuilder {
    @MainActor
    static func build(leagueId: String) -> some View {
        let router = AuctionMarketRouter()
        let repository = AuctionLocalRepository()
        let useCase = AuctionUseCase(repository: repository)
        let viewModel = AuctionMarketViewModel(router: router, useCase: useCase, leagueId: leagueId)
        return AuctionMarketView(viewModel: viewModel)
    }
}
