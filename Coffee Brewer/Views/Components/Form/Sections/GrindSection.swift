import SwiftUI

struct GrindSection: View {
    @Binding var formData: RecipeFormData
    @Binding var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("coffee.grind", size: 25, color: BrewerColors.caramel)
                
                SecondaryHeader(title: "Grind")
            }
            .padding(.horizontal, 20)
            
            FormGroup {
                SearchGrinderPickerField(
                    selectedGrinder: $formData.grinder,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Grind Size",
                    range: Array(0...100),
                    formatter: { "\($0)" },
                    field: .grindSize,
                    value: $formData.grindSize,
                    focusedField: $focusedField
                )
            }
        }
    }
}