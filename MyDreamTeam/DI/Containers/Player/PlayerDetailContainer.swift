import Foundation

class PlayerDetailContainer {
    static func makeUseCase() -> PlayerUseCase {
        let errorHandler = ErrorHandlerManager()
        let network = Config.shared.network
        let dataSource = PlayerRemoteDataSource(network: network)
        let repository = PlayerRepository(dataSource: dataSource, errorHandler: errorHandler)
        return PlayerUseCase(repository: repository)
    }
}
