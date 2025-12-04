import Foundation

struct MockLineupData {
    static let sampleLineup: Lineup = {
        var lineup = Lineup(id: 1, teamId: 1)

        // Usar formación 4-3-3 (2 delanteros y portero)
        lineup.updateFormation(.formation_1_4_3_3)

        return lineup
    }()
}
