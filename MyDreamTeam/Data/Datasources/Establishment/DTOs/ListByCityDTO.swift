//
//  ListByCityDTO.swift
//  Gula
//
//  Created by Jorge on 28/10/24.
//

import Foundation

struct ListByCityDTO: Codable {
    let isListedByCity: Bool

    enum CodingKeys: String, CodingKey {
        case isListedByCity = "list_by_city"
    }
}
