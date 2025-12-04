//
//  EstablishmentRepository.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 17/10/24.
//

import Foundation

class EstablishmentRepository: EstablishmentRepositoryProtocol {
    // MARK: - Properties
    private let dataSource: EstablishmentRemoteDataSourceProtocol
    private let errorHandler: ErrorHandlerProtocol

    // MARK: - Init
    init(dataSource: EstablishmentRemoteDataSourceProtocol, errorHandler: ErrorHandlerProtocol) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    // MARK: - Functions
    func getCities(serviceID: Int) async throws -> [City] {
        do {
            let responseDTO = try await dataSource.getCities(serviceID: serviceID)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getCities(serviceID: Int,
                   latitude: Double,
                   longitude: Double) async throws -> [City] {
        do {
            let responseDTO = try await dataSource.getCities(serviceID: serviceID,
                                                             latitude: latitude,
                                                             longitude: longitude)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getEstablishments(serviceID: Int) async throws -> [Establishment] {
        do {
            let responseDTO = try await dataSource.getEstablishments(serviceID: serviceID)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func getEstablishments(serviceID: Int,
                           latitude: Double,
                           longitude: Double) async throws -> [Establishment] {
        do {
            let responseDTO = try await dataSource.getEstablishments(serviceID: serviceID,
                                                                     latitude: latitude,
                                                                     longitude: longitude)
            return responseDTO.map { $0.toDomain() }
        } catch {
            throw errorHandler.handle(error)
        }
    }

    func isListedByCity() async throws -> Bool {
        do {
            return try await dataSource.isListedByCity()
        } catch {
            throw errorHandler.handle(error)
        }
    }
}

// MARK: - Mappers
fileprivate extension CityDTO {
    func toDomain() -> City {
        City(id: self.id,
             name: self.name,
             establishments: self.establishments.map { $0.toDomain()})
    }
}

fileprivate extension EstablishmentDTO {
    func toDomain() -> Establishment {
        Establishment(id: self.id,
                      name: self.name,
                      address: self.address,
                      image: self.image ?? "",
                      phone: self.phone)
    }
}
