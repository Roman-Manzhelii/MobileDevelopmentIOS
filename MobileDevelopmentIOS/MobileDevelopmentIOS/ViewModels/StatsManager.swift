import Foundation
import SwiftData
import Combine

@MainActor
class StatsManager: ObservableObject {
    @Published private(set) var accuracyProgress = 0.0
    @Published private(set) var dayStreak = 0
    @Published private(set) var correctSwipes = 0
    @Published private(set) var wrongSwipes = 0
    @Published private(set) var cardsSwipes = 0

    @Published private(set) var stats: [StatItem] = [
        StatItem(value: "0", label: "Scans this week"),
        StatItem(value: "0%", label: "Game accuracy"),
        StatItem(value: "0🔥", label: "Day streak")
    ]

    func refreshStats(using modelContext: ModelContext, activeUserID: String = "") {
        do {
            guard let profile = try selectedProfile(using: modelContext, activeUserID: activeUserID) else {
                applyStats(scans: 0, accuracy: 0, streak: 0, correct: 0, wrong: 0, total: 0)
                return
            }

            let scansThisWeek = try scanCount(using: modelContext, userID: profile.id)
            let gameSession = try gameSession(using: modelContext, userID: profile.id)
            let totalSwipes = gameSession?.totalSwipes ?? 0
            let correct = gameSession?.correctGuesses ?? 0
            let wrong = max(totalSwipes - correct, 0)
            let accuracy = totalSwipes == 0 ? 0 : Double(correct) / Double(totalSwipes)

            applyStats(
                scans: scansThisWeek,
                accuracy: accuracy,
                streak: profile.currentStreak,
                correct: correct,
                wrong: wrong,
                total: totalSwipes
            )
        } catch {
            applyStats(scans: 0, accuracy: 0, streak: 0, correct: 0, wrong: 0, total: 0)
            print("Failed to refresh stats- \(error.localizedDescription)")
        }
    }

    private func selectedProfile(using modelContext: ModelContext, activeUserID: String) throws -> UserProfile? {
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

    private func scanCount(using modelContext: ModelContext, userID: UUID) throws -> Int {
        let selectedUserID = Optional(userID)
        let descriptor = FetchDescriptor<ScanRecord>(
            predicate: #Predicate<ScanRecord> { record in
                record.userProfileID == selectedUserID
            }
        )
        return try modelContext.fetchCount(descriptor)
    }

    private func gameSession(using modelContext: ModelContext, userID: UUID) throws -> GameSession? {
        var descriptor = FetchDescriptor<GameSession>(
            predicate: #Predicate<GameSession> { session in
                session.userId == userID
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func applyStats(scans: Int, accuracy: Double, streak: Int, correct: Int, wrong: Int, total: Int) {
        accuracyProgress = accuracy
        dayStreak = streak
        correctSwipes = correct
        wrongSwipes = wrong
        cardsSwipes = total

        stats = [
            StatItem(value: "\(scans)", label: "Scans this week"),
            StatItem(value: "\(Int((accuracy * 100).rounded()))%", label: "Game accuracy"),
            StatItem(value: "\(streak)🔥", label: "Day streak")
        ]
    }
}
