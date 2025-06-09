import SwiftUI

struct GrinderForm: View {
    @Binding var formData: GrinderFormData
    @Binding var focusedField: FocusedField?
    
    let burrTypes = ["Conical", "Flat"]
    let grinderTypes = ["Manual", "Electric"]
    let dosingTypes = ["Single Dose", "Hopper Fed", "Doserless", "Timer Based"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 30) {
                    basicInfoSection
                    burrSection
                }
            }
            .padding(.bottom, 100)
        }
        .scrollDismissesKeyboard(.interactively)
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
                    title: "Grinder Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.name,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormToggleField(
                    title: "Type",
                    options: grinderTypes,
                    selectedOption: $formData.type
                )
                
                Divider()
                
                FormExpandableStringField(
                    title: "Dosing Type",
                    items: dosingTypes,
                    field: .dosingType,
                    allowEmpty: true,
                    selectedItem: $formData.dosingType,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormTripleExpandableField(
                    title: "Grind Settings",
                    fromRange: Array(0...100),
                    toRange: Array(0...500),
                    stepRange: [0.1, 0.25, 0.5, 1.0, 2.0],
                    from: $formData.settingsFrom,
                    to: $formData.settingsTo,
                    step: $formData.settingsStep,
                    focusedField: $focusedField
                )
            }
        }
    }
    
    // MARK: - Specifications Section
    private var burrSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("burrs", size: 20, color: BrewerColors.caramel)
                
                SecondaryHeader(title: "Burr")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormToggleField(
                    title: "Burr Type",
                    options: burrTypes,
                    selectedOption: $formData.burrType
                )
                
                Divider()
                
                FormKeyboardInputField(
                    title: "Burr Size (mm)",
                    field: .burrSize,
                    keyboardType: .numberPad,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.burrSize,
                    focusedField: $focusedField
                )
            }
        }
    }
}
