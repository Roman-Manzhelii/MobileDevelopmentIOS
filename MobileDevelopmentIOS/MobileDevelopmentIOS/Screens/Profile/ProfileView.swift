//
//  ProfileView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var statsManager = StatsManager()

    private var profile: UserProfile? {
        activeUserManager.selectedProfile(using: modelContext)
    }

    private var accuracyPercentText: String {
        "\(Int((statsManager.accuracyProgress * 100).rounded()))%"
    }

    private var displayName: String {
        guard let profile else { return "User" }
        return profile.displayName
    }

    private var levelText: String {
        let level = max(1, ((profile?.imagesAnalyzed ?? 0) / 25) + 1)
        return "\(level)"
    }

    private var metrics: [MetricItem] {
        [
            MetricItem(value: "\(profile?.imagesAnalyzed ?? 0)", label: "Images Analyzed"),
            MetricItem(value: "\(statsManager.scansCount)", label: "Cards Swiped"),
            MetricItem(value: "\(statsManager.dayStreak)🔥", label: "Day Streak"),
            MetricItem(value: accuracyPercentText, label: "Accuracy"),
            MetricItem(value: "\(statsManager.correctSwipes)", label: "Correct Swipes"),
            MetricItem(value: "\(statsManager.wrongSwipes)", label: "Wrong Swipes")
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile & Stats")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.ffTextPrimary)
                }
                .padding(.top, 8)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                userRow
                Button("Change User") {
                    activeUserManager.clearActiveUser()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ffTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.ffCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.ffBorder, lineWidth: 1)
                        )
                )
                .buttonStyle(.plain)

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                SectionLabel(title: "Overall Game Accuracy")
                AccuracyRing(progress: statsManager.accuracyProgress)

                SectionLabel(title: "Metrics")
                MetricsGrid(items: metrics)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .onAppear {
            statsManager.refreshStats(using: modelContext, activeUserID: activeUserManager.activeUserID)
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
                    Text(displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ffTextPrimary)
                    Badge(text: levelText)
                }
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
        .environmentObject(ActiveUserManager())
        .background(Color.ffBackground)
}
