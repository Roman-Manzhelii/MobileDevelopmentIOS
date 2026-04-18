//
//  Badge.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct Badge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.ffTextPrimary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.ffElevated, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.ffBorder, lineWidth: 1))
    }
}

#Preview {
    Badge(text: "1")
        .padding()
        .background(Color.ffBackground)
}
