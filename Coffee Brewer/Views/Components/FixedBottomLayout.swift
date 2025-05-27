import SwiftUI

struct FixedBottomLayout<Content: View, Actions: View>: View {
    let content: Content
    let actions: Actions
    let contentPadding: EdgeInsets
    let actionPadding: EdgeInsets
    let scrollable: Bool
    
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
                }
                .scrollDismissesKeyboard(.immediately)
            } else {
                VStack(alignment: .leading, spacing: 30) {
                    content
                    Spacer()
                }
                .padding(contentPadding)
            }
            
            VStack {
                Divider()
                    .background(BrewerColors.divider)
                
                actions
                    .padding(actionPadding)
            }
            .background(BrewerColors.background)
        }
        .background(BrewerColors.background)
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