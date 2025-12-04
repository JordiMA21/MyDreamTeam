//
//  EstablishmentRemoteDataSourceProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 17/10/24.
//

import Foundation

protocol EstablishmentRemoteDataSourceProtocol {
    func getCities(serviceID: Int) async throws -> [CityDTO]
    func getCities(serviceID: Int, latitude: Double, longitude: Double) async throws -> [CityDTO]
    func getEstablishments(serviceID: Int) async throws -> [EstablishmentDTO]
    func getEstablishments(serviceID: Int, latitude: Double, longitude: Double) async throws -> [EstablishmentDTO]
    func isListedByCity() async throws -> Bool
}
