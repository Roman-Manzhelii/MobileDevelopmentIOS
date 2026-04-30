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

    func recordDailyActivity(using modelContext: ModelContext, now: Date = .now) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let profile: UserProfile

            if let existing = try modelContext.fetch(descriptor).first {
                profile = existing
            } else {
                let created = UserProfile(
                    currentStreak: 1,
                    longestStreak: 1,
                    lastActiveDay: today
                )
                modelContext.insert(created)
                try modelContext.save()
                return
            }

            let lastActive = calendar.startOfDay(for: profile.lastActiveDay)
            if calendar.isDate(lastActive, inSameDayAs: today) {
                return
            }

            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                calendar.isDate(lastActive, inSameDayAs: yesterday) {
                profile.currentStreak += 1
            } else {
                profile.currentStreak = 1
            }

            profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
            profile.lastActiveDay = today
            try modelContext.save()
        } catch {
            print("Failed to update daily activity- \(error.localizedDescription)")
        }
    }

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