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

    @Published var isLoggedIn: Bool = false // Hardcoded for now, will be connected to Firebase later
    @Published var selectedTab: Int = 0

    // MARK: - Private Properties

    private let router: HomeRouter

    // MARK: - Initialization

    init(router: HomeRouter) {
        self.router = router
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
}
