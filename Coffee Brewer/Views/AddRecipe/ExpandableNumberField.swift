import SwiftUI

struct ExpandableNumberField<T: Hashable & CustomStringConvertible>: View {
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
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .light))
                    .foregroundColor(BrewerColors.placeholder)

                Spacer()

                Text(formatter(value))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    focusedField = isActive ? nil : field
                }
            }
            .padding(.vertical, 13.5)

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

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
    }
}
