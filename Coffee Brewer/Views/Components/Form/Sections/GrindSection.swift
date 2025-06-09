import SwiftUI

struct GrindSection: View {
    @Binding var formData: RecipeFormData
    @Binding var focusedField: FocusedField?
    
    private var grinderFrom: Int16 {
        formData.grinder?.from ?? 0
    }
    
    private var grinderTo: Int16 {
        formData.grinder?.to ?? 100
    }
    
    private var grinderStep: Double {
        formData.grinder?.step ?? 1.0
    }
    
    private var grindRange: [Double] {
        guard grinderTo != 0 else { return Array(stride(from: 0.0, through: 100.0, by: 1.0)) }
        print(Array(stride(from: Double(grinderFrom), through: Double(grinderTo), by: grinderStep > 0 ? grinderStep : 1.0)))
        return Array(stride(from: Double(grinderFrom), through: Double(grinderTo), by: grinderStep > 0 ? grinderStep : 1.0))
    }
    
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
                
                if formData.grinder != nil {
                    Divider()
                    
                    FormExpandableNumberField(
                        title: "Grind Size",
                        range: grindRange,
                        formatter: { value in
                            return String(format: "%.1f", value)
                        },
                        field: .grindSize,
                        value: Binding(
                            get: { formData.grindSize ?? 0.0 },
                            set: { formData.grindSize = $0 }
                        ),
                        focusedField: $focusedField
                    )
                    .id(formData.grinder?.id)
                }
            }
        }
        .onChange(of: formData.grinder?.id) { oldGrinderId, newGrinderId in
            formData.grindSize = nil
        }
    }
}
