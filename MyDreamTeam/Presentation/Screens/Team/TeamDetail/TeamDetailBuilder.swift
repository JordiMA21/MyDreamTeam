import Foundation

enum TeamDetailBuilder {
    static func build(teamId: Int) -> TeamDetailView {
        let useCase = TeamDetailContainer.makeUseCase()
        let router = TeamDetailRouter()
        let viewModel = TeamDetailViewModel(router: router, teamUseCase: useCase, teamId: teamId)
        let view = TeamDetailView(viewModel: viewModel)
        return view
    }
}
