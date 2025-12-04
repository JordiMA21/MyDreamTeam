//
//  EstablishmentRepositoryProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 17/10/24.
//

import Foundation

protocol EstablishmentRepositoryProtocol {
    func getCities(serviceID: Int) async throws -> [City]
    func getCities(serviceID: Int, latitude: Double, longitude: Double) async throws -> [City]
    func getEstablishments(serviceID: Int) async throws -> [Establishment]
    func getEstablishments(serviceID: Int, latitude: Double, longitude: Double) async throws -> [Establishment]
    func isListedByCity() async throws -> Bool
}
