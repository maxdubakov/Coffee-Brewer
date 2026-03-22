import SwiftUI
import Combine

struct FixedBottomLayout<Content: View, Actions: View>: View {
    let content: Content
    let actions: Actions
    let contentPadding: EdgeInsets
    let actionPadding: EdgeInsets
    let scrollable: Bool

    @State private var isKeyboardVisible = false

    init(
        scrollable: Bool = true,
        contentPadding: EdgeInsets = EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0),
        actionPadding: EdgeInsets = EdgeInsets(top: 16, leading: 18, bottom: 28, trailing: 18),
        @ViewBuilder content: () -> Content,
        @ViewBuilder actions: () -> Actions
    ) {
        self.scrollable = scrollable
        self.contentPadding = contentPadding
        self.actionPadding = actionPadding
        self.content = content()
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: 0) {
            if scrollable {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        content
                    }
                    .padding(contentPadding)
                    .padding(.bottom, 80)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    if isKeyboardVisible {
                        VStack(spacing: 0) {
                            Spacer().frame(height: 20)
                            HStack {
                                Spacer()
                                Button("Done") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 20)
                            .padding(.vertical, 8)
                            .background(BrewerColors.background)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 30) {
                    content
                    Spacer()
                }
                .padding(contentPadding)
            }

            if !isKeyboardVisible {
                VStack {
                    Divider()
                        .background(BrewerColors.divider)

                    actions
                        .padding(actionPadding)
                }
                .background(BrewerColors.background)
            }
        }
        .background(BrewerColors.background)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
}

extension View {
    func withFixedBottomActions<Actions: View>(
        scrollable: Bool = true,
        contentPadding: EdgeInsets = EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0),
        actionPadding: EdgeInsets = EdgeInsets(top: 16, leading: 18, bottom: 28, trailing: 18),
        @ViewBuilder actions: () -> Actions
    ) -> some View {
        FixedBottomLayout(
            scrollable: scrollable,
            contentPadding: contentPadding,
            actionPadding: actionPadding,
            content: { self },
            actions: actions
        )
    }
}
