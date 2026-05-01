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
    @StateObject private var statsManager = StatsManager()
    @State private var recentScans: [ScanRecord] = []
    @State private var didLoadRecentScans = false

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
                recentActivityContent
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .task(id: activeUserManager.activeUserID) {
            await refreshHomeDataAfterFirstFrame()
        }
    }

    @MainActor
    private func refreshHomeDataAfterFirstFrame() async {
        didLoadRecentScans = false
        await Task.yield()

        HomeManager.recordDailyActivity(using: modelContext, activeUserID: activeUserManager.activeUserID)
        loadRecentScans()
        statsManager.refreshStats(using: modelContext, activeUserID: activeUserManager.activeUserID)
        GameStreakReminderService.shared.showLaunchReminderIfPossible()
    }

    private func loadRecentScans() {
        var descriptor: FetchDescriptor<ScanRecord>

        if let selectedUUID = activeUserManager.selectedUserUUID {
            let selectedUserID = Optional(selectedUUID)
            descriptor = FetchDescriptor<ScanRecord>(
                predicate: #Predicate<ScanRecord> { record in
                    record.userProfileID == selectedUserID
                },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        } else {
            descriptor = FetchDescriptor<ScanRecord>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        }

        descriptor.fetchLimit = 2

        do {
            recentScans = try modelContext.fetch(descriptor)
        } catch {
            recentScans = []
            print("Failed loading recent scans- \(error.localizedDescription)")
        }

        didLoadRecentScans = true
    }

    @ViewBuilder
    private var recentActivityContent: some View {
        if !didLoadRecentScans {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 32)
        } else if recentScans.isEmpty {
            recentActivityEmptyState
        } else {
            VStack(spacing: 10) {
                ForEach(recentScans, id: \.id) { record in
                    HistoryRow(
                        timestamp: dateFormatter.string(from: record.timestamp),
                        verdict: record.displayVerdictLabel,
                        imageData: record.imageData
                    )
                }
            }
        }
    }

    private var recentActivityEmptyState: some View {
        Text("No scans yet")
            .font(.subheadline)
            .foregroundStyle(Color.ffTextMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(ActiveUserManager())
        .modelContainer(for: [ScanRecord.self, UserProfile.self], inMemory: true)
        .background(Color.ffBackground)
}
