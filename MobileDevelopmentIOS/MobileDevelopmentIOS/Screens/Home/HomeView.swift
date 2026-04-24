//
//  HomeView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: FFTab

    private let stats: [StatItem] = [
        StatItem(value: "12", label: "Scans this week"),
        StatItem(value: "74%", label: "Game accuracy"),
        StatItem(value: "3🔥", label: "Day streak")
    ]

    private let recentActivity: [(String, String, String)] = [
        ("Image_001.jpg", "Today, 2:14 PM", "85% AI"),
        ("Image_002.jpg", "Today, 11:03 AM", "12% AI")
    ]

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
                Stats3Grid(items: stats)

                SectionLabel(title: "Recent Activity")
                VStack(spacing: 10) {
                    ForEach(recentActivity, id: \.0) { row in
                        HistoryRow(filename: row.0, timestamp: row.1, badgeText: row.2)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .background(Color.ffBackground)
}
