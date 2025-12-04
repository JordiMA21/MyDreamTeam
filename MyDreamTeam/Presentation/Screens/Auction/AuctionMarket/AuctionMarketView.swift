//
//  AuctionMarketView.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Auction Market View

struct AuctionMarketView: View {
    @StateObject private var viewModel: AuctionMarketViewModel

    init(viewModel: AuctionMarketViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            // Content Area
            contentArea
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.loadAuctions()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mercado de Subastas")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("\(viewModel.activeAuctions.count) subastas activas")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxHeight: .infinity)
        } else if viewModel.activeAuctions.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.activeAuctions) { auction in
                        auctionCard(auction)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "gavel.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Sin Subastas")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Text("No hay subastas activas en este momento")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Auction Card

    private func auctionCard(_ auction: Auction) -> some View {
        VStack(spacing: 12) {
            // Player Info
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(auction.playerName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text(auction.playerPosition)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text(auction.playerTeam)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Time remaining
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    Text("\(auction.minutesRemaining)m")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }

            Divider()

            // Bid Info
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Oferta Mínima")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("€\(formatNumber(auction.marketValue))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Oferta Actual")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("€\(formatNumber(auction.currentHighestBid))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                }

                // Highest bidder
                if let highestBid = auction.highestBidder {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)

                        Text(highestBid.teamName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("€\(formatNumber(highestBid.amount))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
            }

            Divider()

            // Action Section
            HStack(spacing: 10) {
                // Bid Button
                Button(action: {
                    viewModel.didTapBid(auction)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "gavel.fill")
                            .font(.system(size: 14))
                        Text("Pujar")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                // Info Button
                Button(action: {
                    viewModel.didTapInfo(auction)
                }) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Preview

#Preview {
    let router = AuctionMarketRouter()
    let repository = AuctionLocalRepository()
    let useCase = AuctionUseCase(repository: repository)
    let viewModel = AuctionMarketViewModel(router: router, useCase: useCase, leagueId: "1")
    return AuctionMarketView(viewModel: viewModel)
}
