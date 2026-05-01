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

    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var homeManager = HomeManager()
    @StateObject private var statsManager = StatsManager()
    @Query(sort: \ScanRecord.timestamp, order: .reverse) private var scanRecords: [ScanRecord]

    private var filteredScans: [ScanRecord] {
        guard let selectedUUID = activeUserManager.selectedUserUUID else {
            return scanRecords
        }
        return scanRecords.filter { $0.userProfileID == selectedUUID }
    }

    private var recentScans: [ScanRecord] {
        Array(filteredScans.prefix(2))
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScreenHeader(
                    title: "Welcome back",
                    subtitle: "Quick actions and recent scan activity"
                )

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
                Stats3Grid(items: statsManager.stats)

                SectionLabel(title: "Recent Activity")
                VStack(spacing: 10) {
                    ForEach(recentScans, id: \.id) { record in
                        HistoryRow(
                            timestamp: dateFormatter.string(from: record.timestamp),
                            verdict: record.verdictLabel,
                            imageData: record.imageData
                        )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .onAppear {
            homeManager.recordDailyActivity(using: modelContext, activeUserID: activeUserManager.activeUserID)
            statsManager.refreshStats(using: modelContext, activeUserID: activeUserManager.activeUserID)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(ActiveUserManager())
        .modelContainer(for: [ScanRecord.self, UserProfile.self], inMemory: true)
        .background(Color.ffBackground)
}
