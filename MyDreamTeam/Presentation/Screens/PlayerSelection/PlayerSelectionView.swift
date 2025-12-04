import SwiftUI

struct PlayerSelectionView: View {
    @StateObject var viewModel: PlayerSelectionViewModel
    @State private var showBudgetInfo = false

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
            } else {
                VStack(spacing: 0) {
                    // Budget Bar
                    budgetBarView()
                        .padding(16)
                        .background(Color.white.opacity(0.05))

                    // Position Filter
                    positionFilterView()
                        .padding(16)
                        .background(Color.white.opacity(0.02))

                    // Search Bar
                    searchBarView()
                        .padding(16)

                    // Players List
                    playersListView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Seleccionar Jugadores")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showBudgetInfo.toggle()
                }) {
                    Image(systemName: "info.circle")
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
        .onAppear {
            viewModel.loadPlayersByPosition()
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.applyFilters()
        }
    }

    // MARK: - Budget Bar View

    @ViewBuilder
    private func budgetBarView() -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Presupuesto")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("€\(String(format: "%.1f", viewModel.remainingBudget)) / €100.0")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Gastado")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("€\(String(format: "%.1f", viewModel.totalBudgetSpent))")
                        .font(.headline)
                        .foregroundStyle(viewModel.remainingBudget >= 0 ? .green : .red)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (viewModel.budgetPercentage / 100))
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Position Filter View

    @ViewBuilder
    private func positionFilterView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Posición")
                .font(.caption)
                .foregroundStyle(.secondary)
                .uppercase()

            HStack(spacing: 8) {
                ForEach(["GK", "DEF", "MID", "FWD"], id: \.self) { position in
                    Button(action: {
                        viewModel.changePosition(position)
                    }) {
                        Text(position)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(viewModel.selectedPosition == position ? Color.blue : Color.white.opacity(0.1))
                            .foregroundStyle(viewModel.selectedPosition == position ? .white : .secondary)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    // MARK: - Search Bar View

    @ViewBuilder
    private func searchBarView() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Buscar jugador...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Players List View

    @ViewBuilder
    private func playersListView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                if viewModel.filteredPlayers.isEmpty {
                    emptyStateView()
                } else {
                    ForEach(viewModel.filteredPlayers) { player in
                        playerRowView(player)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Player Row View

    @ViewBuilder
    private func playerRowView(_ player: PlayerEntity) -> some View {
        PlayerCardView(
            player: player,
            isSelected: viewModel.isPlayerSelected(player),
            onTap: {
                if viewModel.isPlayerSelected(player) {
                    viewModel.removePlayerFromSquad(player)
                } else {
                    viewModel.addPlayerToSquad(player)
                }
            },
            onCompare: viewModel.selectedPlayers.count > 0 && !viewModel.isPlayerSelected(player) ? {
                viewModel.compareWithPlayer(player)
            } : nil
        )
    }

    // MARK: - Empty State View

    @ViewBuilder
    private func emptyStateView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No hay jugadores disponibles")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Intenta cambiar de posición o refina tu búsqueda")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
