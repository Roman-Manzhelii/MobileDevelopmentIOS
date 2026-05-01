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
    @State private var records: [ScanRecord] = []
    @State private var didLoadRecords = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter
    }()

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

                LazyVStack(spacing: 10) {
                    ForEach(records, id: \.id) { record in
                        HistoryRow(
                            timestamp: dateFormatter.string(from: record.timestamp),
                            verdict: record.displayVerdictLabel,
                            imageData: record.imageData
                        )
                    }
                }

                if !didLoadRecords {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                } else if records.isEmpty {
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
        .task(id: activeUserManager.activeUserID) {
            await loadRecordsAfterFirstFrame()
        }
    }

    @MainActor
    private func loadRecordsAfterFirstFrame() async {
        didLoadRecords = false
        await Task.yield()
        loadRecords()
    }

    private func loadRecords() {
        var descriptor: FetchDescriptor<ScanRecord>

        if let selectedUUID = activeUserManager.selectedUserUUID {
            let selectedUserID = Optional(selectedUUID)
            descriptor = FetchDescriptor<ScanRecord>(
                predicate: #Predicate<ScanRecord> { record in
                    record.userProfileID == selectedUserID
                },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<ScanRecord>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        }

        do {
            records = try modelContext.fetch(descriptor)
        } catch {
            records = []
            print("Failed to load scan history - \(error.localizedDescription)")
        }

        didLoadRecords = true
    }

    private func clearAll() {
        do {
            for record in records {
                modelContext.delete(record)
            }
            try modelContext.save()
            records.removeAll()
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
