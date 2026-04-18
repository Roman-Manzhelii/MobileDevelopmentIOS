//
//  HistoryView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct HistoryView: View {
    private struct ScanItem: Identifiable {
        let id = UUID()
        let filename: String
        let timestamp: String
        let badgePrimary: String
        let badgeSecondary: String?
    }

    @State private var items: [ScanItem] = [
        ScanItem(filename: "Image_012.jpg", timestamp: "Mar 20, 2026 · 2:14 PM", badgePrimary: "85%", badgeSecondary: "AI"),
        ScanItem(filename: "Image_011.jpg", timestamp: "Mar 20, 2026 · 11:03 AM", badgePrimary: "12%", badgeSecondary: "Real"),
        ScanItem(filename: "Image_010.jpg", timestamp: "Mar 19, 2026 · 7:45 PM", badgePrimary: "63%", badgeSecondary: "AI"),
        ScanItem(filename: "Image_009.jpg", timestamp: "Mar 19, 2026 · 4:22 PM", badgePrimary: "91%", badgeSecondary: "AI")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scan History")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.ffTextPrimary)
                        Text("All of your previous scans")
                            .font(.subheadline)
                            .foregroundStyle(Color.ffTextMuted)
                    }
                    Spacer(minLength: 12)
                    OutlineButton(title: "Clear All") {
                        items.removeAll()
                    }
                }
                .padding(.top, 8)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                Text("● Fetched from SwiftData ScanHistory — chronological list")
                    .font(.caption2)
                    .foregroundStyle(Color.ffTextMuted)

                VStack(spacing: 10) {
                    ForEach(items) { item in
                        HistoryRow(
                            filename: item.filename,
                            timestamp: item.timestamp,
                            badgeText: item.badgePrimary,
                            secondaryBadge: item.badgeSecondary,
                            showChevron: true
                        )
                    }
                }

                if items.isEmpty {
                    Text("No scans yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.ffTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    HistoryView()
        .background(Color.ffBackground)
}
