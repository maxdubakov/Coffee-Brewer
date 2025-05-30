import SwiftUI

struct FormAxisPickerField: View {
    let title: String
    let field: FocusedField
    let axes: [(String, [any ChartAxis])]
    @Binding var selection: AxisConfiguration?
    @Binding var focusedField: FocusedField?
    let disabledAxisId: String?
    
    var body: some View {
        FormField {
            Menu {
                menuContent
            } label: {
                menuLabel
            }
        }
        .onTapGesture {
            focusedField = field
        }
    }
    
    @ViewBuilder
    private var menuContent: some View {
        ForEach(axes, id: \.0) { groupName, axesList in
            Section(groupName) {
                ForEach(axesList, id: \.id) { axis in
                    menuButton(for: axis)
                }
            }
        }
    }
    
    private func menuButton(for axis: any ChartAxis) -> some View {
        Button(action: {
            if disabledAxisId != axis.id {
                selection = AxisConfiguration(from: axis)
            }
        }) {
            let isSelected = selection?.axisId == axis.id
            Label(
                axis.displayName,
                systemImage: isSelected ? "checkmark" : ""
            )
        }
        .disabled(disabledAxisId == axis.id)
    }
    
    private var menuLabel: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                FormPlaceholderText(value: title)
                
                let displayText = selection?.displayName ?? "Select \(title)"
                FormValueText(value: displayText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(BrewerColors.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedAxis: AxisConfiguration?
        @State private var focusedField: FocusedField?
        
        private let axes: [(String, [any ChartAxis])] = [
            ("Numeric", NumericAxis.allAxes),
            ("Categorical", CategoricalAxis.allAxes),
            ("Temporal", TemporalAxis.allAxes)
        ]
        
        var body: some View {
            GlobalBackground {
                VStack(spacing: 20) {
                    FormGroup {
                        FormAxisPickerField(
                            title: "X-Axis",
                            field: .name,
                            axes: axes,
                            selection: $selectedAxis,
                            focusedField: $focusedField,
                            disabledAxisId: nil
                        )
                    }
                    .padding()
                }
            }
        }
    }
    
    return PreviewWrapper()
}
