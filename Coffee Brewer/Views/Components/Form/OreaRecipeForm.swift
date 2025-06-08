import SwiftUI

struct OreaRecipeForm: View {
    @Binding var formData: RecipeFormData
    @Binding var brewMath: BrewMathViewModel
    @Binding var focusedField: FocusedField?
    var onBottomTypeChange: ((OreaBottomType) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            basicInfoSection
            oreaBottomSection
            brewingParametersSection
            grindSection
        }
        .padding(.bottom, 20)
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
    
    // MARK: - Orea Bottom Section
    private var oreaBottomSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("orea.v4", size: 20, color: BrewerColors.caramel)
                SecondaryHeader(title: "Orea Bottom Type")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormTypePickerField(
                    title: "Bottom Type",
                    field: .grindSize, // Using an existing field as placeholder
                    options: OreaBottomType.allCases.map { $0 },
                    selection: Binding(
                        get: { formData.oreaBottomType ?? .classic },
                        set: { newValue in
                            formData.oreaBottomType = newValue
                            onBottomTypeChange?(newValue)
                        }
                    ),
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
                FormSliderField(
                    value: Binding(
                        get: { Int(formData.temperature) },
                        set: { formData.temperature = Double($0) }
                    ),
                    from: 80,
                    to: 100,
                    title: "Temperature °C",
                    color: BrewerColors.caramel
                )
                
                Divider()

                FormKeyboardInputField(
                    title: "Coffee (g)",
                    field: .grams,
                    keyboardType: .numberPad,
                    valueToString: { String($0) },
                    stringToValue: { Int16($0) ?? 0 },
                    value: $brewMath.grams,
                    focusedField: $focusedField
                )
                
                Divider()

                FormKeyboardInputField(
                    title: "Ratio (1:x)",
                    field: .ratio,
                    keyboardType: .decimalPad,
                    valueToString: { String(format: "%.1f", $0) },
                    stringToValue: { Double($0) ?? 16.0 },
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
            }
        }
    }
    
    // MARK: - Grind Section
    private var grindSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("burrs", size: 20, color: BrewerColors.caramel)
                SecondaryHeader(title: "Grind")
            }
            .padding(.horizontal, 20)

            FormGroup {
                SearchGrinderPickerField(
                    selectedGrinder: $formData.grinder,
                    focusedField: $focusedField
                )
                
                Divider()

                FormSliderField(
                    value: Binding(
                        get: { Int(formData.grindSize) },
                        set: { formData.grindSize = Int16($0) }
                    ),
                    from: 1,
                    to: 100,
                    title: "Grind Size",
                    color: BrewerColors.caramel
                )
            }
        }
    }
}