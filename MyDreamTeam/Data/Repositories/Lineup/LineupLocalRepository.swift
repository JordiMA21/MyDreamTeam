import Foundation

class LineupLocalRepository: LineupRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let keyPrefix = "lineup_"

    func getLineup(teamId: Int) async throws -> Lineup {
        let key = "\(keyPrefix)\(teamId)"

        if let data = userDefaults.data(forKey: key) {
            let decoder = JSONDecoder()
            do {
                let lineup = try decoder.decode(LineupCodable.self, from: data)
                return lineup.toDomain()
            } catch {
                throw AppError.customError("Error al decodificar la alineación", nil)
            }
        }

        // Si no existe, crear una nueva
        return Lineup(id: teamId, teamId: teamId)
    }

    func saveLineup(_ lineup: Lineup) async throws {
        let key = "\(keyPrefix)\(lineup.teamId)"
        let encoder = JSONEncoder()

        do {
            let codable = LineupCodable.fromDomain(lineup)
            let data = try encoder.encode(codable)
            userDefaults.set(data, forKey: key)
        } catch {
            throw AppError.customError("Error al guardar la alineación", nil)
        }
    }

    func updateLineup(_ lineup: Lineup) async throws {
        try await saveLineup(lineup)
    }

    func deleteLineup(teamId: Int) async throws {
        let key = "\(keyPrefix)\(teamId)"
        userDefaults.removeObject(forKey: key)
    }
}

// MARK: - Codable Models
struct LineupCodable: Codable {
    let id: Int
    let teamId: Int
    let formationType: String
    let slots: [LineupSlotCodable]
    let createdDate: Date
    let lastModifiedDate: Date

    func toDomain() -> Lineup {
        var lineup = Lineup(id: id, teamId: teamId)

        if let formation = FormationType(rawValue: formationType) {
            lineup.formation = formation
        }

        lineup.slots = slots.map { $0.toDomain() }
        return lineup
    }

    static func fromDomain(_ lineup: Lineup) -> LineupCodable {
        return LineupCodable(
            id: lineup.id,
            teamId: lineup.teamId,
            formationType: lineup.formation.rawValue,
            slots: lineup.slots.map { LineupSlotCodable.fromDomain($0) },
            createdDate: lineup.createdDate,
            lastModifiedDate: lineup.lastModifiedDate
        )
    }
}

struct LineupSlotCodable: Codable {
    let id: Int
    let position: String
    let playerId: Int?
    let playerName: String?
    let slotIndex: Int

    func toDomain() -> LineupSlot {
        let slot = LineupSlot(
            id: id,
            position: FormationPosition(rawValue: position) ?? .goalkeeper,
            player: nil,
            slotIndex: slotIndex
        )
        return slot
    }

    static func fromDomain(_ slot: LineupSlot) -> LineupSlotCodable {
        return LineupSlotCodable(
            id: slot.id,
            position: slot.position.rawValue,
            playerId: slot.player?.id,
            playerName: slot.player?.name,
            slotIndex: slot.slotIndex
        )
    }
}
