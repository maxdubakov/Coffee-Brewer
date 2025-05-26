import SwiftUI

struct FormKeyboardInputField<Value>: View {
    // MARK: - Public Properties
    let title: String
    let field: FocusedField
    var keyboardType: UIKeyboardType = .default
    var formatter: Formatter?
    let valueToString: (Value) -> String
    let stringToValue: (String) -> Value?

    // MARK: - Bindings
    @Binding var value: Value
    @Binding var focusedField: FocusedField?

    // MARK: - Focus State
    @FocusState private var isFocused: Bool

    // MARK: - Local State
    @State private var internalText: String = ""

    // MARK: - Computed Properties
    private var isActive: Bool {
        focusedField == field
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                ZStack(alignment: .leading) {
                    // Always show placeholder when not active or when active but empty
                    if !isActive || (isActive && internalText.isEmpty) {
                        FormPlaceholderText(value: title)
                    }
                    
                    // Always render TextField but make it invisible when not active
                    TextField("", text: $internalText)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(BrewerColors.cream)
                        .multilineTextAlignment(.leading)
                        .opacity(isActive ? 1 : 0)
                        .allowsHitTesting(isActive)
                        .onChange(of: internalText) { _, newValue in
                            if let newVal = stringToValue(newValue) {
                                value = newVal
                            }
                        }
                }
                
                Spacer()
                
                if !isActive && !valueToString(value).isEmpty {
                    FormValueText(value: valueToString(value))
                }
            }
        }
        .onTapGesture {
            focusedField = field
        }
        .onAppear {
            internalText = valueToString(value)
        }
        .onChange(of: focusedField) { _, newValue in
            isFocused = newValue == field
        }
        .onChange(of: isFocused) { _, newValue in
            if newValue {
                internalText = valueToString(value)
            } else {
                if focusedField == field {
                    focusedField = nil
                }
            }
        }
    }
}
