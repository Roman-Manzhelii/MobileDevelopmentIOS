import Foundation
import SwiftData

enum HomeManager {
    @MainActor
    static func recordDailyActivity(using modelContext: ModelContext, activeUserID: String = "", now: Date = .now) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let allProfiles = try modelContext.fetch(descriptor)
            let profile: UserProfile
            let selectedUUID = UUID(uuidString: activeUserID)

            if let selectedUUID,
               let selectedProfile = allProfiles.first(where: { $0.id == selectedUUID }) {
                profile = selectedProfile
            } else if let existing = allProfiles.first {
                profile = existing
            } else {
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
}
