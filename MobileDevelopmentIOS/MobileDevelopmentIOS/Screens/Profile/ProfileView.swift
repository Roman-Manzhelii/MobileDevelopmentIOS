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
    @State private var profile: UserProfile?
    @AppStorage("haptics_enabled") private var hapticsEnabled = true

    private var accuracyPercentText: String {
        "\(Int((statsManager.accuracyProgress * 100).rounded()))%"
    }

    private var displayName: String {
        guard let profile else { return "User" }
        return profile.displayName
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

                HStack(alignment: .center, spacing: 10) {
                    userRow
                    hapticsButton
                }
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
        .task(id: activeUserManager.activeUserID) {
            await refreshProfileDataAfterFirstFrame()
        }
    }

    @MainActor
    private func refreshProfileDataAfterFirstFrame() async {
        await Task.yield()

        profile = activeUserManager.selectedProfile(using: modelContext)
        statsManager.refreshStats(using: modelContext, activeUserID: activeUserManager.activeUserID)
    }

    private var userRow: some View {
        HStack(alignment: .center, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ffElevated)
                .frame(width: 58, height: 58)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.ffTextPrimary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ffBorder, lineWidth: 1)
                )

            Text(displayName)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ffTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 92)
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
            VStack(spacing: 8) {
                Image(systemName: hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(hapticsEnabled ? Color.ffGold : Color.ffTextMuted)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.ffElevated)
                    )

                Text("Haptics \(hapticsEnabled ? "On" : "Off")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.ffTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(12)
            .frame(width: 112)
            .frame(minHeight: 92)
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
