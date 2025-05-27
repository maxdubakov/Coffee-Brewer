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
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
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
                
                FormExpandableStringField(
                    title: "Type",
                    items: grinderTypes,
                    field: .grinderType,
                    allowEmpty: false,
                    selectedItem: $formData.type,
                    focusedField: $focusedField
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
            }
        }
    }
    
    // MARK: - Specifications Section
    private var burrSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
                SecondaryHeader(title: "Burr")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormExpandableStringField(
                    title: "Burr Type",
                    items: burrTypes,
                    field: .burrType,
                    allowEmpty: false,
                    selectedItem: $formData.burrType,
                    focusedField: $focusedField
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
