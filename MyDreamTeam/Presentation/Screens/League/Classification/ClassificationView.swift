//
//  ClassificationView.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Classification View

struct ClassificationView: View {
    @StateObject private var viewModel: ClassificationViewModel
    @Environment(SelectedLeagueManager.self) var leagueManager

    init(viewModel: ClassificationViewModel) {
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
            viewModel.loadStandings(leagueId: leagueManager.selectedLeagueId)
        }
        .onChange(of: leagueManager.selectedLeagueId) { oldValue, newValue in
            viewModel.loadStandings(leagueId: newValue)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clasificación")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("\(viewModel.standings.count) equipos")
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
        } else if viewModel.standings.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    // Table Header
                    tableHeader

                    Divider()
                        .padding(.vertical, 8)

                    // Standings List
                    VStack(spacing: 8) {
                        ForEach(Array(viewModel.standings.enumerated()), id: \.element.id) { index, standing in
                            standingRow(standing, position: index + 1)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Table Header

    private var tableHeader: some View {
        HStack(spacing: 12) {
            Text("Pos")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 30)

            Text("Equipo")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 2) {
                Text("Pts")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .frame(width: 35)

            VStack(spacing: 2) {
                Text("J")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .frame(width: 25)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Standing Row

    private func standingRow(_ standing: Standing, position: Int) -> some View {
        HStack(spacing: 12) {
            // Position
            Text("\(position)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 30)

            // Team Name
            Text(standing.teamName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Points
            Text("\(standing.points)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)
                .frame(width: 35)

            // Matches
            Text("\(standing.matches)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 25)
        }
        .padding(12)
        .background(position % 2 == 0 ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(8)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "list.number")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Sin Clasificación")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Text("No hay datos de clasificación disponibles")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let router = ClassificationRouter()
    let viewModel = ClassificationViewModel(router: router)
    return ClassificationView(viewModel: viewModel)
        .environment(SelectedLeagueManager.shared)
}
