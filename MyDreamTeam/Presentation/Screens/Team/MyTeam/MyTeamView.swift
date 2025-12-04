//
//  MyTeamView.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - My Team View

struct MyTeamView: View {
    @StateObject private var viewModel: MyTeamViewModel

    init(viewModel: MyTeamViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

            // Content Area
            contentArea
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mi Equipo")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("Gestiona tu alineación y plantilla")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        VStack(spacing: 16) {
            Spacer()

            // Players List Button
            Button(action: {
                viewModel.didTapPlayersList()
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)

                    VStack(spacing: 4) {
                        Text("Plantilla")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Ver lista de jugadores de tu equipo")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }

            // Lineup Button
            Button(action: {
                viewModel.didTapLineup()
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.grid.1x2.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)

                    VStack(spacing: 4) {
                        Text("Alineación")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Visualiza tu equipo en el campo")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }

            Spacer()

            // Team Stats Card
            teamStatsCard

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Team Stats Card

    private var teamStatsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estadísticas del Equipo")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text("Plantilla 2024/25")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }

            Divider()

            HStack(spacing: 16) {
                StatItem(
                    label: "Porteros",
                    value: "1",
                    color: .purple
                )

                StatItem(
                    label: "Defensas",
                    value: "4",
                    color: .red
                )

                StatItem(
                    label: "Mediocampistas",
                    value: "4",
                    color: .yellow
                )

                StatItem(
                    label: "Delanteros",
                    value: "2",
                    color: .green
                )
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let router = MyTeamRouter()
    let viewModel = MyTeamViewModel(router: router)
    return MyTeamView(viewModel: viewModel)
}
