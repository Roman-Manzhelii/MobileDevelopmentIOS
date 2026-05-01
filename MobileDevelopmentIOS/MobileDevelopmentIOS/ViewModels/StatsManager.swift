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
    @Published private(set) var cardsSwipes = 0
    
    @Published private(set) var stats: [StatItem] = [
        StatItem(value: "0", label: "Scans this week"),
        StatItem(value: "0%", label: "Game accuracy"),
        StatItem(value: "0🔥", label: "Day streak")
    ]

    func refreshStats(using modelContext: ModelContext, activeUserID: String = "") {
        do {
            let allScans = try modelContext.fetch(FetchDescriptor<ScanRecord>())
            let allProfiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
            let allGameSessions = try modelContext.fetch(FetchDescriptor<GameSession>())
            let selectedUUID = UUID(uuidString: activeUserID)
            guard let profile = allProfiles.first(where: { $0.id == selectedUUID }) ?? allProfiles.first else {
                print("No profile found to attach session to.")
                return
            }
            let recentScans = allScans.filter { record in
                guard let selectedUUID else { return true }
                return record.userProfileID == selectedUUID
            }
                
            guard let gameSession = allGameSessions.first(where: { $0.userId == selectedUUID }) ?? allGameSessions.first else {
                let newSession = GameSession(id: profile.id, totalSwipes: 0, correctGuesses: 0)
                modelContext.insert(newSession)
                try modelContext.save()
                return
                }
            
            let scansThisWeek = recentScans.count
            print("gamesession correct- \(gameSession.correctGuesses)")
            print("gamesession total- \(gameSession.totalSwipes)")
            print("gamesession id \(gameSession.id)")
            
            var accuracyPercentage = 0.0
            if (gameSession.totalSwipes != 0){
                accuracyPercentage = Double(gameSession.correctGuesses)/Double(gameSession.totalSwipes)
            }
            
            let streak = profile.currentStreak
            let correct = gameSession.correctGuesses
            let wrong = (gameSession.totalSwipes - gameSession.correctGuesses)
            
            self.scansCount = scansThisWeek
            self.accuracyProgress = accuracyPercentage
            self.dayStreak = streak
            self.correctSwipes = correct
            self.wrongSwipes = wrong
            self.cardsSwipes = gameSession.totalSwipes

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
