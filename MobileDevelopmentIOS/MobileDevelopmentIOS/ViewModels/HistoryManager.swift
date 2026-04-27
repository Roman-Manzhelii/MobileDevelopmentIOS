import Foundation
import SwiftData
import Combine

@MainActor
final class HistoryManager: ObservableObject {
    struct ScanItem: Identifiable {
        let id: UUID
        let filename: String
        let timestamp: String
        let badgePrimary: String
        let badgeSecondary: String?
    }

    @Published private(set) var items: [ScanItem] = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter
    }()

    func load(using modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ScanRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let records = try modelContext.fetch(descriptor)
            items = records.map { record in
                ScanItem(
                    id: record.id,
                    filename: record.imageFileName,
                    timestamp: dateFormatter.string(from: record.timestamp),
                    badgePrimary: "\(Int((record.aiProbability * 100).rounded()))%",
                    badgeSecondary: record.verdictLabel
                )
            }
        } catch {
            items = []
        }
    }

    func clearAll(using modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<ScanRecord>()
            let records = try modelContext.fetch(descriptor)
            for record in records {
                modelContext.delete(record)
            }
            try modelContext.save()
            items.removeAll()
        } catch {
            print("Failed to clear scan history- \(error.localizedDescription)")
        }
    }
}