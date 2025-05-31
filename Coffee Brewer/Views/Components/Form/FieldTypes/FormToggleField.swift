import SwiftUI

struct FormToggleField: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        FormField {
            FormPlaceholderText(value: title)
            Spacer()
            FormValueText(value: selectedOption)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            cycleToNextOption()
        }
    }
    
    private func cycleToNextOption() {
        guard let currentIndex = options.firstIndex(of: selectedOption) else {
            // If current selection not found, set to first option
            if !options.isEmpty {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedOption = options[0]
                }
            }
            return
        }
        
        // Calculate next index (wrap around to 0 if at end)
        let nextIndex = (currentIndex + 1) % options.count
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedOption = options[nextIndex]
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    VStack {
        FormToggleField(
            title: "Type",
            options: ["Manual", "Electric"],
            selectedOption: .constant("Manual")
        )
        
        FormToggleField(
            title: "Size",
            options: ["Small", "Medium", "Large", "Extra Large"],
            selectedOption: .constant("Medium")
        )
    }
    .padding()
    .background(BrewerColors.background)
}
