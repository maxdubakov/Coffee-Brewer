import SwiftUI

struct FormValueText<Leading: View>: View {
    // MARK: - Private Properties
    private let value: String
    private let placeholder: String
    private let onCommit: (() -> Void)?
    private let textBinding: Binding<String>?
    private let isFocusedBinding: FocusState<Bool>.Binding?
    private let fontSize: CGFloat = 17.0
    private let fontWeight: Font.Weight = .medium
    private let foregroundColor: Color = BrewerColors.cream
    private let leadingView: Leading?
    
    // MARK: - Initializers
    init(value: String, @ViewBuilder leading: () -> Leading) {
        self.value = value
        self.placeholder = ""
        self.onCommit = nil
        self.textBinding = nil
        self.isFocusedBinding = nil
        self.leadingView = leading()
    }
    
    init(value: String) where Leading == EmptyView {
        self.value = value
        self.placeholder = ""
        self.onCommit = nil
        self.textBinding = nil
        self.isFocusedBinding = nil
        self.leadingView = nil
    }

    init(
        placeholder: String = "",
        textBinding: Binding<String>,
        isFocused: FocusState<Bool>.Binding? = nil,
        onCommit: (() -> Void)? = nil
    ) where Leading == EmptyView {
        self.value = textBinding.wrappedValue
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.textBinding = textBinding
        self.isFocusedBinding = isFocused
        self.leadingView = nil
    }

    var body: some View {
        Group {
            if let binding = textBinding {
                if let focusBinding = isFocusedBinding {
                    TextField(placeholder, text: binding, onCommit: {
                        onCommit?()
                    })
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(foregroundColor)
                    .keyboardType(.default)
                    .focused(focusBinding)
                } else {
                    TextField(placeholder, text: binding, onCommit: {
                        onCommit?()
                    })
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(foregroundColor)
                    .keyboardType(.default)
                }
            } else {
                HStack(spacing: 6) {
                    if let leading = leadingView {
                        leading
                    }
                    Text(value)
                        .font(.system(size: fontSize, weight: fontWeight))
                        .foregroundColor(foregroundColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: 220, alignment: .trailing)
            }
        }
    }
}
