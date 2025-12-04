//
//  AuctionUseCaseProtocol.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction Use Case Protocol

protocol AuctionUseCaseProtocol {
    func getActiveAuctions(leagueId: String) async throws -> [Auction]
    func getAuction(auctionId: String) async throws -> Auction
    func placeBid(auctionId: String, teamId: String, teamName: String, amount: Int) async throws -> Auction
    func getAuctionHistory(leagueId: String) async throws -> [Auction]
    func getTeamBids(leagueId: String, teamId: String) async throws -> [Auction]
}
