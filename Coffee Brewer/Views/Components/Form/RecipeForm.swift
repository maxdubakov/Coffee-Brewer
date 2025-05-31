import SwiftUI

struct RecipeForm: View {
    @Binding var formData: RecipeFormData
    @Binding var brewMath: BrewMathViewModel
    @Binding var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            basicInfoSection
            brewingParametersSection
            grindSection
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss any active field when tapping outside
            withAnimation(.spring()) {
                focusedField = nil
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
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
            }
        }
    }
    
    // MARK: - Brewing Parameters Section
    private var brewingParametersSection: some View {
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
    
    // MARK: - Grind Section
    private var grindSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("coffee.grind", size: 20, color: BrewerColors.caramel)
                
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
