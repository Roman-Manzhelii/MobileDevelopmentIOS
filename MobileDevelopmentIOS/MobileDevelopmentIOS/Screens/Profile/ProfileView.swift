//
//  ProfileView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI

struct ProfileView: View {
    private let metrics: [MetricItem] = [
        MetricItem(value: "47", label: "Images Analyzed"),
        MetricItem(value: "132", label: "Cards Swiped"),
        MetricItem(value: "5🔥", label: "Day Streak"),
        MetricItem(value: "72%", label: "Accuracy"),
        MetricItem(value: "95", label: "Correct Swipes"),
        MetricItem(value: "37", label: "Wrong Swipes")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile & Stats")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.ffTextPrimary)
                    Text("Screen 5 — Gamification & Settings")
                        .font(.caption)
                        .foregroundStyle(Color.ffTextMuted)
                }
                .padding(.top, 8)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                userRow

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                SectionLabel(title: "Overall Game Accuracy")
                AccuracyRing(progress: 0.72)

                SectionLabel(title: "Metrics")
                MetricsGrid(items: metrics)

                Text("● All metrics from SwiftData GameStat + ScanHistory")
                    .font(.caption2)
                    .foregroundStyle(Color.ffTextMuted)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
    }

    private var userRow: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ffElevated)
                .frame(width: 62, height: 62)
                .overlay(
                    Text("👤")
                        .font(.title)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("User Name")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ffTextPrimary)
                    Badge(text: "1")
                }
                Text("Member since Jan 2026")
                    .font(.caption)
                    .foregroundStyle(Color.ffTextMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ffCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    ProfileView()
        .background(Color.ffBackground)
}
