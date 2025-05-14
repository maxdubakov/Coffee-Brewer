import SwiftUI

struct FormTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Title/placeholder always visible on the left
                Text(title)
                    .font(.custom("Outfit", size: 17, relativeTo: .body).weight(.light))
                    .foregroundColor(BrewerColors.placeholder)
                
                Spacer()
                
                // Text field aligned to the right
                TextField("", text: $text)
                    .font(.custom("Outfit", size: 17, relativeTo: .body).weight(.medium))
                    .foregroundColor(BrewerColors.textPrimary)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 13.5, leading: 0, bottom: 13.5, trailing: 0))
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(BrewerColors.divider)
        }
    }
}
