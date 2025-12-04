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

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navBar

            // Content Area based on selected tab
            tabContent
                .frame(maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
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
            .background(.blue)
            .padding(.horizontal, 20)
        .frame(height: 60)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        if viewModel.isLoggedIn {
            switch viewModel.selectedTab {
            case 0:
                homeTabContent
            case 1:
                MyTeamBuilder.build()
            case 2:
                PlayersBuilder.build()
            case 3:
                leaguesTabContent
            default:
                homeTabContent
            }
        } else {
            loggedOutContent
        }
    }

    private var homeTabContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("My Leagues")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("\(viewModel.userLeagues.count) active leagues")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // Leagues List
            if viewModel.userLeagues.isEmpty {
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "list.bullet")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("No Leagues")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("Join or create a league to get started")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.userLeagues) { league in
                            leagueCard(league)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private var leaguesTabContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Mis Ligas")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("Accede al mercado de subastas")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // Leagues List
            if viewModel.userLeagues.isEmpty {
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("Sin Ligas")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("Únete a una liga para acceder al mercado")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.userLeagues) { league in
                            leagueAuctionCard(league)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func leagueAuctionCard(_ league: League) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(league.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text("\(league.members) miembros")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "gavel.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("8 subastas")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        Text("#\(league.rank)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Text("posición")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 4)

            Button(action: {
                viewModel.didSelectLeagueForAuction(league)
            }) {
                HStack {
                    Image(systemName: "gavel.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Ir al Mercado de Subastas")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

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
    }


    private func leagueCard(_ league: League) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(league.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text("\(league.members) members")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("Rank #\(league.rank)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        Text("\(league.points)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Text("points")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 4)

            HStack {
                Button(action: {}) {
                    Text("View")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                Button(action: {}) {
                    Text("Stats")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                tabBarItem(for: index)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func tabBarItem(for index: Int) -> some View {
        Button(action: {
            viewModel.didSelectTab(index)
        }) {
            VStack(spacing: 4) {
                Image(systemName: iconName(for: index))
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.selectedTab == index ? .blue : .gray)

                Text(title(for: index))
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.selectedTab == index ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper Methods

    private func iconName(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "rectangle.grid.1x2.fill"
        case 2: return "person.3.fill"
        case 3: return "trophy.fill"
        default: return "questionmark"
        }
    }

    private func title(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Mi Equipo"
        case 2: return "Jugadores"
        case 3: return "Ligas"
        default: return ""
        }
    }
}

// MARK: - Preview

#Preview {
    let router = HomeRouter()
    let viewModel = HomeViewModel(router: router)
    return HomeView(viewModel: viewModel)
}
