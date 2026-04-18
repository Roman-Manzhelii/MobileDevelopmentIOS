//
//  PickerCard.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct PickerCard: View {
    let emoji: String
    let title: String
    let footnote: String

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 28))

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ffTextPrimary)

            Text(footnote)
                .font(.caption2)
                .foregroundStyle(Color.ffTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.ffBorder, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.ffCard))
        )
    }
}

#Preview {
    HStack(spacing: 10) {
        PickerCard(emoji: "🖼", title: "Photo Library", footnote: "● iOS PHPicker")
        PickerCard(emoji: "📷", title: "Take Photo", footnote: "● Camera capture")
    }
    .padding()
    .background(Color.ffBackground)
}
