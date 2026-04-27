import Foundation
import SwiftData
import Combine

@MainActor
final class HomeManager: ObservableObject {
    struct RecentScanItem: Identifiable {
        let id: UUID
        let filename: String
        let timestamp: String
        let badgePrimary: String
        let badgeSecondary: String?
    }

    @Published private(set) var recentActivity: [RecentScanItem] = []

    let stats: [StatItem] = [
        StatItem(value: "12", label: "Scans this week"),
        StatItem(value: "74%", label: "Game accuracy"),
        StatItem(value: "3🔥", label: "Day streak")
    ]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy · h:mm a"
        return f
    }()

    func loadRecent(using modelContext: ModelContext, limit: Int = 2) {
        var descriptor = FetchDescriptor<ScanRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        descriptor.fetchLimit = limit

        do {
            let records = try modelContext.fetch(descriptor)
            recentActivity = records.map { record in
                RecentScanItem(
                    id: record.id,
                    filename: record.imageFileName,
                    timestamp: dateFormatter.string(from: record.timestamp),
                    badgePrimary: "\(Int((record.aiProbability * 100).rounded()))%",
                    badgeSecondary: record.verdictLabel
                )
            }
        } catch {
            recentActivity = []
            print("Failed loading home recent activity- \(error.localizedDescription)")
        }
    }
}