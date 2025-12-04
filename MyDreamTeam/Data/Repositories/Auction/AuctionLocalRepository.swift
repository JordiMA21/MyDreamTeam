//
//  AuctionLocalRepository.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction Local Repository

final class AuctionLocalRepository: AuctionRepositoryProtocol {
    private var auctions: [Auction] = []

    init() {
        setupMockData()
    }

    func getActiveAuctions(leagueId: String) async throws -> [Auction] {
        auctions.filter { $0.leagueId == leagueId && $0.isActive }
    }

    func getAuction(auctionId: String) async throws -> Auction {
        guard let auction = auctions.first(where: { $0.id == auctionId }) else {
            throw AuctionError.auctionEnded
        }
        return auction
    }

    func getAuctionsByPlayer(playerId: Int, leagueId: String) async throws -> [Auction] {
        auctions.filter { $0.playerId == playerId && $0.leagueId == leagueId }
    }

    func createAuction(_ auction: Auction) async throws {
        auctions.append(auction)
    }

    func placeBid(_ bid: Bid, auctionId: String) async throws {
        guard let index = auctions.firstIndex(where: { $0.id == auctionId }) else {
            throw AuctionError.auctionEnded
        }

        var updatedAuction = auctions[index]
        updatedAuction.bids.append(bid)
        auctions[index] = updatedAuction
    }

    func updateAuction(_ auction: Auction) async throws {
        guard let index = auctions.firstIndex(where: { $0.id == auction.id }) else {
            throw AuctionError.auctionEnded
        }
        auctions[index] = auction
    }

    func endAuction(auctionId: String, winningBid: Bid?) async throws {
        guard let index = auctions.firstIndex(where: { $0.id == auctionId }) else {
            throw AuctionError.auctionEnded
        }

        var updatedAuction = auctions[index]
        updatedAuction.status = .ended
        if let winningBid = winningBid {
            updatedAuction.winningTeamId = winningBid.teamId
        }
        auctions[index] = updatedAuction
    }

    func getAuctionHistory(leagueId: String) async throws -> [Auction] {
        auctions.filter { $0.leagueId == leagueId && $0.status == .ended }
    }

    func getTeamAuctionHistory(leagueId: String, teamId: String) async throws -> [Auction] {
        auctions.filter { auction in
            auction.leagueId == leagueId &&
            auction.bids.contains { $0.teamId == teamId }
        }
    }

    // MARK: - Mock Data

    private func setupMockData() {
        let leagueId = "1"
        let now = Date()

        // Create 8 mock auctions
        let mockAuctions: [Auction] = [
            Auction(
                id: "auction_1",
                leagueId: leagueId,
                playerId: 1,
                playerName: "Cristiano Ronaldo",
                playerPosition: "ST",
                playerTeam: "Manchester United",
                marketValue: 5000000,
                currentBid: 5000000,
                bids: [
                    Bid(auctionId: "auction_1", teamId: "team_1", teamName: "Team Alpha", amount: 5000000),
                    Bid(auctionId: "auction_1", teamId: "team_2", teamName: "Team Beta", amount: 5500000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 3) // 3 days
            ),
            Auction(
                id: "auction_2",
                leagueId: leagueId,
                playerId: 2,
                playerName: "Lionel Messi",
                playerPosition: "LW",
                playerTeam: "Inter Miami",
                marketValue: 4500000,
                currentBid: 4500000,
                bids: [
                    Bid(auctionId: "auction_2", teamId: "team_3", teamName: "Team Gamma", amount: 4500000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 2) // 2 days
            ),
            Auction(
                id: "auction_3",
                leagueId: leagueId,
                playerId: 3,
                playerName: "Lamine Yamal",
                playerPosition: "RW",
                playerTeam: "Barcelona",
                marketValue: 8000000,
                currentBid: 8000000,
                bids: [
                    Bid(auctionId: "auction_3", teamId: "team_1", teamName: "Team Alpha", amount: 8000000),
                    Bid(auctionId: "auction_3", teamId: "team_2", teamName: "Team Beta", amount: 8500000),
                    Bid(auctionId: "auction_3", teamId: "team_3", teamName: "Team Gamma", amount: 9000000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 1) // 1 day
            ),
            Auction(
                id: "auction_4",
                leagueId: leagueId,
                playerId: 4,
                playerName: "Jude Bellingham",
                playerPosition: "CM",
                playerTeam: "Real Madrid",
                marketValue: 12000000,
                currentBid: 12000000,
                bids: [
                    Bid(auctionId: "auction_4", teamId: "team_2", teamName: "Team Beta", amount: 12000000),
                    Bid(auctionId: "auction_4", teamId: "team_4", teamName: "Team Delta", amount: 13000000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 4) // 4 days
            ),
            Auction(
                id: "auction_5",
                leagueId: leagueId,
                playerId: 5,
                playerName: "Florian Wirtz",
                playerPosition: "LW",
                playerTeam: "Bayer Leverkusen",
                marketValue: 10000000,
                currentBid: 10000000,
                bids: [
                    Bid(auctionId: "auction_5", teamId: "team_1", teamName: "Team Alpha", amount: 10000000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 2) // 2 days
            ),
            Auction(
                id: "auction_6",
                leagueId: leagueId,
                playerId: 6,
                playerName: "Antonio Rüdiger",
                playerPosition: "CB",
                playerTeam: "Real Madrid",
                marketValue: 3500000,
                currentBid: 3500000,
                bids: [
                    Bid(auctionId: "auction_6", teamId: "team_3", teamName: "Team Gamma", amount: 3500000),
                    Bid(auctionId: "auction_6", teamId: "team_4", teamName: "Team Delta", amount: 4000000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 3) // 3 days
            ),
            Auction(
                id: "auction_7",
                leagueId: leagueId,
                playerId: 7,
                playerName: "Kyle Walker",
                playerPosition: "RB",
                playerTeam: "Manchester City",
                marketValue: 2500000,
                currentBid: 2500000,
                bids: [
                    Bid(auctionId: "auction_7", teamId: "team_4", teamName: "Team Delta", amount: 2500000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 5) // 5 days
            ),
            Auction(
                id: "auction_8",
                leagueId: leagueId,
                playerId: 8,
                playerName: "Ederson",
                playerPosition: "GK",
                playerTeam: "Manchester City",
                marketValue: 3000000,
                currentBid: 3000000,
                bids: [
                    Bid(auctionId: "auction_8", teamId: "team_1", teamName: "Team Alpha", amount: 3000000),
                    Bid(auctionId: "auction_8", teamId: "team_2", teamName: "Team Beta", amount: 3500000),
                    Bid(auctionId: "auction_8", teamId: "team_3", teamName: "Team Gamma", amount: 4000000),
                ],
                startDate: now,
                endDate: now.addingTimeInterval(86400 * 2) // 2 days
            ),
        ]

        auctions = mockAuctions
    }
}
