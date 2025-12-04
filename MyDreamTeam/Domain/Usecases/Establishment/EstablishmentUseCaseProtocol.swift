//
//  EstablishmentUseCaseProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 17/10/24.
//

import Foundation

protocol EstablishmentUseCaseProtocol {
    func isListedByCity() async throws -> Bool
    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [City]
    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [Establishment]
}
