import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: MainView.Tab

    var body: some View {
        HStack(alignment: .center, spacing: 40) {
            // Home Button
            BottomBarButton(
                action: {
                    selectedTab = .home
                },
                icon: {
                    Image("home")
                        .resizable()
                        .scaledToFit()
                },
                isSelected: selectedTab == .home
            )

            // Recipes Button
            BottomBarButton(
                action: {
                    selectedTab = .add
                },
                icon: {
                    Image("add.recipe")
                        .resizable()
                        .scaledToFit()
                },
                isSelected: selectedTab == .add
            )

            // History Button
            BottomBarButton(
                action: {
                    selectedTab = .history
                },
                icon: {
                    Image("history")
                        .resizable()
                        .scaledToFit()
                },
                isSelected: selectedTab == .history
            )
        }
        .padding(.vertical, 20)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.05, green: 0.03, blue: 0.01))
        .shadow(color: Color.black.opacity(0.2), radius: 5, y: -2)
    }
}

struct BottomBarButton: View {
    let action: () -> Void
    let icon: () -> AnyView
    let isSelected: Bool

    init(action: @escaping () -> Void, icon: @escaping () -> some View, isSelected: Bool = false) {
        self.action = action
        self.icon = { AnyView(icon()) }
        self.isSelected = isSelected
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                icon()
                    .frame(height: 40)
                    .scaleEffect(isSelected ? 1 : 0.8)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: MainView.Tab = .home

        var body: some View {
            BottomBar(selectedTab: $selectedTab)                .background(Color.black)
        }
    }

    return PreviewWrapper()
}
