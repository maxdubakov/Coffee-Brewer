import SwiftUI

struct BasicInfoWithBottomTypeSection: View {
    @Binding var formData: RecipeFormData
    @Binding var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("basics", size: 20, color: BrewerColors.caramel)
                SecondaryHeader(title: "Basics")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormKeyboardInputField(
                    title: "Recipe Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.name,
                    focusedField: $focusedField
                )
                
                Divider()
                
                SearchRoasterPickerField(
                    selectedRoaster: $formData.roaster,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormExpandableStringField(
                    title: "Orea Bottom",
                    items: OreaBottomType.allCases.map(\.displayName),
                    field: .oreaBottom,
                    allowEmpty: false,
                    selectedItem: Binding(
                        get: { formData.oreaBottomType?.displayName ?? "" },
                        set: { newValue in
                            formData.oreaBottomType = OreaBottomType.allCases.first { $0.displayName == newValue }
                        }
                    ),
                    focusedField: $focusedField
                )
            }
        }
    }
}
