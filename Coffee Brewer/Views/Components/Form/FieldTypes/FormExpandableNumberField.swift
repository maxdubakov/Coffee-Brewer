import SwiftUI

struct FormExpandableNumberField<T: Hashable & CustomStringConvertible>: View {
    // MARK: - Public Properties
    let title: String
    let range: [T]
    let formatter: (T) -> String
    let field: FocusedField
    
    // MARK: - Bindings
    @Binding var value: T
    @Binding var focusedField: FocusedField?

    // MARK: - Computed Properties
    var isActive: Bool {
        focusedField == field
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: title)
                Spacer()
                FormValueText(value: formatter(value))
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    focusedField = isActive ? nil : field
                }
            }

            if isActive {
                VStack {
                    Picker("", selection: $value) {
                        ForEach(range, id: \.self) { item in
                            Text(formatter(item))
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                }
            }

        }
    }
}
