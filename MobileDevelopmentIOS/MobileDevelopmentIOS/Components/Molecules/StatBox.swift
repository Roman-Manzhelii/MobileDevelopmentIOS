//
//  StatBox.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct StatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ffTextPrimary)

            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.ffTextMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ffCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    StatBox(value: "74%", label: "Game accuracy")
        .padding()
        .background(Color.ffBackground)
}
