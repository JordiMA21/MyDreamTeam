import Foundation

struct LineupSlot: Identifiable, Equatable {
    let id: Int
    let position: FormationPosition
    var player: Player?
    let slotIndex: Int

    init(id: Int, position: FormationPosition, player: Player? = nil, slotIndex: Int) {
        self.id = id
        self.position = position
        self.player = player
        self.slotIndex = slotIndex
    }

    mutating func assignPlayer(_ player: Player) {
        self.player = player
    }

    mutating func removePlayer() {
        self.player = nil
    }

    var isEmpty: Bool {
        player == nil
    }

    var displayName: String {
        player?.name ?? "Vacío"
    }

    var displayNumber: String {
        player.map { "#\($0.number)" } ?? "+"
    }
}
