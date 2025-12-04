//
//  EstablishmentUseCase.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 17/10/24.
//

import Foundation

class EstablishmentUseCase: EstablishmentUseCaseProtocol {
    // MARK: - Properties
    private let repository: EstablishmentRepositoryProtocol

    // MARK: - Init
    init(repository: EstablishmentRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Functions
    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [City] {
        if service == .delivery, let coordinates {
            return try await repository.getCities(serviceID: service.rawValue,
                                                  latitude: coordinates.latitude,
                                                  longitude: coordinates.longitude)
        } else {
            return try await repository.getCities(serviceID: service.rawValue)
        }
    }

    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [Establishment] {
        if service == .delivery, let coordinates {
            return try await repository.getEstablishments(serviceID: service.rawValue,
                                                          latitude: coordinates.latitude,
                                                          longitude: coordinates.longitude)
        } else {
            return try await repository.getEstablishments(serviceID: service.rawValue)
        }
    }

    func isListedByCity() async throws -> Bool {
        try await repository.isListedByCity()
    }
}
