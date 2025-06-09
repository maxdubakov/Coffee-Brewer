import SwiftUI

struct FormTripleExpandableField: View {
    // MARK: - Public Properties
    let title: String
    let fromRange: [Int16]
    let toRange: [Int16]
    let stepRange: [Double]
    
    // MARK: - Bindings
    @Binding var from: Int16
    @Binding var to: Int16
    @Binding var step: Double
    @Binding var focusedField: FocusedField?
    
    // MARK: - Computed Properties
    var isActive: Bool {
        focusedField == .settingsFrom || 
        focusedField == .settingsTo || 
        focusedField == .settingsStep
    }
    
    var displayValue: String {
        "\(from) – \(to) (step: \(String(format: "%.1f", step)))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: title)
                Spacer()
                FormValueText(value: displayValue)
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    focusedField = isActive ? nil : .settingsFrom
                }
            }
            
            if isActive {
                HStack(spacing: 8) {
                    // From picker
                    VStack(alignment: .center, spacing: 8) {
                        Text("From")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        Picker("", selection: $from) {
                            ForEach(fromRange, id: \.self) { value in
                                Text("\(value)")
                                    .font(.system(size: 20))
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                    }
                    
                    Divider()
                    
                    // To picker
                    VStack(alignment: .center, spacing: 8) {
                        Text("To")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        Picker("", selection: $to) {
                            ForEach(toRange, id: \.self) { value in
                                Text("\(value)")
                                    .font(.system(size: 20))
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                    }
                    
                    Divider()
                    
                    // Step picker
                    VStack(alignment: .center, spacing: 8) {
                        Text("Step")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        Picker("", selection: $step) {
                            ForEach(stepRange, id: \.self) { value in
                                Text(String(format: "%.1f", value))
                                    .font(.system(size: 20))
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                    }
                }
                .padding(.vertical, 12)
            }
        }
    }
}
