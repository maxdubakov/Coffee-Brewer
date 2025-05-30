import SwiftUI

struct FormAxisPickerField: View {
    let title: String
    let field: FocusedField
    let axes: [(String, [any ChartAxis])]
    @Binding var selection: AxisConfiguration?
    @Binding var focusedField: FocusedField?
    let disabledAxisId: String?
    
    private var commonAxes: [any ChartAxis] {
        let allAxes = axes.flatMap { $0.1 }
        let commonIds = ["brewDate", "rating", "temperature", "ratio", "roasterName", "grinderName"]
        
        return commonIds.compactMap { id in
            allAxes.first { $0.id == id }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: title)
                
                Spacer()
                
                Menu {
                    // Popular/Common axes at top level
                    ForEach(commonAxes, id: \.id) { axis in
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
                    
                    Divider()
                    
                    // Categorized axes
                    ForEach(axes, id: \.0) { groupName, axesList in
                        Menu(groupName) {
                            ForEach(axesList, id: \.id) { axis in
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
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if let selection = selection {
                            FormValueText(value: selection.displayName)
                        } else {
                            FormPlaceholderText(value: "Select")
                        }
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                }
            }
        }
        .onTapGesture {
            focusedField = field
        }
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
