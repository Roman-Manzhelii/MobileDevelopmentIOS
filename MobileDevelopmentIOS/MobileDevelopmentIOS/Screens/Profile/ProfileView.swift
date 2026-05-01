//
//  ProfileView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftData
import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var statsManager = StatsManager()
    @AppStorage("haptics_enabled") private var hapticsEnabled = true

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
            MetricItem(value: "\(statsManager.cardsSwipes)", label: "Cards Swiped"),
            MetricItem(value: "\(statsManager.dayStreak)", label: "Day Streak"),
            MetricItem(value: accuracyPercentText, label: "Accuracy"),
            MetricItem(value: "\(statsManager.correctSwipes)", label: "Correct Swipes"),
            MetricItem(value: "\(statsManager.wrongSwipes)", label: "Wrong Swipes")
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScreenHeader(
                    title: "Profile & Stats",
                    subtitle: "Game settings and progress"
                )

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
                
                SectionLabel(title: "Settings")
                hapticsButton

                Text("All metrics come from SwiftData models.")
                    .font(.caption2)
                    .foregroundStyle(Color.ffTextMuted)
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
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(Color.ffTextPrimary)
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

                Text("Current streak: \(profile?.currentStreak ?? 0) days")
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

    private var hapticsButton: some View {
        Button(action: toggleHaptics) {
            HStack(spacing: 14) {
                Image(systemName: hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(hapticsEnabled ? Color.ffGold : Color.ffTextMuted)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.ffElevated)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Haptics")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ffTextPrimary)

                    Text(hapticsEnabled ? "On for wrong guesses" : "Off")
                        .font(.caption)
                        .foregroundStyle(Color.ffTextMuted)
                }

                Spacer(minLength: 0)

                Badge(text: hapticsEnabled ? "On" : "Off")
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
        .buttonStyle(.plain)
    }

    private func toggleHaptics() {
        let shouldEnable = !hapticsEnabled
        hapticsEnabled = shouldEnable

        guard shouldEnable else { return }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    ProfileView()
        .environmentObject(ActiveUserManager())
        .modelContainer(for: [UserProfile.self], inMemory: true)
        .background(Color.ffBackground)
}
