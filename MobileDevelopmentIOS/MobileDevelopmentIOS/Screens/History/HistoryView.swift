//
//  HistoryView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanRecord.timestamp, order: .reverse) private var records: [ScanRecord]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter
    }()

    private var filteredRecords: [ScanRecord] {
        guard let selectedUUID = activeUserManager.selectedUserUUID else {
            return records
        }
        return records.filter { $0.userProfileID == selectedUUID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScreenHeader(
                    title: "Scan History",
                    subtitle: "Review and manage your previous scans"
                ) {
                    OutlineButton(title: "Clear All") {
                        clearAll()
                    }
                }

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                VStack(spacing: 10) {
                    ForEach(filteredRecords, id: \.id) { record in
                        HistoryRow(
                            timestamp: dateFormatter.string(from: record.timestamp),
                            verdict: record.verdictLabel,
                            imageData: record.imageData
                        )
                    }
                }

                if filteredRecords.isEmpty {
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
            for record in filteredRecords {
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
        .environmentObject(ActiveUserManager())
        .modelContainer(for: ScanRecord.self, inMemory: true)
        .background(Color.ffBackground)
}
