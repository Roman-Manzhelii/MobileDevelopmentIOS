//
//  GameStreakReminderService.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 01/05/2026.
//

import Foundation
import UserNotifications

final class GameStreakReminderService {
    static let shared = GameStreakReminderService()

    private let center = UNUserNotificationCenter.current()
    private let launchReminderIdentifier = "game-streak-launch-reminder"
    private var didHandleLaunchReminder = false

    private init() {}

    func showLaunchReminderIfPossible() {
        guard !didHandleLaunchReminder else {
            return
        }

        didHandleLaunchReminder = true

        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermissionAndScheduleIfAllowed()
            case .authorized, .provisional, .ephemeral:
                self.scheduleLaunchReminder()
            case .denied:
                return
            @unknown default:
                return
            }
        }
    }

    private func requestPermissionAndScheduleIfAllowed() {
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            if let error {
                print("Failed to request notification permission - \(error.localizedDescription)")
                return
            }

            guard granted else {
                return
            }

            self?.scheduleLaunchReminder()
        }
    }

    private func scheduleLaunchReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [launchReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Keep your streak going"
        content.body = "Play a quick round today to keep your streak going."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: launchReminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Failed to schedule game streak reminder - \(error.localizedDescription)")
            }
        }
    }
}
