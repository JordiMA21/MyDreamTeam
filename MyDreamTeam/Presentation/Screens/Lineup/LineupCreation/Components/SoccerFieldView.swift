import SwiftUI

struct SoccerFieldView: View {
    let formation: FormationType
    let slots: [LineupSlot]
    let onSlotTap: (Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Field background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.5, blue: 0.1),
                        Color(red: 0.2, green: 0.6, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Canvas { context, _  in
                    // Field lines
                    drawFieldLines(context, size: geometry.size)
                }

                // Slots
                ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                    let position = FormationManager.getSlotPosition(
                        for: index,
                        formation: formation,
                        fieldSize: geometry.size
                    )

                    VStack {
                        FormationSlotView(slot: slot) {
                            onSlotTap(index)
                        }
                    }
                    .position(position)
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .aspectRatio(9/16, contentMode: .fit)
    }

    private func drawFieldLines(_ context: GraphicsContext, size: CGSize) {
        var path = Path()

        // Perimeter
        path.addRect(CGRect(origin: .zero, size: size))

        // Center line
        path.move(to: CGPoint(x: size.width / 2, y: 0))
        path.addLine(to: CGPoint(x: size.width / 2, y: size.height))

        // Center circle
        let centerCircle = Circle()
            .path(in: CGRect(
                x: size.width / 2 - 30,
                y: size.height / 2 - 30,
                width: 60,
                height: 60
            ))
        path.addPath(centerCircle)

        // Center spot
        path.addEllipse(in: CGRect(
            x: size.width / 2 - 3,
            y: size.height / 2 - 3,
            width: 6,
            height: 6
        ))

        // Goal areas (top)
        path.addRect(CGRect(x: size.width * 0.2, y: 0, width: size.width * 0.6, height: size.height * 0.15))
        path.addRect(CGRect(x: size.width * 0.3, y: 0, width: size.width * 0.4, height: size.height * 0.08))

        // Goal areas (bottom)
        path.addRect(CGRect(x: size.width * 0.2, y: size.height * 0.85, width: size.width * 0.6, height: size.height * 0.15))
        path.addRect(CGRect(x: size.width * 0.3, y: size.height * 0.92, width: size.width * 0.4, height: size.height * 0.08))

        context.stroke(
            path,
            with: .color(Color.white.opacity(0.7)),
            lineWidth: 2
        )
    }
}

struct FormationSlotView: View {
    let slot: LineupSlot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                if let player = slot.player {
                    // Jugador asignado
                    Text(slot.displayNumber)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)

                    Text(player.name.split(separator: " ").first.map(String.init) ?? "")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                } else {
                    // Slot vacío
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(width: 52, height: 52)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                FormationManager.getPositionColor(for: slot.position).opacity(0.8),
                                FormationManager.getPositionColor(for: slot.position).opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
            )
        }
    }
}

#Preview {
    let mockSlots = [
        LineupSlot(id: 0, position: .goalkeeper, player: nil, slotIndex: 0),
        LineupSlot(id: 1, position: .defender, player: nil, slotIndex: 1),
        LineupSlot(id: 2, position: .defender, player: nil, slotIndex: 2),
        LineupSlot(id: 3, position: .defender, player: nil, slotIndex: 3),
        LineupSlot(id: 4, position: .defender, player: nil, slotIndex: 4),
        LineupSlot(id: 5, position: .midfielder, player: nil, slotIndex: 5),
        LineupSlot(id: 6, position: .midfielder, player: nil, slotIndex: 6),
        LineupSlot(id: 7, position: .midfielder, player: nil, slotIndex: 7),
        LineupSlot(id: 8, position: .midfielder, player: nil, slotIndex: 8),
        LineupSlot(id: 9, position: .forward, player: nil, slotIndex: 9),
        LineupSlot(id: 10, position: .forward, player: nil, slotIndex: 10)
    ]

    SoccerFieldView(formation: .formation_1_4_4_2, slots: mockSlots, onSlotTap: { _ in })
        .padding()
        .background(Color(red: 0.05, green: 0.05, blue: 0.15))
}
