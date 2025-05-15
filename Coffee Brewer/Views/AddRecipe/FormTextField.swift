import SwiftUI

struct FormTextField: View {
    let title: String
    @Binding var text: String
    @Binding var focusedField: AddRecipe.FocusedField?
    let field: AddRecipe.FocusedField
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = false

    var isActive: Bool {
        focusedField == field
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // LEFT side placeholder or text
                if isActive {
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text(title)
                                .font(.system(size: 17, weight: .light))
                                .foregroundColor(BrewerColors.placeholder)
                        }

                        TextField("", text: $text, onEditingChanged: { editing in
                            isEditing = editing
                            if editing {
                                focusedField = field
                            }
                        }, onCommit: {
                            isEditing = false
                            focusedField = nil
                        })
                        .focused($isFocused)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                        .keyboardType(keyboardType)
                        .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .light))
                        .foregroundColor(BrewerColors.placeholder)
                }

                Spacer()

                // RIGHT side final text (shown only when not editing and text isn't empty)
                if !isActive && !text.isEmpty {
                    Text(text)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                        .onTapGesture {
                            focusedField = field
                            isFocused = true
                        }
                }
            }
            .padding(.vertical, 13.5)

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
        .onChange(of: focusedField) { newFocus in
            let shouldBeFocused = newFocus == field
            isFocused = shouldBeFocused
            isEditing = shouldBeFocused
        }
        .onTapGesture {
            focusedField = field
            isFocused = true
        }
    }
}
