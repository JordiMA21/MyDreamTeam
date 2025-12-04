//
//  AuctionMarketViewModel.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Auction Market ViewModel

@MainActor
final class AuctionMarketViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var activeAuctions: [Auction] = []
    @Published var isLoading = false
    @Published var selectedAuction: Auction?
    @Published var showBidSheet = false
    @Published var showInfoSheet = false

    // MARK: - Private Properties

    private let router: AuctionMarketRouter
    private let useCase: AuctionUseCaseProtocol
    let leagueId: String

    // MARK: - Initialization

    init(router: AuctionMarketRouter, useCase: AuctionUseCaseProtocol, leagueId: String) {
        self.router = router
        self.useCase = useCase
        self.leagueId = leagueId
    }

    // MARK: - Public Methods

    func loadAuctions() {
        Task {
            isLoading = true
            do {
                activeAuctions = try await useCase.getActiveAuctions(leagueId: leagueId)
                isLoading = false
            } catch {
                isLoading = false
                router.showAlert(with: AppError.customError(error.localizedDescription, nil), action: {})
            }
        }
    }

    func didTapBid(_ auction: Auction) {
        selectedAuction = auction
        showBidSheet = true
    }

    func didTapInfo(_ auction: Auction) {
        selectedAuction = auction
        showInfoSheet = true
    }

    func placeBid(_ amount: Int) {
        guard let auction = selectedAuction else { return }

        Task {
            do {
                let updatedAuction = try await useCase.placeBid(
                    auctionId: auction.id,
                    teamId: "team_mock", // TODO: Get actual team ID from user
                    teamName: "Mi Equipo", // TODO: Get actual team name
                    amount: amount
                )

                // Update the auction in the list
                if let index = activeAuctions.firstIndex(where: { $0.id == updatedAuction.id }) {
                    activeAuctions[index] = updatedAuction
                }

                router.showToastWithCloseAction(with: "¡Oferta realizada!", closeAction: {})
                showBidSheet = false
                selectedAuction = nil
            } catch let error as AuctionError {
                router.showAlert(with: AppError.customError(error.errorDescription ?? "Error", nil), action: {})
            } catch {
                router.showAlert(with: AppError.customError(error.localizedDescription, nil), action: {})
            }
        }
    }
}
