import SwiftUI

struct FormTitleField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textPrimary)
                .focused($isFocused)
                .padding(.vertical, 12)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                }
            
            // Bottom border
            Rectangle()
                .fill(isFocused ? BrewerColors.caramel : BrewerColors.divider)
                .frame(height: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// Extension to add placeholder modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var title1 = ""
        @State private var title2 = "Rating Over Time"
        
        var body: some View {
            GlobalBackground {
                VStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMPTY STATE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        FormTitleField(
                            placeholder: "Enter Chart Title",
                            text: $title1
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WITH CONTENT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        FormTitleField(
                            placeholder: "Enter Chart Title",
                            text: $title2
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
