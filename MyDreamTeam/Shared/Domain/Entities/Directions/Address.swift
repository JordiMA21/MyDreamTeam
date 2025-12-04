//
//  Address.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 18/9/24.
//

import Foundation

struct Address: Equatable, Identifiable {
    var alias: String?
    var coordinates: Coordinates?
    var street: String
    var number: String
    var subpremise: String
    var postalCode: String
    var city: String
    var province: String?
    var placeID: String?
    var additionalInfo: String?
    var isDefault: Bool?
    var id: Int?

    var fullLocation: String {
        if let province {
            return "\(postalCode) \(city), \(province)"
        } else {
            return "\(postalCode) \(city)"
        }
    }

    var fullAddress: String {
        return "\(street), \(postalCode), \(city)"
    }

    var displayAlias: String {
        alias?.capitalized ?? ""
    }
}
