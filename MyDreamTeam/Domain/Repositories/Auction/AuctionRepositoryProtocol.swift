//
//  AuctionRepositoryProtocol.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction Repository Protocol

protocol AuctionRepositoryProtocol {
    // Fetch auctions
    func getActiveAuctions(leagueId: String) async throws -> [Auction]
    func getAuction(auctionId: String) async throws -> Auction
    func getAuctionsByPlayer(playerId: Int, leagueId: String) async throws -> [Auction]

    // Create auction
    func createAuction(_ auction: Auction) async throws

    // Place bid
    func placeBid(_ bid: Bid, auctionId: String) async throws

    // Update auction
    func updateAuction(_ auction: Auction) async throws

    // End auction
    func endAuction(auctionId: String, winningBid: Bid?) async throws

    // Get auction history
    func getAuctionHistory(leagueId: String) async throws -> [Auction]
    func getTeamAuctionHistory(leagueId: String, teamId: String) async throws -> [Auction]
}
