import SwiftUI

struct ExpandableNumberField<T: Hashable & CustomStringConvertible>: View {
    let title: String
    @Binding var value: String
    let range: [T]
    let formatter: (T) -> String
    
    @State private var isExpanded = false
    @State private var selectedValue: T
    
    init(title: String, value: Binding<String>, range: [T], formatter: @escaping (T) -> String) {
        self.title = title
        self._value = value
        self.range = range
        self.formatter = formatter
        
        // Initialize selectedValue with the current value if possible
        if let existingValue = range.first(where: { $0.description == value.wrappedValue }) {
            self._selectedValue = State(initialValue: existingValue)
        } else {
            self._selectedValue = State(initialValue: range.first!)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.custom("Outfit", size: 17, relativeTo: .body).weight(.light))
                    .foregroundColor(BrewerColors.placeholder)
                
                Spacer()
                
                Text(formatter(selectedValue))
                    .font(.custom("Outfit", size: 17, relativeTo: .body).weight(.medium))
                    .foregroundColor(BrewerColors.textPrimary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
            .padding(EdgeInsets(top: 13.5, leading: 0, bottom: 13.5, trailing: 0))
            
            if isExpanded {
                VStack {
                    Picker("", selection: $selectedValue) {
                        ForEach(range, id: \.self) { item in
                            Text(formatter(item))
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                    
                    Button("Confirm") {
                        value = selectedValue.description
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }
                    .font(.custom("Outfit", size: 14, relativeTo: .body).weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(BrewerColors.coffee)
                    .cornerRadius(20)
                    .padding(.bottom, 8)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
        .onChange(of: selectedValue) { newValue in
            // Only update the binding when not expanded if user changes the picker without tapping confirm
            if !isExpanded {
                value = newValue.description
            }
        }
    }
}
