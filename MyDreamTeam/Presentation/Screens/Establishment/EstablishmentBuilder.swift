//
//  RestaurantsBuilder.swift
//  Gula
//
//  Created by María on 9/8/24.
//

import Foundation

class EstablishmentBuilder {
    func build(with service: ServiceType) -> EstablishmentView {
        let useCase = EstablishmentSelectionContainer.makeUseCase()
        let router = EstablishmentRouter()
        let viewModel = EstablishmentViewModel(router: router, establishmentUseCase: useCase, service: service)
        let view = EstablishmentView(viewModel: viewModel)
        return view
    }
}
