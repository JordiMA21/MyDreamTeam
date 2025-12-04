import Foundation

enum PlayerSelectionBuilder {
    static func build(squadId: String, season: Int) -> PlayerSelectionView {
        let playerUseCase = PlayerContainer.shared.makeUseCase()
        let fantasyUseCase = FantasySquadContainer.shared.makeUseCase()
        let router = PlayerSelectionRouter()
        let viewModel = PlayerSelectionViewModel(
            router: router,
            playerUseCase: playerUseCase,
            fantasySortedUseCase: fantasyUseCase,
            squadId: squadId,
            season: season
        )
        return PlayerSelectionView(viewModel: viewModel)
    }
}
