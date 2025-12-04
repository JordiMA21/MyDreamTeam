import SwiftUI

struct DebugView: View {
    @State private var isLoading = false
    @State private var message: String = ""
    @State private var showMessage = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔧 Debug Menu")
                    .font(.title)
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    Button(action: seedData) {
                        HStack {
                            Image(systemName: "sprout.fill")
                            Text("Seed Firestore Data")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading)

                    if isLoading {
                        HStack {
                            ProgressView()
                                .tint(.blue)
                            Text("Cargando...")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if showMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: message.contains("✅") ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundStyle(message.contains("✅") ? .green : .red)
                                Text(message)
                                    .foregroundStyle(.white)
                                    .font(.caption)
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()

                Divider()
                    .background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Información")
                        .font(.headline)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Este menú agrega datos de ejemplo a Firestore:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("✅ 6 equipos (La Liga, Premier League)")
                        Text("✅ 8 jugadores con estadísticas")
                        Text("✅ Posiciones: GK, DEF, MID, FWD")
                        Text("✅ Diferentes ligas y países")

                        Spacer()
                            .frame(height: 8)

                        Text("Después de ejecutar puedes:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("1. Buscar jugadores en PlayerSelection")
                        Text("2. Crear un equipo fantasy")
                        Text("3. Ver estadísticas en tiempo real")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Debug")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func seedData() {
        isLoading = true
        showMessage = false

        Task {
            do {
                try await SeedDataManager.shared.seedAllData()
                message = "✅ Datos cargados exitosamente"
                showMessage = true
                isLoading = false
            } catch {
                message = "❌ Error: \(error.localizedDescription)"
                showMessage = true
                isLoading = false
            }
        }
    }
}

#Preview {
    DebugView()
}
