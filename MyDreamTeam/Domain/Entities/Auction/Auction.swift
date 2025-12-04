//
//  Auction.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction

struct Auction: Identifiable, Equatable {
    let id: String
    let leagueId: String
    let playerId: Int
    let playerName: String
    let playerPosition: String
    let playerTeam: String
    let marketValue: Int // Minimum bid
    let currentBid: Int
    var bids: [Bid] = []
    let startDate: Date
    var endDate: Date
    var status: AuctionStatus = .active
    var winningTeamId: String?

    // Computed properties
    var currentHighestBid: Int {
        bids.max(by: { $0.amount < $1.amount })?.amount ?? marketValue
    }

    var highestBidder: Bid? {
        bids.max(by: { $0.amount < $1.amount })
    }

    var isActive: Bool {
        status == .active && Date() < endDate
    }

    var timeRemaining: TimeInterval {
        endDate.timeIntervalSince(Date())
    }

    var minutesRemaining: Int {
        Int(timeRemaining / 60)
    }
}

// MARK: - Auction Status

enum AuctionStatus: String, Codable {
    case active
    case ended
    case cancelled
}

// MARK: - Bid

struct Bid: Identifiable, Equatable {
    let id: String
    let auctionId: String
    let teamId: String
    let teamName: String
    let amount: Int
    let bidTime: Date

    // Custom initializer for creating new bids
    init(auctionId: String, teamId: String, teamName: String, amount: Int) {
        self.id = UUID().uuidString
        self.auctionId = auctionId
        self.teamId = teamId
        self.teamName = teamName
        self.amount = amount
        self.bidTime = Date()
    }

    // Standard initializer for existing bids (from DTO)
    init(id: String, auctionId: String, teamId: String, teamName: String, amount: Int, bidTime: Date) {
        self.id = id
        self.auctionId = auctionId
        self.teamId = teamId
        self.teamName = teamName
        self.amount = amount
        self.bidTime = bidTime
    }
}
