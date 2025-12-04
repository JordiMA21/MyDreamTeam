import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    InfoRow(label: "Entrenador", value: "Gerardo Martino")
        .padding()
        .background(Color(red: 0.05, green: 0.05, blue: 0.15))
}
