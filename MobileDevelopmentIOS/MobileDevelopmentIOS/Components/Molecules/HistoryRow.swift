//
//  HistoryRow.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct HistoryRow: View {
    let filename: String
    let timestamp: String
    let badgeText: String

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.ffElevated)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundStyle(Color.ffTextMuted)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(filename)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ffTextPrimary)
                    .lineLimit(1)

                Text(timestamp)
                    .font(.caption)
                    .foregroundStyle(Color.ffTextMuted)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(badgeText)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.ffTextPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.ffElevated, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.ffBorder, lineWidth: 1))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ffCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    HistoryRow(filename: "Image_001.jpg", timestamp: "Today, 2:14 PM", badgeText: "85% AI")
        .padding()
        .background(Color.ffBackground)
}
