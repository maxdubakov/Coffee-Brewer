//
//  FormField.swift
//  Coffee Brewer
//
//  Created by Maxim on 16/05/2025.
//

import SwiftUI

struct FormField<Content: View> : View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
        }
        .contentShape(Rectangle())
        .padding(.vertical, 13.5)
    }
}
