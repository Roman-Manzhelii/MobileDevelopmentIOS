//
//  FakeFinderApp.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import SwiftUI
import SwiftData

@main
struct FakeFinderApp: App {
    @StateObject private var activeUserManager = ActiveUserManager()

    private let modelContainer: ModelContainer
    init() {
        do {
            let schema = Schema([
                ScanRecord.self, 
                GameSession.self, 
                UserProfile.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer \(error)")
        }
    }
    var body: some Scene {
        WindowGroup {
            if activeUserManager.activeUserID.isEmpty {
                StartupUserView()
            } else {
                MainView()
            }
        }
        .environmentObject(activeUserManager)
        .modelContainer(modelContainer)
    }
}
