import SwiftUI

struct FormTextField: View {
    let title: String
    @Binding var text: String
    @Binding var focusedField: AddRecipe.FocusedField?
    let field: AddRecipe.FocusedField
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    private var isActive: Bool { focusedField == field }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if isActive {
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text(title)
                                .foregroundColor(BrewerColors.placeholder)
                                .font(.system(size: 17, weight: .light))
                        }

                        TextField("", text: $text)
                            .focused($isFocused)
                            .keyboardType(keyboardType)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(BrewerColors.textPrimary)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    Text(title)
                        .foregroundColor(BrewerColors.placeholder)
                        .font(.system(size: 17, weight: .light))
                }

                Spacer()

                if !isActive && !text.isEmpty {
                    Text(text)
                        .foregroundColor(BrewerColors.textPrimary)
                        .font(.system(size: 17, weight: .medium))
                        .onTapGesture {
                            focusedField = field
                        }
                }
            }
            .padding(.vertical, 13.5)

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = field
        }
        .onChange(of: focusedField) { oldValue, newValue in
            isFocused = newValue == field
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if !newValue {
                focusedField = nil
            }
        }
    }
}
