import SwiftUI

// MARK: - Main SegmentedFormTypePicker Component
struct FormTypePicker<T: Identifiable & CustomStringConvertible & Hashable>: View {
    // MARK: - Public Properties
    let title: String
    let field: FocusedField
    let options: [T]
    
    // MARK: - Bindings
    @Binding var selection: T
    @Binding var focusedField: FocusedField?
    
    init(title: String, field: FocusedField, options: [T], selection: Binding<T>, focusedField: Binding<FocusedField?>) {
        self.title = title
        self.field = field
        self.options = options
        self._selection = selection
        self._focusedField = focusedField
        
        // Configure UISegmentedControl appearance
        let segmentAppearance = UISegmentedControl.appearance()
        
        // Convert SwiftUI colors to UIColors
        let selectedBgColor = UIColor(BrewerColors.cream)
        let normalTextColor = UIColor(BrewerColors.textPrimary)
        let selectedTextColor = UIColor(BrewerColors.espresso)
        let bgColor = UIColor(BrewerColors.surface.opacity(0.6))
        
        // Set colors for different states
        segmentAppearance.backgroundColor = bgColor
        segmentAppearance.selectedSegmentTintColor = selectedBgColor
        
        // Set the text attributes for different states
        segmentAppearance.setTitleTextAttributes([
            .foregroundColor: normalTextColor,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        
        segmentAppearance.setTitleTextAttributes([
            .foregroundColor: selectedTextColor,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FormField {
                // Segmented control showing all options at once
                Picker("", selection: $selection) {
                    ForEach(options, id: \.id) { option in
                        Text("\(option.description) \(option.id as! String != "wait" ? "Pour" : "")")
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(BrewerColors.cream)
            }
        }
        .padding(.bottom, 10)
        .onTapGesture {
            focusedField = field
        }
    }
}

// MARK: - Example Preview
struct SegmentedFormTypePickerPreview: View {
    @State private var selectedStage: StageType = .fast
    @State private var focusedField: FocusedField? = nil
    
    var body: some View {
        GlobalBackground {
            VStack(spacing: 24) {
                FormTypePicker(
                    title: "Stage Type",
                    field: .grindSize,
                    options: StageType.allTypes,
                    selection: $selectedStage,
                    focusedField: $focusedField
                )
            }
            .padding()
        }
    }
}

#Preview {
    SegmentedFormTypePickerPreview()
}
