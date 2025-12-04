import Foundation

enum FormationPosition: String, Codable {
    case goalkeeper = "Portero"
    case defender = "Defensa"
    case midfielder = "Centrocampista"
    case forward = "Delantero"
}

enum FormationType: String, Codable, CaseIterable {
    case formation_1_4_4_2 = "1-4-4-2"
    case formation_1_4_3_3 = "1-4-3-3"
    case formation_1_3_5_2 = "1-3-5-2"
    case formation_1_5_3_1 = "1-5-3-1"

    var displayName: String {
        self.rawValue
    }

    var positions: [FormationPosition] {
        switch self {
        case .formation_1_4_4_2:
            return [.goalkeeper, .defender, .defender, .defender, .defender,
                    .midfielder, .midfielder, .midfielder, .midfielder,
                    .forward, .forward]
        case .formation_1_4_3_3:
            return [.goalkeeper, .defender, .defender, .defender, .defender,
                    .midfielder, .midfielder, .midfielder,
                    .forward, .forward, .forward]
        case .formation_1_3_5_2:
            return [.goalkeeper, .defender, .defender, .defender,
                    .midfielder, .midfielder, .midfielder, .midfielder, .midfielder,
                    .forward, .forward]
        case .formation_1_5_3_1:
            return [.goalkeeper, .defender, .defender, .defender, .defender, .defender,
                    .midfielder, .midfielder, .midfielder,
                    .forward]
        }
    }

    var slotCoordinates: [(x: CGFloat, y: CGFloat)] {
        switch self {
        case .formation_1_4_4_2:
            // GK, 4 DEF, 4 MID, 2 FWD
            return [
                (0.5, 0.95),   // GK
                (0.15, 0.75), (0.35, 0.75), (0.65, 0.75), (0.85, 0.75),  // DEF
                (0.15, 0.50), (0.35, 0.50), (0.65, 0.50), (0.85, 0.50),  // MID
                (0.35, 0.25), (0.65, 0.25)   // FWD
            ]
        case .formation_1_4_3_3:
            return [
                (0.5, 0.95),   // GK
                (0.15, 0.75), (0.35, 0.75), (0.65, 0.75), (0.85, 0.75),  // DEF
                (0.25, 0.50), (0.5, 0.50), (0.75, 0.50),                  // MID
                (0.20, 0.25), (0.5, 0.15), (0.80, 0.25)                    // FWD
            ]
        case .formation_1_3_5_2:
            return [
                (0.5, 0.95),   // GK
                (0.25, 0.75), (0.5, 0.75), (0.75, 0.75),                  // DEF
                (0.10, 0.50), (0.30, 0.50), (0.5, 0.50), (0.70, 0.50), (0.90, 0.50),  // MID
                (0.35, 0.25), (0.65, 0.25)   // FWD
            ]
        case .formation_1_5_3_1:
            return [
                (0.5, 0.95),   // GK
                (0.10, 0.75), (0.30, 0.75), (0.5, 0.75), (0.70, 0.75), (0.90, 0.75),  // DEF
                (0.25, 0.50), (0.5, 0.50), (0.75, 0.50),                  // MID
                (0.5, 0.20)    // FWD
            ]
        }
    }
}
