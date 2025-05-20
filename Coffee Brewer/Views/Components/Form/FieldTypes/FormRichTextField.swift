import SwiftUI

struct FormRichTextField: View {
    // MARK: - Properties
    @Binding var notes: String
    var placeholder: String
    var minHeight: CGFloat = 120
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            // The actual TextEditor
            TextEditor(text: $notes)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: minHeight)
                .foregroundColor(BrewerColors.textPrimary)
                .font(.system(size: 16))
                .padding(.horizontal, 0) // Remove horizontal padding
                .padding(.vertical, 0)   // Remove vertical padding
            
            // Placeholder with precise positioning
            if notes.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.7))
                    .padding(.horizontal, 5) // Match TextEditor's internal padding
                    .padding(.vertical, 8)   // Match TextEditor's internal padding
                    .allowsHitTesting(false)
            }
        }
        .padding(12) // Apply padding to the ZStack instead
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BrewerColors.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(BrewerColors.divider, lineWidth: 1)
                )
        )
    }
}

#Preview {
    struct FormRichTextFieldPreviewWrapper: View {
        @State private var notes: String = ""
        @State private var notesWithContent: String = "This is some sample text to show how it looks with content."

        var body: some View {
            GlobalBackground {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Tasting Notes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Empty state:")
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        FormRichTextField(
                            notes: $notes,
                            placeholder: "How did it taste? (Aroma, acidity, body, etc.)"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("With content:")
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        FormRichTextField(
                            notes: $notesWithContent,
                            placeholder: "How did it taste? (Aroma, acidity, body, etc.)"
                        )
                    }
                }
                .padding(24)
            }
        }
    }

    return FormRichTextFieldPreviewWrapper()
}
