//
//  AuctionDTO.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction DTO

struct AuctionDTO: Codable {
    let id: String
    let leagueId: String
    let playerId: Int
    let playerName: String
    let playerPosition: String
    let playerTeam: String
    let marketValue: Int
    let currentBid: Int
    let bids: [BidDTO]
    let startDate: Date
    let endDate: Date
    let status: String // "active", "ended", "cancelled"
    let winningTeamId: String?

    // MARK: - Mapping to Domain

    func toDomain() -> Auction {
        Auction(
            id: id,
            leagueId: leagueId,
            playerId: playerId,
            playerName: playerName,
            playerPosition: playerPosition,
            playerTeam: playerTeam,
            marketValue: marketValue,
            currentBid: currentBid,
            bids: bids.map { $0.toDomain() },
            startDate: startDate,
            endDate: endDate,
            status: AuctionStatus(rawValue: status) ?? .active,
            winningTeamId: winningTeamId
        )
    }
}

// MARK: - Bid DTO

struct BidDTO: Codable {
    let id: String
    let auctionId: String
    let teamId: String
    let teamName: String
    let amount: Int
    let bidTime: Date

    // MARK: - Mapping to Domain

    func toDomain() -> Bid {
        Bid(
            id: id,
            auctionId: auctionId,
            teamId: teamId,
            teamName: teamName,
            amount: amount,
            bidTime: bidTime
        )
    }

    // MARK: - Factory

    init(from bid: Bid) {
        self.id = bid.id
        self.auctionId = bid.auctionId
        self.teamId = bid.teamId
        self.teamName = bid.teamName
        self.amount = bid.amount
        self.bidTime = bid.bidTime
    }
}
