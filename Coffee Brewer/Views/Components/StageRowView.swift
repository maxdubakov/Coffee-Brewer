import SwiftUI

// MARK: - Stage Row View

struct StageRowView: View {
    let stage: StageFormData
    let onToggleType: () -> Void
    let onUpdateWater: (Int16) -> Void
    let onDelete: () -> Void

    @State private var isEditingWater = false
    @State private var waterText = ""
    @FocusState private var waterFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Type badge — tap to toggle Fast ↔ Slow
            Button(action: onToggleType) {
                Text(stage.type.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(
                        stage.type == .fast ? BrewerColors.background : BrewerColors.textSecondary
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(stage.type == .fast ? BrewerColors.caramel : BrewerColors.textSecondary.opacity(0.3))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            // Water amount — tap to edit inline
            if isEditingWater {
                HStack(spacing: 2) {
                    TextField("", text: $waterText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 52)
                        .focused($waterFocused)
                        .onSubmit { commitWaterEdit() }
                        .onChange(of: waterFocused) { _, focused in
                            if !focused { commitWaterEdit() }
                        }
                    Text("ml")
                        .font(.system(size: 13))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                .onAppear {
                    waterText = "\(stage.waterAmount)"
                    waterFocused = true
                }
            } else {
                Button(action: {
                    waterText = "\(stage.waterAmount)"
                    isEditingWater = true
                }) {
                    Text("\(stage.waterAmount)ml")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                .buttonStyle(.plain)
            }

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func commitWaterEdit() {
        if let value = Int16(waterText), value > 0 {
            onUpdateWater(value)
        }
        isEditingWater = false
    }
}
