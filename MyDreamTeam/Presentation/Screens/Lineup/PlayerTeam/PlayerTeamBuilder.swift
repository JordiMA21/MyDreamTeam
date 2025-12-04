import SwiftUI

enum PlayerTeamBuilder {
    static func build(teamId: Int) -> some View {
        let router = PlayerTeamRouter()
        let lineupUseCase = LineupUseCase(
            repository: LineupLocalRepository()
        )
        let viewModel = PlayerTeamViewModel(
            router: router,
            lineupUseCase: lineupUseCase,
            teamId: teamId
        )
        return PlayerTeamView(viewModel: viewModel)
    }
}
