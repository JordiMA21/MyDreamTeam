import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("My Dream Team")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Welcome to your Football Team Manager")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { viewModel.openTeamDetail() }) {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text("Team Details")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Button(action: { viewModel.openPlayerDetail() }) {
                    HStack {
                        Image(systemName: "figure.soccer")
                        Text("Player Details")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Button(action: { viewModel.openLineup() }) {
                    HStack {
                        Image(systemName: "square.grid.2x2")
                        Text("Lineup Creation")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Button(action: { viewModel.openPlayerTeam() }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                        Text("Player Team View")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    HomeBuilder.build()
}
