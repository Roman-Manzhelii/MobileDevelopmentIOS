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
    var secondaryBadge: String? = nil
    var showChevron: Bool = false

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

            Group {
                if let secondary = secondaryBadge {
                    HStack(spacing: 4) {
                        historyChip(badgeText)
                        historyChip(secondary)
                    }
                } else {
                    historyChip(badgeText)
                }
            }

            if showChevron {
                Text("›")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(Color.ffTextMuted)
            }
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

    private func historyChip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.ffTextPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.ffElevated, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.ffBorder, lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: 10) {
        HistoryRow(filename: "Image_001.jpg", timestamp: "Today, 2:14 PM", badgeText: "85% AI")
        HistoryRow(
            filename: "Image_012.jpg",
            timestamp: "Mar 20, 2026 · 2:14 PM",
            badgeText: "85%",
            secondaryBadge: "AI",
            showChevron: true
        )
    }
    .padding()
    .background(Color.ffBackground)
}
