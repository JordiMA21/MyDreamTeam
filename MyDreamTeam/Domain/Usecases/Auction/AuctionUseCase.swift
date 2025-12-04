//
//  AuctionUseCase.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction Use Case

final class AuctionUseCase: AuctionUseCaseProtocol {
    private let repository: AuctionRepositoryProtocol

    init(repository: AuctionRepositoryProtocol) {
        self.repository = repository
    }

    func getActiveAuctions(leagueId: String) async throws -> [Auction] {
        try await repository.getActiveAuctions(leagueId: leagueId)
    }

    func getAuction(auctionId: String) async throws -> Auction {
        try await repository.getAuction(auctionId: auctionId)
    }

    func placeBid(auctionId: String, teamId: String, teamName: String, amount: Int) async throws -> Auction {
        // Get current auction
        var auction = try await repository.getAuction(auctionId: auctionId)

        // Validate bid
        guard amount > auction.currentHighestBid else {
            throw AuctionError.bidTooLow(minimumAmount: auction.currentHighestBid + 1)
        }

        guard auction.isActive else {
            throw AuctionError.auctionEnded
        }

        // Create and place bid
        let bid = Bid(auctionId: auctionId, teamId: teamId, teamName: teamName, amount: amount)
        try await repository.placeBid(bid, auctionId: auctionId)

        // Return updated auction
        return try await repository.getAuction(auctionId: auctionId)
    }

    func getAuctionHistory(leagueId: String) async throws -> [Auction] {
        try await repository.getAuctionHistory(leagueId: leagueId)
    }

    func getTeamBids(leagueId: String, teamId: String) async throws -> [Auction] {
        try await repository.getTeamAuctionHistory(leagueId: leagueId, teamId: teamId)
    }
}

// MARK: - Auction Error

enum AuctionError: LocalizedError {
    case bidTooLow(minimumAmount: Int)
    case auctionEnded
    case playerNotFound
    case leagueNotFound
    case invalidAmount

    var errorDescription: String? {
        switch self {
        case .bidTooLow(let minimumAmount):
            return "La oferta debe ser superior a \(minimumAmount)"
        case .auctionEnded:
            return "La subasta ha finalizado"
        case .playerNotFound:
            return "Jugador no encontrado"
        case .leagueNotFound:
            return "Liga no encontrada"
        case .invalidAmount:
            return "Cantidad inválida"
        }
    }
}
