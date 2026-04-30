//
//  HistoryView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanRecord.timestamp, order: .reverse) private var records: [ScanRecord]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter
    }()

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
                        clearAll()
                    }
                }
                .padding(.top, 8)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                VStack(spacing: 10) {
                    ForEach(records, id: \.id) { record in
                        HistoryRow(
                            timestamp: dateFormatter.string(from: record.timestamp),
                            verdict: record.verdictLabel,
                            imageData: record.imageData
                        )
                    }
                }

                if records.isEmpty {
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

    private func clearAll() {
        do {
            for record in records {
                modelContext.delete(record)
            }
            try modelContext.save()
        } catch {
            print("Failed to clear scan history - \(error.localizedDescription)")
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
        .background(Color.ffBackground)
}
