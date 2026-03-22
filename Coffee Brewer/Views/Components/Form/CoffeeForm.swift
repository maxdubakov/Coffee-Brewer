import SwiftUI

private enum CoffeeProcess: String, CaseIterable {
    case washed = "Washed"
    case natural = "Natural"
    case honey = "Honey"
    case anaerobic = "Anaerobic"
    case other = "Other"

    var displayName: String { rawValue }
}

struct CoffeeForm: View {
    @Binding var formData: CoffeeFormData
    @Binding var focusedField: FocusedField?

    @State private var selectedProcess: CoffeeProcess = .washed
    @State private var customProcessText: String = ""

    private var processOptions: [String] {
        CoffeeProcess.allCases.map(\.rawValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 30) {
                basicInfoSection
                processSection
                notesSection
            }
        }
        .onAppear {
            initializeProcessState()
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
                    title: "Coffee Name",
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

                SearchCountryPickerField(
                    selectedCountry: $formData.country,
                    focusedField: $focusedField
                )
            }
        }
    }

    // MARK: - Process Section

    private var processSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("parameters", size: 20, color: BrewerColors.caramel)
                SecondaryHeader(title: "Process")
            }
            .padding(.horizontal, 20)

            FormGroup {
                FormExpandableStringField(
                    title: "Process",
                    items: processOptions,
                    field: .coffeeProcess,
                    allowEmpty: false,
                    selectedItem: Binding(
                        get: { selectedProcess.rawValue },
                        set: { selectedProcess = CoffeeProcess(rawValue: $0) ?? .other }
                    ),
                    focusedField: $focusedField
                )
                .onChange(of: selectedProcess) { _, newProcess in
                    if newProcess != .other {
                        formData.process = newProcess.rawValue
                        customProcessText = ""
                    } else {
                        formData.process = customProcessText
                    }
                }

                if selectedProcess == .other {
                    Divider()

                    FormKeyboardInputField(
                        title: "Custom Process",
                        field: .coffeeCustomProcess,
                        keyboardType: .default,
                        valueToString: { $0 },
                        stringToValue: { $0 },
                        value: $customProcessText,
                        focusedField: $focusedField
                    )
                    .onChange(of: customProcessText) { _, newValue in
                        formData.process = newValue
                    }
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                SVGIcon("notes", size: 20, color: BrewerColors.caramel)
                SecondaryHeader(title: "Notes")
            }

            FormRichTextField(
                notes: $formData.notes,
                placeholder: "Add any additional notes about this coffee..."
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private func initializeProcessState() {
        let process = formData.process
        if process.isEmpty {
            selectedProcess = .washed
            formData.process = CoffeeProcess.washed.rawValue
        } else if let known = CoffeeProcess(rawValue: process), known != .other {
            selectedProcess = known
        } else {
            selectedProcess = .other
            customProcessText = process
        }
    }
}
