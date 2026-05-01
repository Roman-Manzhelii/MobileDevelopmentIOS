import Foundation
import SwiftData

enum HomeManager {
    @MainActor
    static func recordDailyActivity(using modelContext: ModelContext, activeUserID: String = "", now: Date = .now) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        do {
            guard let profile = try selectedProfile(using: modelContext, activeUserID: activeUserID) else {
                let created = UserProfile(
                    displayName: "User",
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

    private static func selectedProfile(using modelContext: ModelContext, activeUserID: String) throws -> UserProfile? {
        if let selectedUUID = UUID(uuidString: activeUserID) {
            var descriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate<UserProfile> { profile in
                    profile.id == selectedUUID
                }
            )
            descriptor.fetchLimit = 1

            if let selectedProfile = try modelContext.fetch(descriptor).first {
                return selectedProfile
            }
        }

        var fallbackDescriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.displayName)]
        )
        fallbackDescriptor.fetchLimit = 1
        return try modelContext.fetch(fallbackDescriptor).first
    }
}
