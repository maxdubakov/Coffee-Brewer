import SwiftUI

// MARK: - Option Row Component
struct PickerOptionRow<T: Identifiable & CustomStringConvertible>: View {
    let option: T
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.description)
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? BrewerColors.cream.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Dropdown Options Component
struct PickerOptionsContainer<T: Identifiable & CustomStringConvertible>: View {
    let options: [T]
    let selection: T
    let onSelect: (T) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options, id: \.id) { option in
                PickerOptionRow(
                    option: option,
                    isSelected: option.id == selection.id,
                    action: { onSelect(option) }
                )
                
                if option.id != options.last?.id {
                    Divider().padding(.leading, 16)
                }
            }
        }
        .background(BrewerColors.background)
        .cornerRadius(8)
        .padding(.top, 8)
    }
}

// MARK: - Selected Value Display
struct SelectedValueDisplay<T: CustomStringConvertible>: View {
    let selection: T
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if !isActive {
                FormValueText(value: selection.description)
            }
            
            Image(systemName: isActive ? "chevron.up" : "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isActive ? BrewerColors.cream : BrewerColors.textSecondary)
        }
    }
}

// MARK: - Main FormTypePicker Component
struct FormTypePicker<T: Identifiable & CustomStringConvertible>: View {
    // MARK: - Public Properties
    let title: String
    let field: AddRecipe.FocusedField
    let options: [T]
    
    // MARK: - Bindings
    @Binding var selection: T
    @Binding var focusedField: AddRecipe.FocusedField?
    
    // MARK: - Local State
    @State private var isExpanded: Bool = false
    
    // MARK: - Computed Properties
    private var isActive: Bool {
        focusedField == field || isExpanded
    }
    
    // MARK: - Methods
    private func toggleExpanded() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if isExpanded {
                isExpanded = false
                focusedField = nil
            } else {
                isExpanded = true
                focusedField = field
            }
        }
    }
    
    private func selectOption(_ option: T) {
        selection = option
        withAnimation(.easeInOut(duration: 0.2)) {
            isExpanded = false
            focusedField = nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: title)
                Spacer()
                SelectedValueDisplay(selection: selection, isActive: isActive)
            }
            .onTapGesture {
                toggleExpanded()
            }

            if isActive {
                PickerOptionsContainer(
                    options: options,
                    selection: selection,
                    onSelect: selectOption
                )
                .transition(.opacity)
            }
            
            Divider()
        }
        .onChange(of: focusedField) { _, newValue in
            if newValue != field {
                isExpanded = false
            }
        }
    }
}

struct ExampleViewWithMultipleTypePickersPreview: View {
    @State private var selectedStage: StageType = .fast
    @State private var focusedField: AddRecipe.FocusedField? = nil
    
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
    ExampleViewWithMultipleTypePickersPreview()
}
