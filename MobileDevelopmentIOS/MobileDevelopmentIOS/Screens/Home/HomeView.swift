//
//  HomeView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: FFTab

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanRecord.timestamp, order: .reverse) private var scanRecords: [ScanRecord]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? {
        profiles.first
    }

    private var stats: [StatItem] {
        [
            StatItem(value: "\(scansThisWeek)", label: "Scans this week"),
            StatItem(value: "74%", label: "Game accuracy"),
            StatItem(value: "\(profile?.currentStreak ?? 0)", label: "Day streak")
        ]
    }

    private var recentScans: [ScanRecord] {
        Array(scanRecords.prefix(2))
    }

    private var scansThisWeek: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)

        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            return scanRecords.count
        }

        return scanRecords.filter { $0.timestamp >= weekStart }.count
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Welcome back")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ffTextPrimary)
                    .padding(.top, 8)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                SectionLabel(title: "Quick Actions")
                HStack(spacing: 10) {
                    QuickActionCard(systemImage: "camera.viewfinder", title: "Detector") {
                        selectedTab = .detector
                    }
                    QuickActionCard(systemImage: "gamecontroller.fill", title: "Play Game") {
                        selectedTab = .game
                    }
                }

                SectionLabel(title: "At-a-Glance Stats")
                Stats3Grid(items: stats)

                SectionLabel(title: "Recent Activity")
                VStack(spacing: 10) {
                    ForEach(recentScans, id: \.id) { record in
                        HistoryRow(
                            filename: record.imageFileName,
                            timestamp: dateFormatter.string(from: record.timestamp),
                            badgeText: "\(Int((record.aiProbability * 100).rounded()))%",
                            secondaryBadge: record.verdictLabel
                        )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .onAppear {
            recordDailyActivity()
        }
    }

    private func recordDailyActivity(now: Date = .now) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let userProfile: UserProfile
        if let profile {
            userProfile = profile
        } else {
            let created = UserProfile(
                currentStreak: 1,
                longestStreak: 1,
                lastActiveDay: today
            )
            modelContext.insert(created)

            do {
                try modelContext.save()
            } catch {
                print("Failed to create user profile - \(error.localizedDescription)")
            }
            return
        }

        let lastActive = calendar.startOfDay(for: userProfile.lastActiveDay)
        if calendar.isDate(lastActive, inSameDayAs: today) {
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastActive, inSameDayAs: yesterday) {
            userProfile.currentStreak += 1
        } else {
            userProfile.currentStreak = 1
        }

        userProfile.longestStreak = max(userProfile.longestStreak, userProfile.currentStreak)
        userProfile.lastActiveDay = today

        do {
            try modelContext.save()
        } catch {
            print("Failed to update daily activity - \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .modelContainer(for: [ScanRecord.self, UserProfile.self], inMemory: true)
        .background(Color.ffBackground)
}
