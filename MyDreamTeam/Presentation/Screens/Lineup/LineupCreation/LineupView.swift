import SwiftUI

struct LineupView: View {
    @StateObject var viewModel: LineupViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
            } else {
                VStack(spacing: 16) {
                    // Header with formation info
                    formationHeaderView()

                    // Soccer field with slots
                    SoccerFieldView(
                        formation: viewModel.lineup.formation,
                        slots: viewModel.lineup.slots
                    ) { slotIndex in
                        viewModel.openSlotForSelection(slotIndex)
                    }
                    .frame(maxHeight: 400)
                    .padding(.horizontal, 16)

                    // Stats bar
                    statsBarView()

                    // Formation selector (future: make switchable)
                    formationSelectorView()

                    // Save button
                    Button(action: {
                        viewModel.saveLineup()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Guardar Alineación")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .padding(.top, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mi Alineación")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    viewModel.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.blue)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $viewModel.showPlayerSelection) {
            if let slotIndex = viewModel.selectedSlotIndex {
                let slot = viewModel.lineup.slots[slotIndex]
                let filteredPlayers = viewModel.getFilteredPlayers()

                PlayerSelectionModal(
                    position: slot.position,
                    players: filteredPlayers,
                    onPlayerSelected: { player in
                        viewModel.assignPlayerToSlot(player, slotIndex: slotIndex)
                    },
                    onRemovePlayer: {
                        viewModel.removePlayerFromSlot(slotIndex)
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadLineupData()
        }
    }

    // MARK: - Formation Header
    @ViewBuilder
    private func formationHeaderView() -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Formación")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)

                    Text(viewModel.lineup.formation.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Completitud")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)

                    Text("\(viewModel.lineup.filledSlots)/\(viewModel.lineup.slots.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Stats Bar
    @ViewBuilder
    private func statsBarView() -> some View {
        HStack(spacing: 12) {
            StatBadge(
                title: "Porteros",
                count: viewModel.lineup.slots.filter { $0.position == .goalkeeper && !$0.isEmpty }.count,
                total: viewModel.lineup.slots.filter { $0.position == .goalkeeper }.count,
                color: .purple
            )

            StatBadge(
                title: "Defensas",
                count: viewModel.lineup.slots.filter { $0.position == .defender && !$0.isEmpty }.count,
                total: viewModel.lineup.slots.filter { $0.position == .defender }.count,
                color: .red
            )

            StatBadge(
                title: "Mediocampistas",
                count: viewModel.lineup.slots.filter { $0.position == .midfielder && !$0.isEmpty }.count,
                total: viewModel.lineup.slots.filter { $0.position == .midfielder }.count,
                color: .yellow
            )

            StatBadge(
                title: "Delanteros",
                count: viewModel.lineup.slots.filter { $0.position == .forward && !$0.isEmpty }.count,
                total: viewModel.lineup.slots.filter { $0.position == .forward }.count,
                color: .green
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Formation Selector
    @ViewBuilder
    private func formationSelectorView() -> some View {
        VStack(spacing: 8) {
            Text("Cambiar Formación")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FormationButton(
                        formation: .formation_1_4_4_2,
                        isSelected: viewModel.lineup.formation == .formation_1_4_4_2,
                        action: { viewModel.changeFormation(.formation_1_4_4_2) }
                    )
                    FormationButton(
                        formation: .formation_1_4_3_3,
                        isSelected: viewModel.lineup.formation == .formation_1_4_3_3,
                        action: { viewModel.changeFormation(.formation_1_4_3_3) }
                    )
                    FormationButton(
                        formation: .formation_1_3_5_2,
                        isSelected: viewModel.lineup.formation == .formation_1_3_5_2,
                        action: { viewModel.changeFormation(.formation_1_3_5_2) }
                    )
                    FormationButton(
                        formation: .formation_1_5_3_1,
                        isSelected: viewModel.lineup.formation == .formation_1_5_3_1,
                        action: { viewModel.changeFormation(.formation_1_5_3_1) }
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Supporting Views
struct StatBadge: View {
    let title: String
    let count: Int
    let total: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.gray)

            Text("\(count)/\(total)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FormationButton: View {
    let formation: FormationType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(formation.displayName)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.white.opacity(0.1))
                .foregroundStyle(isSelected ? Color.white : Color.gray)
                .cornerRadius(6)
        }
    }
}

#Preview {
    NavigationStack {
        LineupView(
            viewModel: LineupViewModel(
                router: LineupRouter(),
                lineupUseCase: LineupUseCase(repository: MockLineupRepository()),
                teamUseCase: TeamUseCase(repository: MockTeamRepository()),
                teamId: 1
            )
        )
    }
}

// Mock for preview
class MockLineupRepository: LineupRepositoryProtocol {
    func getLineup(teamId: Int) async throws -> Lineup {
        return Lineup(id: 1, teamId: teamId)
    }

    func saveLineup(_ lineup: Lineup) async throws {}
    func updateLineup(_ lineup: Lineup) async throws {}
    func deleteLineup(teamId: Int) async throws {}
}
