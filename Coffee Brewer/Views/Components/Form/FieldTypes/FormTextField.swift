import SwiftUI

struct FormTextField: View {
        // MARK: - Public Properties
        let title: String
        let field: AddRecipe.FocusedField
        var keyboardType: UIKeyboardType = .default

        // MARK: - Bindings
        @Binding var text: String
        @Binding var focusedField: AddRecipe.FocusedField?

        // MARK: - Focus State
        @FocusState private var isFocused: Bool

        // MARK: - Computed Properties
        private var isActive: Bool {
            focusedField == field
        }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                if isActive {
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            FormPlaceholderText(value: title)
                        }

                        TextField("", text: $text)
                            .focused($isFocused)
                            .keyboardType(keyboardType)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(BrewerColors.textPrimary)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    FormPlaceholderText(value: title)
                }

                Spacer()

                if !isActive && !text.isEmpty {
                    FormValueText(value: text)
                }
            }

            Divider()
        }
        .onTapGesture {
            focusedField = field
        }
        .onChange(of: focusedField) { oldValue, newValue in
            isFocused = newValue == field
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if !newValue, focusedField == field {
                focusedField = nil
            }
        }
    }
}
