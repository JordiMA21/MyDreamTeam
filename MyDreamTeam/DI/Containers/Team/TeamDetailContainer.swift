import Foundation

class TeamDetailContainer {
    static func makeUseCase() -> TeamUseCase {
        let errorHandler = ErrorHandlerManager()
        let network = Config.shared.network
        let dataSource = TeamRemoteDataSource(network: network)
        let repository = TeamRepository(dataSource: dataSource, errorHandler: errorHandler)
        return TeamUseCase(repository: repository)
    }
}
