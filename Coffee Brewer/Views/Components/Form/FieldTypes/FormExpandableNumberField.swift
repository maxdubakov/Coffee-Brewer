import SwiftUI

struct FormExpandableNumberField<T: Hashable & CustomStringConvertible>: View {
    let title: String
    @Binding var value: T
    let range: [T]
    let formatter: (T) -> String
    @Binding var focusedField: AddRecipe.FocusedField?
    let field: AddRecipe.FocusedField

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

            Divider()
        }
    }
}
