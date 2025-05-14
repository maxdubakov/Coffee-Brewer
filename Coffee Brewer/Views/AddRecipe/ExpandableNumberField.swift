import SwiftUI

struct ExpandableNumberField<T: Hashable & CustomStringConvertible>: View {
    let title: String
    @Binding var value: T
    let range: [T]
    let formatter: (T) -> String

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .light))
                    .foregroundColor(BrewerColors.placeholder)

                Spacer()

                Text(formatter(value))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
            .padding(.vertical, 13.5)

            if isExpanded {
                VStack {
                    Picker("", selection: $value) {
                        ForEach(range, id: \.self) { item in
                            Text(formatter(item))
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()

                    Button("Confirm") {
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(BrewerColors.coffee)
                    .cornerRadius(20)
                    .padding(.bottom, 30)
                }
            }

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
    }
}
