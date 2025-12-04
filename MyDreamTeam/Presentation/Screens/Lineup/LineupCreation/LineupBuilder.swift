import Foundation

class LineupBuilder {
    func build(teamId: Int) -> LineupView {
        let useCase = LineupUseCase(repository: LineupLocalRepository())
        let teamUseCase = TeamDetailContainer.makeUseCase()
        let router = LineupRouter()
        let viewModel = LineupViewModel(
            router: router,
            lineupUseCase: useCase,
            teamUseCase: teamUseCase,
            teamId: teamId
        )
        let view = LineupView(viewModel: viewModel)
        return view
    }
}
