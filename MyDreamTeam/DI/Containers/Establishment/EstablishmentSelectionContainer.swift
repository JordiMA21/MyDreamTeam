//
//  EstablishmentSelectionContainer.swift
//  Gula
//
//  Created by Eduard on 6/8/25.
//

import Foundation

class EstablishmentSelectionContainer {
    static func makeUseCase() -> EstablishmentUseCase {
        let errorHandler = ErrorHandlerManager()
        let network = Config.shared.network
        let dataSource = EstablishmentRemoteDataSource(network: network)
        let repository = EstablishmentRepository(dataSource: dataSource, errorHandler: errorHandler)
        return EstablishmentUseCase(repository: repository)
    }
}
