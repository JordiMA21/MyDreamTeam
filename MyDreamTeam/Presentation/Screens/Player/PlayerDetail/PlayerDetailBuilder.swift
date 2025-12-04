import Foundation

class PlayerDetailBuilder {
    func build(playerId: Int) -> PlayerDetailView {
        let useCase = PlayerDetailContainer.makeUseCase()
        let router = PlayerDetailRouter()
        let viewModel = PlayerDetailViewModel(router: router, playerUseCase: useCase, playerId: playerId)
        let view = PlayerDetailView(viewModel: viewModel)
        return view
    }
}
