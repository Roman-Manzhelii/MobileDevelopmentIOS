//
//  HistoryView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HistoryManager()

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
                        viewModel.clearAll(using: modelContext)
                    }
                }
                .padding(.top, 8)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                Text("● Fetched from SwiftData ScanRecord — chronological list")
                    .font(.caption2)
                    .foregroundStyle(Color.ffTextMuted)

                VStack(spacing: 10) {
                    ForEach(viewModel.items) { item in
                        HistoryRow(
                            filename: item.filename,
                            timestamp: item.timestamp,
                            badgeText: item.badgePrimary,
                            secondaryBadge: item.badgeSecondary,
                            showChevron: true
                        )
                    }
                }

                if viewModel.items.isEmpty {
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
        .onAppear {
            viewModel.load(using: modelContext)
        }
    }
}

#Preview {
    HistoryView()
        .background(Color.ffBackground)
}
