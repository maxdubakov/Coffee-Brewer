import SwiftUI

struct FormTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .light))
                    .foregroundColor(BrewerColors.placeholder)
                
                Spacer()
                
                TextField("", text: $text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
            }
            .padding(EdgeInsets(top: 13.5, leading: 0, bottom: 13.5, trailing: 0))
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
    }
}
