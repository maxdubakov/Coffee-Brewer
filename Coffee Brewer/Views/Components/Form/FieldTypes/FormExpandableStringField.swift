import SwiftUI

struct FormExpandableStringField: View {
    // MARK: - Public Properties
    let title: String
    let items: [String]
    let field: FocusedField
    let allowEmpty: Bool
    
    // MARK: - Bindings
    @Binding var selectedItem: String
    @Binding var focusedField: FocusedField?

    // MARK: - Computed Properties
    var isActive: Bool {
        focusedField == field
    }
    
    var displayItems: [String] {
        allowEmpty ? ["None"] + items : items
    }
    
    var selectedIndex: Binding<Int> {
        Binding(
            get: {
                if allowEmpty {
                    if selectedItem.isEmpty {
                        return 0
                    } else {
                        return (items.firstIndex(of: selectedItem) ?? -1) + 1
                    }
                } else {
                    return items.firstIndex(of: selectedItem) ?? 0
                }
            },
            set: { newIndex in
                if allowEmpty {
                    if newIndex == 0 {
                        selectedItem = ""
                    } else {
                        selectedItem = items[newIndex - 1]
                    }
                } else {
                    selectedItem = items[newIndex]
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: title)
                Spacer()
                if !selectedItem.isEmpty {
                    FormValueText(value: selectedItem)
                } else if allowEmpty {
                    FormValueText(value: "None")
                        .foregroundColor(BrewerColors.textSecondary)
                } else {
                    FormPlaceholderText(value: "Select")
                }
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    focusedField = isActive ? nil : field
                }
            }

            if isActive {
                VStack {
                    Picker("", selection: selectedIndex) {
                        ForEach(0..<displayItems.count, id: \.self) { index in
                            Text(displayItems[index])
                                .foregroundColor(index == 0 && allowEmpty ? BrewerColors.textSecondary : BrewerColors.textPrimary)
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
