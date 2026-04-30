import Foundation
import SwiftData
import Combine

@MainActor
class StatsManager: ObservableObject {
    @Published private(set) var scansCount = 0
    @Published private(set) var accuracyProgress = 0.0
    @Published private(set) var dayStreak = 0
    @Published private(set) var correctSwipes = 0
    @Published private(set) var wrongSwipes = 0

    @Published private(set) var stats: [StatItem] = [
        StatItem(value: "0", label: "Scans this week"),
        StatItem(value: "0%", label: "Game accuracy"),
        StatItem(value: "0🔥", label: "Day streak")
    ]

    func refreshStats(using modelContext: ModelContext, activeUserID: String = "") {
        do {
            let recentScans = try modelContext.fetch(FetchDescriptor<ScanRecord>())
            let allProfiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
            let selectedUUID = UUID(uuidString: activeUserID)
            let profile = allProfiles.first(where: { $0.id == selectedUUID }) ?? allProfiles.first

            let scansThisWeek = recentScans.count
            var totalProbability = 0.0
            for record in recentScans {
                totalProbability += record.aiProbability
            }
            let accuracyPercentage = recentScans.isEmpty ? 0 : totalProbability / Double(recentScans.count)
            let streak = profile?.currentStreak ?? 0
            let correct = Int((Double(scansThisWeek) * accuracyPercentage).rounded())
            let wrong = max(scansThisWeek - correct, 0)

            scansCount = scansThisWeek
            accuracyProgress = accuracyPercentage
            dayStreak = streak
            correctSwipes = correct
            wrongSwipes = wrong

            stats = [
                StatItem(value: "\(scansThisWeek)", label: "Scans this week"),
                StatItem(value: "\(Int((accuracyPercentage * 100).rounded()))%", label: "Game accuracy"),
                StatItem(value: "\(streak)🔥", label: "Day streak")
            ]
        } catch {
            scansCount = 0
            accuracyProgress = 0
            dayStreak = 0
            correctSwipes = 0
            wrongSwipes = 0
            stats = [
                StatItem(value: "0", label: "Scans this week"),
                StatItem(value: "0%", label: "Game accuracy"),
                StatItem(value: "0🔥", label: "Day streak")
            ]
            print("Failed to refresh stats- \(error.localizedDescription)")
        }
    }
}
