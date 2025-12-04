//
//  EstablishmentRemoteDataSource.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 17/10/24.
//

import Foundation
import TripleA

class EstablishmentRemoteDataSource: EstablishmentRemoteDataSourceProtocol {
    let network: Network

    init(network: Network) {
        self.network = network
    }

    func getCities(serviceID: Int) async throws -> [CityDTO] {
        let query: [String: Any] = ["service_id": String(serviceID)]
        let endpoint = Endpoint(path: "api/restaurants",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint,
                                      of: [CityDTO].self)
    }

    func getCities(serviceID: Int,
                   latitude: Double,
                   longitude: Double) async throws -> [CityDTO] {
        let query: [String: Any] = ["service_id": serviceID,
                                    "lat": latitude,
                                    "long": longitude]
        let endpoint = Endpoint(path: "api/restaurants",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint,
                                      of: [CityDTO].self)
    }

    func getEstablishments(serviceID: Int) async throws -> [EstablishmentDTO] {
        let query: [String: Any] = ["service_id": serviceID]
        let endpoint = Endpoint(path: "api/restaurants",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint,
                                      of: [EstablishmentDTO].self)
    }

    func getEstablishments(serviceID: Int,
                           latitude: Double,
                           longitude: Double) async throws -> [EstablishmentDTO] {
        let query: [String: Any] = ["service_id": serviceID,
                                    "lat": latitude,
                                    "long": longitude]
        let endpoint = Endpoint(path: "api/restaurants",
                                httpMethod: .get,
                                query: query)
        return try await network.load(endpoint: endpoint,
                                      of: [EstablishmentDTO].self)
    }

    func isListedByCity() async throws -> Bool {
        let endpoint = Endpoint(path: "api/restaurants/verify_restaurants", httpMethod: .get)
        let listByCity = try await network.load(endpoint: endpoint, of: ListByCityDTO.self)
        return listByCity.isListedByCity
    }
}
