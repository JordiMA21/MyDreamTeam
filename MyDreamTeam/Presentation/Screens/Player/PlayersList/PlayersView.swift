//
//  PlayersView.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Players View

struct PlayersView: View {
    @StateObject private var viewModel: PlayersViewModel

    init(viewModel: PlayersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar

            // Players List
            playersList
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            TextField("Search players...", text: $viewModel.searchText)
                .font(.system(size: 16))
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }

    // MARK: - Players List

    @ViewBuilder
    private var playersList: some View {
        if viewModel.filteredPlayers.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.filteredPlayers) { player in
                        playerCard(player)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("No Players Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            if !viewModel.searchText.isEmpty {
                Text("Try adjusting your search")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else {
                Text("No players available")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func playerCard(_ player: Player) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Player Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(player.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text(player.position)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text(player.team)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(Int(player.fantasyPoints))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Text("points")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 4)

            HStack {
                Button(action: {
                    viewModel.didSelectPlayer(player)
                }) {
                    Text("View Profile")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {
                    viewModel.didAddPlayerToTeam(player)
                }) {
                    Text("Add to Team")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    let router = PlayersRouter()
    let viewModel = PlayersViewModel(router: router)
    return PlayersView(viewModel: viewModel)
}
