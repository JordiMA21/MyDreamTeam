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

            // Content Area
            contentArea
                .frame(maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(edges: .top)
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
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 60)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoggedIn {
            loggedInContent
        } else {
            loggedOutContent
        }
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

    private var loggedInContent: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Leagues List")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
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
        case 1: return "person.3.fill"
        case 2: return "trophy.fill"
        default: return "questionmark"
        }
    }

    private func title(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Players"
        case 2: return "Leagues"
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
