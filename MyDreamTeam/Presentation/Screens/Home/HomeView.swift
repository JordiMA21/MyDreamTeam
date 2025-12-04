//
//  HomeView.swift
//  MyDreamTeam
//
//  Created by Claude Code on 4/12/25.
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Environment(SelectedLeagueManager.self) var leagueManager

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            if viewModel.isLoggedIn {
                loggedInContent
            } else {
                loggedOutContent
            }
        }
        .onAppear {
            viewModel.setupLeagueManager()
        }
    }

    // MARK: - Logged In Content

    private var loggedInContent: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navBar

            // League Selector
            leagueSelectorBar

            // TabView
            TabView(selection: $viewModel.selectedTab) {
                // Tab 0: Inicio
                homeTabContent
                    .tabItem {
                        Label("Inicio", systemImage: "house.fill")
                    }
                    .tag(0)

                // Tab 1: Mi Equipo
                MyTeamBuilder.build()
                    .tabItem {
                        Label("Mi Equipo", systemImage: "rectangle.grid.1x2.fill")
                    }
                    .tag(1)

                // Tab 2: Clasificación
                ClassificationBuilder.build()
                    .tabItem {
                        Label("Clasificación", systemImage: "list.number")
                    }
                    .tag(2)

                // Tab 3: Subastas
                AuctionMarketBuilder.build(leagueId: leagueManager.selectedLeagueId)
                    .tabItem {
                        Label("Subastas", systemImage: "gavel.fill")
                    }
                    .tag(3)
            }
        }
    }

    // MARK: - Logged Out Content

    private var loggedOutContent: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)

            Text("Welcome to MyDreamTeam")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)

            Text("Build your fantasy team and compete with friends")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)

            // Login Button
            Button(action: {
                viewModel.didTapLogin()
            }) {
                Text("Login")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            // Sign Up Button
            Button(action: {
                viewModel.didTapSignUp()
            }) {
                Text("Sign Up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .top) {
            navBar
        }
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        ZStack {
            Color.blue

            HStack {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)

                Text("MyDreamTeam")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // Login/Logout Toggle
                HStack(spacing: 8) {
                    Text(viewModel.isLoggedIn ? "Logout" : "Login")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)

                    Toggle("", isOn: $viewModel.isLoggedIn)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .frame(width: 50)
                        .onChange(of: viewModel.isLoggedIn) { _, _ in
                            viewModel.toggleLoginStatus()
                        }
                        .scaleEffect(0.8, anchor: .center)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 60)
    }

    // MARK: - League Selector Bar

    private var leagueSelectorBar: some View {
        VStack(spacing: 12) {
            Menu {
                ForEach(viewModel.userLeagues) { league in
                    Button(action: {
                        leagueManager.selectLeague(league)
                    }) {
                        HStack {
                            Text(league.name)
                            if leagueManager.selectedLeagueId == league.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Liga Actual")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        if let league = leagueManager.selectedLeague {
                            Text(league.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Posición")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)

                            if let league = leagueManager.selectedLeague {
                                Text("#\(league.rank)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Home Tab Content

    private var homeTabContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Mi Liga")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                if let league = leagueManager.selectedLeague {
                    Text("\(league.members) miembros - \(league.points) puntos")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // League Info Cards
            ScrollView {
                VStack(spacing: 16) {
                    if let league = leagueManager.selectedLeague {
                        // Stats Card
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tu Posición")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)

                                    Text("#\(league.rank)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.blue)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Puntos")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)

                                    Text("\(league.points)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.green)
                                }
                            }

                            Divider()

                            HStack(spacing: 16) {
                                VStack(alignment: .center, spacing: 6) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)

                                    Text("\(league.members)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text("Miembros")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)

                                Divider()
                                    .frame(height: 40)

                                VStack(alignment: .center, spacing: 6) {
                                    Image(systemName: "gavel.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)

                                    Text("8")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text("Subastas")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#Preview {
    let router = HomeRouter()
    let viewModel = HomeViewModel(router: router)
    return HomeView(viewModel: viewModel)
        .environment(SelectedLeagueManager.shared)
}
