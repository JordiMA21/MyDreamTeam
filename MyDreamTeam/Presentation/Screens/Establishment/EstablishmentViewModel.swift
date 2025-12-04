//
//  RestaurantsViewModel.swift
//  Gula
//
//  Created by María on 9/8/24.
//

import Foundation

class EstablishmentViewModel: ObservableObject {
    // MARK: - Properties
    @Published var cities: [City] = []
    @Published var establishments: [Establishment] = []
    @Published var isListedByCity = true
    @Published var selectedEstablishment: Establishment?

    private let router: EstablishmentRouter
    private let establishmentUseCase: EstablishmentUseCaseProtocol
    private let service: ServiceType
    private var coordinates: Coordinates?

    init(router: EstablishmentRouter, establishmentUseCase: EstablishmentUseCaseProtocol, service: ServiceType) {
        self.router = router
        self.establishmentUseCase = establishmentUseCase
        self.service = service
    }

    // MARK: - Functions
    @MainActor
    func loadCitiesOrEstablishments() {
        Task {
            do {
                isListedByCity = try await establishmentUseCase.isListedByCity()
                if isListedByCity {
                    try await getCities(with: coordinates, and: service)
                } else {
                    try await getEstablishments(with: coordinates, and: service)
                }
            } catch  {
                router.showAlert(with: error)
            }
        }
    }

    @MainActor
    private func getCities(with coordinates: Coordinates?, and service: ServiceType) async throws {
        cities = try await establishmentUseCase.getCities(service: service,
                                                          coordinates: coordinates)
    }

    @MainActor
    private func getEstablishments(with coordinates: Coordinates?, and service: ServiceType) async throws {
        establishments = try await establishmentUseCase.getEstablishments(service: service,
                                                                          coordinates: coordinates)
    }
}

extension EstablishmentViewModel {
    func dismiss() {
        router.dismiss()
    }

    func navigateToEmptyView() {
        router.goToEmptyView()
    }
}
