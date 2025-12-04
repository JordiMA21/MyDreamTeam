import SwiftUI

struct PlayerTeamView: View {
    @StateObject var viewModel: PlayerTeamViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.blue)
            } else {
                VStack(spacing: 0) {
                    // Tab Selector
                    tabSelectorView()

                    // Tab Content
                    tabContentView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mi Equipo")
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
        .onAppear {
            viewModel.loadLineupData()
        }
    }

    // MARK: - Tab Selector
    @ViewBuilder
    private func tabSelectorView() -> some View {
        HStack(spacing: 0) {
            // Field Tab
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.grid.1x2.fill")
                    Text("Campo")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(viewModel.selectedTab == .field ? .blue : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = .field
                    }
                }

                if viewModel.selectedTab == .field {
                    Divider()
                        .frame(height: 2)
                        .background(Color.blue)
                }
            }

            // Roster Tab
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                    Text("Plantilla")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(viewModel.selectedTab == .roster ? .blue : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = .roster
                    }
                }

                if viewModel.selectedTab == .roster {
                    Divider()
                        .frame(height: 2)
                        .background(Color.blue)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.02))
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }

    // MARK: - Tab Content
    @ViewBuilder
    private func tabContentView() -> some View {
        switch viewModel.selectedTab {
        case .field:
            fieldTabView()
        case .roster:
            rosterTabView()
        }
    }

    // MARK: - Field Tab
    @ViewBuilder
    private func fieldTabView() -> some View {
        // Use LineupView for field editing
        let router = LineupRouter()
        let lineupUseCase = LineupUseCase(repository: LineupLocalRepository())
        let teamUseCase = TeamDetailContainer.makeUseCase()
        let lineupViewModel = LineupViewModel(
            router: router,
            lineupUseCase: lineupUseCase,
            teamUseCase: teamUseCase,
            teamId: viewModel.teamId
        )

        LineupView(viewModel: lineupViewModel)
    }

    // MARK: - Roster Tab
    @ViewBuilder
    private func rosterTabView() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Goalkeepers
                if !viewModel.getPlayersByPosition(.goalkeeper).isEmpty {
                    PlayerPositionListSection(
                        position: .goalkeeper,
                        players: viewModel.getPlayersByPosition(.goalkeeper),
                        onPlayerTap: { player in
                            viewModel.didSelectPlayer(player)
                        }
                    )
                }

                // Defenders
                if !viewModel.getPlayersByPosition(.defender).isEmpty {
                    PlayerPositionListSection(
                        position: .defender,
                        players: viewModel.getPlayersByPosition(.defender),
                        onPlayerTap: { player in
                            viewModel.didSelectPlayer(player)
                        }
                    )
                }

                // Midfielders
                if !viewModel.getPlayersByPosition(.midfielder).isEmpty {
                    PlayerPositionListSection(
                        position: .midfielder,
                        players: viewModel.getPlayersByPosition(.midfielder),
                        onPlayerTap: { player in
                            viewModel.didSelectPlayer(player)
                        }
                    )
                }

                // Forwards
                if !viewModel.getPlayersByPosition(.forward).isEmpty {
                    PlayerPositionListSection(
                        position: .forward,
                        players: viewModel.getPlayersByPosition(.forward),
                        onPlayerTap: { player in
                            viewModel.didSelectPlayer(player)
                        }
                    )
                }

                if viewModel.lineup.slots.filter({ $0.player != nil }).isEmpty {
                    emptyStateView()
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
    }


    // MARK: - Empty State
    @ViewBuilder
    private func emptyStateView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.slash.circle")
                .font(.system(size: 48))
                .foregroundStyle(.gray)

            VStack(spacing: 8) {
                Text("Sin Jugadores")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Tu equipo está vacío. Crea una alineación para comenzar.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

#Preview {
    NavigationStack {
        PlayerTeamView(
            viewModel: PlayerTeamViewModel(
                router: PlayerTeamRouter(),
                lineupUseCase: LineupUseCase(repository: LineupLocalRepository()),
                teamId: 1
            )
        )
    }
}
