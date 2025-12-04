//
//  City.swift
//  Gula
//
//  Created by María on 13/8/24.
//

import Foundation

struct City: Identifiable {
    let id: Int
    let name: String
    let establishments: [Establishment]
}
