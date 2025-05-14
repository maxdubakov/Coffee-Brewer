//
//  GlobalBackground.swift
//  Coffee Brewer
//
//  Created by Maxim on 14/05/2025.
//


import SwiftUI

struct GlobalBackground<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            BrewerColors.background
                .ignoresSafeArea()
            content
        }
    }
}
