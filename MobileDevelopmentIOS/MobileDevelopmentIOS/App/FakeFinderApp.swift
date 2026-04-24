//
//  FakeFinderApp.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI
@main
struct FakeFinderApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [ScanRecord.self, GameSession.self, UserProfile.self])
    }
}
