import Foundation

struct Lineup: Identifiable, Equatable {
    let id: Int
    let teamId: Int
    var formation: FormationType
    var slots: [LineupSlot]
    let createdDate: Date
    var lastModifiedDate: Date

    init(id: Int, teamId: Int, formation: FormationType = .formation_1_4_4_2) {
        self.id = id
        self.teamId = teamId
        self.formation = formation
        self.slots = formation.positions.enumerated().map { index, position in
            LineupSlot(id: index, position: position, player: nil, slotIndex: index)
        }
        self.createdDate = Date()
        self.lastModifiedDate = Date()
    }

    mutating func updateFormation(_ newFormation: FormationType) {
        self.formation = newFormation
        // Preserve existing players if their positions match
        let oldSlots = self.slots
        self.slots = newFormation.positions.enumerated().map { index, position in
            let matchingPlayer = oldSlots.first { $0.position == position && !$0.isEmpty }?.player
            return LineupSlot(id: index, position: position, player: matchingPlayer, slotIndex: index)
        }
        self.lastModifiedDate = Date()
    }

    mutating func assignPlayerToSlot(_ player: Player, slotIndex: Int) {
        guard slotIndex < slots.count else { return }
        // Only assign if player position matches slot position
        if player.position.lowercased() == slots[slotIndex].position.rawValue.lowercased() ||
           canAssignPlayerToPosition(player, slots[slotIndex].position) {
            slots[slotIndex].assignPlayer(player)
            self.lastModifiedDate = Date()
        }
    }

    mutating func removePlayerFromSlot(_ slotIndex: Int) {
        guard slotIndex < slots.count else { return }
        slots[slotIndex].removePlayer()
        self.lastModifiedDate = Date()
    }

    private func canAssignPlayerToPosition(_ player: Player, _ position: FormationPosition) -> Bool {
        let playerPosition = player.position.lowercased()
        switch position {
        case .goalkeeper:
            return playerPosition == "portero"
        case .defender:
            return playerPosition == "defensa"
        case .midfielder:
            return playerPosition == "centrocampista"
        case .forward:
            return playerPosition == "delantero"
        }
    }

    var filledSlots: Int {
        slots.filter { !$0.isEmpty }.count
    }

    var isEmpty: Bool {
        filledSlots == 0
    }

    var isFull: Bool {
        filledSlots == slots.count
    }
}
