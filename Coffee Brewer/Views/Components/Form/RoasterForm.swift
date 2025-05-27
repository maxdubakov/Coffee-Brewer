import SwiftUI

struct RoasterForm: View {
    @Binding var formData: RoasterFormData
    @Binding var focusedField: FocusedField?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("New Roaster")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Text("Add a coffee roaster to your collection")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                .padding(.bottom, 24)
                
                VStack(spacing: 30) {
                    basicInfoSection
                    detailsSection
                    notesSection
                }
            }
            .padding(.horizontal, 16)
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
                
                SecondaryHeader(title: "Basic Information")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormKeyboardInputField(
                    title: "Name",
                    field: .name,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.name,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormKeyboardInputField(
                    title: "Location",
                    field: .location,
                    keyboardType: .default,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.location,
                    focusedField: $focusedField
                )
            }
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
                SecondaryHeader(title: "Details")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormKeyboardInputField(
                    title: "Website",
                    field: .website,
                    keyboardType: .URL,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.website,
                    focusedField: $focusedField
                )
                
                Divider()
                
                FormKeyboardInputField(
                    title: "Founded Year",
                    field: .foundedYear,
                    keyboardType: .numberPad,
                    valueToString: { $0 },
                    stringToValue: { $0 },
                    value: $formData.foundedYear,
                    focusedField: $focusedField
                )
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .foregroundColor(BrewerColors.caramel)
                    .font(.system(size: 16))
                
                SecondaryHeader(title: "Notes")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormRichTextField(
                    notes: $formData.notes,
                    placeholder: "Add any additional information about this roaster"
                )
            }
        }
    }
}