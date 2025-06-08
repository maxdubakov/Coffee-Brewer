import SwiftUI

struct BrewingParametersSection: View {
    @Binding var formData: RecipeFormData
    @Binding var brewMath: BrewMathViewModel
    @Binding var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("parameters", size: 20, color: BrewerColors.caramel)
                
                SecondaryHeader(title: "Brewing Parameters")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormExpandableNumberField(
                    title: "Coffee (grams)",
                    range: Array(8...40),
                    formatter: { "\($0)g" },
                    field: .grams,
                    value: $brewMath.grams,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Ratio",
                    range: Array(stride(from: 10.0, through: 20.0, by: 1.0)),
                    formatter: { "1:\($0)" },
                    field: .ratio,
                    value: $brewMath.ratio,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormKeyboardInputField(
                    title: "Water (ml)",
                    field: .waterml,
                    keyboardType: .numberPad,
                    valueToString: { String($0) },
                    stringToValue: { Int16($0) ?? 0 },
                    value: $brewMath.water,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormExpandableNumberField(
                    title: "Temperature",
                    range: Array(stride(from: 80.0, through: 99.5, by: 0.5)),
                    formatter: { "\($0)°C" },
                    field: .temperature,
                    value: $formData.temperature,
                    focusedField: $focusedField
                )
            }
        }
    }
}