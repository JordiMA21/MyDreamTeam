//
//  UserRemoteDataSource.swift
//  iOSTemplate
//
//  Created by AUTHOR_NAME on DATE
//  Copyright © YEAR AUTHOR_NAME. All rights reserved.
//

import Foundation

/// Protocolo para acceso remoto a usuarios
protocol UserRemoteDataSourceProtocol {
    func getUsers(page: Int) async throws -> [UserDTO]
    func getUser(id: Int) async throws -> UserDTO
    func createUser(name: String, email: String) async throws -> UserDTO
    func updateUser(id: Int, name: String, email: String) async throws -> UserDTO
    func deleteUser(id: Int) async throws
}

/// Implementación de acceso remoto a usuarios usando Network (TripleA-inspired)
@available(iOS 13.0, *)
class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    // MARK: - Properties

    private let network: Network

    // MARK: - Init

    init(network: Network = Network.shared) {
        self.network = network
    }

    // MARK: - UserRemoteDataSourceProtocol

    func getUsers(page: Int) async throws -> [UserDTO] {
        let endpoint = UserEndpoint.list(page: page)
        let response: [UserDTO] = try await network.request(
            endpoint: endpoint,
            responseType: [UserDTO].self
        )
        return response
    }

    func getUser(id: Int) async throws -> UserDTO {
        let endpoint = UserEndpoint.detail(id: id)
        let response: UserDTO = try await network.request(
            endpoint: endpoint,
            responseType: UserDTO.self
        )
        return response
    }

    func createUser(name: String, email: String) async throws -> UserDTO {
        let endpoint = UserEndpoint.create(name: name, email: email)
        let response: UserDTO = try await network.request(
            endpoint: endpoint,
            responseType: UserDTO.self
        )
        return response
    }

    func updateUser(id: Int, name: String, email: String) async throws -> UserDTO {
        let endpoint = UserEndpoint.update(id: id, name: name, email: email)
        let response: UserDTO = try await network.request(
            endpoint: endpoint,
            responseType: UserDTO.self
        )
        return response
    }

    func deleteUser(id: Int) async throws {
        let endpoint = UserEndpoint.delete(id: id)
        try await network.requestVoid(endpoint: endpoint)
    }
}

// MARK: - Example Usage in Repository

/*
 Ejemplo de cómo usar UserRemoteDataSource en un Repository:

 class UserRepositoryImpl: UserRepository {
     private let remoteDatasource: UserRemoteDataSourceProtocol

     init(remoteDatasource: UserRemoteDataSourceProtocol) {
         self.remoteDatasource = remoteDatasource
     }

     func getUsers(page: Int) async throws -> [User] {
         let dtos = try await remoteDatasource.getUsers(page: page)
         return dtos.map { $0.toDomain() }
     }

     func getUser(id: Int) async throws -> User {
         let dto = try await remoteDatasource.getUser(id: id)
         return dto.toDomain()
     }
 }
 */
