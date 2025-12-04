import SwiftUI

struct FormationManager {
    static func getSlotPosition(for slotIndex: Int, formation: FormationType, fieldSize: CGSize) -> CGPoint {
        let coordinates = formation.slotCoordinates[slotIndex]
        return CGPoint(
            x: coordinates.x * fieldSize.width,
            y: coordinates.y * fieldSize.height
        )
    }

    static func getPositionLabel(for position: FormationPosition) -> String {
        switch position {
        case .goalkeeper:
            return "PT"
        case .defender:
            return "D"
        case .midfielder:
            return "C"
        case .forward:
            return "F"
        }
    }

    static func getPositionColor(for position: FormationPosition) -> Color {
        switch position {
        case .goalkeeper:
            return Color.purple
        case .defender:
            return Color.red
        case .midfielder:
            return Color.yellow
        case .forward:
            return Color.green
        }
    }

    static func getFormationDescription(_ formation: FormationType) -> String {
        switch formation {
        case .formation_1_4_4_2:
            return "1 Portero, 4 Defensas, 4 Centrocampistas, 2 Delanteros"
        case .formation_1_4_3_3:
            return "1 Portero, 4 Defensas, 3 Centrocampistas, 3 Delanteros"
        case .formation_1_3_5_2:
            return "1 Portero, 3 Defensas, 5 Centrocampistas, 2 Delanteros"
        case .formation_1_5_3_1:
            return "1 Portero, 5 Defensas, 3 Centrocampistas, 1 Delantero"
        }
    }
}
