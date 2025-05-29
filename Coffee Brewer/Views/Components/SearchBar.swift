import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Search..."
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(BrewerColors.textSecondary)
                    .font(.system(size: 14))
                
                TextField(placeholder, text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(BrewerColors.cream)
                    .accentColor(BrewerColors.caramel)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing = true
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BrewerColors.textSecondary)
                            .font(.system(size: 14))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(BrewerColors.cardBackground.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        BrewerColors.caramel.opacity(isEditing ? 0.4 : 0.2),
                                        BrewerColors.caramel.opacity(isEditing ? 0.2 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            
            if isEditing {
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
                        isEditing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(BrewerColors.caramel)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEditing)
        .animation(.easeInOut(duration: 0.2), value: searchText)
    }
}

// MARK: - Preview
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        GlobalBackground {
            VStack(spacing: 20) {
                SearchBar(searchText: .constant(""))
                SearchBar(searchText: .constant("Ethiopian"))
                SearchBar(searchText: .constant("V60"), placeholder: "Search recipes...")
            }
            .padding()
        }
    }
}