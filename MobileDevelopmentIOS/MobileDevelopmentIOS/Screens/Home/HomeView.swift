//
//  HomeView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: FFTab

    @AppStorage("activeUserID") private var activeUserID = ""
    @Environment(\.modelContext) private var modelContext
    @StateObject private var homeManager = HomeManager()
    @StateObject private var statsManager = StatsManager()


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("👋 Welcome back")
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
                    QuickActionCard(systemImage: "rectangle.stack.fill.badge.play", title: "Swiper") {}
                }

                SectionLabel(title: "At-a-Glance Stats")
                Stats3Grid(items: statsManager.stats)

                SectionLabel(title: "Recent Activity")
                VStack(spacing: 10) {
                    ForEach(homeManager.recentActivity) { row in
                        HistoryRow(
                            filename: row.filename,
                            timestamp: row.timestamp,
                            badgeText: row.badgePrimary,
                            secondaryBadge: row.badgeSecondary
                        )
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .onAppear {
            homeManager.recordDailyActivity(using: modelContext, activeUserID: activeUserID)
            statsManager.refreshStats(using: modelContext, activeUserID: activeUserID)
            homeManager.loadRecent(using: modelContext, limit: 2)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .background(Color.ffBackground)
}
