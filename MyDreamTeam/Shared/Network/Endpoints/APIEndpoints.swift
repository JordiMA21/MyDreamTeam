//
//  APIEndpoints.swift
//  iOSTemplate
//
//  Created by AUTHOR_NAME on DATE
//  Copyright © YEAR AUTHOR_NAME. All rights reserved.
//

import Foundation

// MARK: - Example Endpoints

/// Endpoints para usuarios (ejemplo)
enum UserEndpoint: Endpoint {
    case list(page: Int = 1)
    case detail(id: Int)
    case create(name: String, email: String)
    case update(id: Int, name: String, email: String)
    case delete(id: Int)

    var path: String {
        switch self {
        case .list:
            return "/users"
        case let .detail(id):
            return "/users/\(id)"
        case .create:
            return "/users"
        case let .update(id, _, _):
            return "/users/\(id)"
        case let .delete(id):
            return "/users/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .detail:
            return .get
        case .create:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .list:
            return nil // Los parámetros van en queryParameters
        case .detail:
            return nil
        case let .create(name, email):
            return [
                "name": name,
                "email": email
            ]
        case let .update(_, name, email):
            return [
                "name": name,
                "email": email
            ]
        case .delete:
            return nil
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .list(page):
            return ["page": String(page)]
        default:
            return nil
        }
    }
}

/// Endpoints para establecimientos (ejemplo de TripleA)
enum EstablishmentEndpoint: Endpoint {
    case list(city: String? = nil)
    case detail(id: Int)
    case nearby(latitude: Double, longitude: Double, radius: Int = 5)

    var path: String {
        switch self {
        case .list:
            return "/establishments"
        case let .detail(id):
            return "/establishments/\(id)"
        case .nearby:
            return "/establishments/nearby"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: [String: Any]? {
        return nil
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .list(city):
            return city.map { ["city": $0] }
        case let .nearby(lat, lon, radius):
            return [
                "latitude": String(lat),
                "longitude": String(lon),
                "radius": String(radius)
            ]
        default:
            return nil
        }
    }
}

/// Endpoints para productos (ejemplo)
enum ProductEndpoint: Endpoint {
    case list(category: String? = nil, limit: Int = 10)
    case detail(id: Int)
    case search(query: String)

    var path: String {
        switch self {
        case .list:
            return "/products"
        case let .detail(id):
            return "/products/\(id)"
        case .search:
            return "/products/search"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: [String: Any]? {
        return nil
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .list(category, limit):
            var params = ["limit": String(limit)]
            if let category = category {
                params["category"] = category
            }
            return params
        case let .search(query):
            return ["q": query]
        default:
            return nil
        }
    }
}

// MARK: - DTOs (Data Transfer Objects)

struct UserDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatar: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatar
        case createdAt = "created_at"
    }
}

struct EstablishmentDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let latitude: Double
    let longitude: Double
    let city: String
    let address: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case latitude
        case longitude
        case city
        case address
        case imageUrl = "image_url"
    }
}

struct ProductDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let price: Double
    let category: String?
    let imageUrl: String?
    let inStock: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case category
        case imageUrl = "image_url"
        case inStock = "in_stock"
    }
}

// MARK: - Generic Response

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct APIListResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: [T]?
    let pagination: PaginationInfo?
    let message: String?
    let error: String?
}

struct PaginationInfo: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let pages: Int
}
