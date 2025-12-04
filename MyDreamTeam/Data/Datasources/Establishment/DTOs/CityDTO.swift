//
//  CityDTO.swift
//  Gula
//
//  Created by María on 13/8/24.
//

import Foundation

struct CityDTO: Codable {
    let id: Int
    let name: String
    let establishments: [EstablishmentDTO]

    enum CodingKeys: String,CodingKey {
        case id
        case name
        case establishments = "restaurants"
    }
}
