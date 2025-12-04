//
//  HomeViewModel.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import Foundation

// MARK: - Home ViewModel

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoggedIn: Bool = false // Toggle para simular login/logout
    @Published var selectedTab: Int = 0
    @Published var userLeagues: [League] = [] // Mock ligas del usuario

    // MARK: - Private Properties

    private let router: HomeRouter

    // MARK: - Initialization

    init(router: HomeRouter) {
        self.router = router
        setupMockData()
    }

    // MARK: - Public Methods

    func didTapLogin() {
        router.navigateToLogin()
    }

    func didTapSignUp() {
        router.navigateToSignUp()
    }

    func didSelectTab(_ index: Int) {
        selectedTab = index
    }

    func toggleLoginStatus() {
        isLoggedIn.toggle()
    }

    // MARK: - Private Methods

    private func setupMockData() {
        userLeagues = [
            League(id: "1", name: "Friends Fantasy League", members: 8, rank: 3, points: 850),
            League(id: "2", name: "Premier League Pro", members: 15, rank: 1, points: 920),
            League(id: "3", name: "Office Cup", members: 12, rank: 5, points: 760),
            League(id: "4", name: "Champions Only", members: 20, rank: 12, points: 680),
        ]
    }
}

// MARK: - Models

struct League: Identifiable {
    let id: String
    let name: String
    let members: Int
    let rank: Int
    let points: Int
}
