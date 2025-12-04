//
//  SelectedLeagueManager.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation
import Observation

// MARK: - Selected League Manager

@Observable
final class SelectedLeagueManager {
    static let shared = SelectedLeagueManager()

    var selectedLeagueId: String = "1" // Default to first league
    var selectedLeague: League? {
        didSet {
            if let league = selectedLeague {
                selectedLeagueId = league.id
            }
        }
    }

    private init() {}

    func selectLeague(_ league: League) {
        self.selectedLeague = league
        self.selectedLeagueId = league.id
    }

    func setDefaultLeague(_ leagues: [League]) {
        if let firstLeague = leagues.first {
            selectLeague(firstLeague)
        }
    }
}
