//
//  GameView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//
import SwiftUI
import SwiftData
import Shuffle

struct GameView: View {
    @AppStorage("activeUserID") private var activeUserID = ""
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    
    @State private var gameManager = GameManager()
    
    var body: some View {
        VStack {
            Text("Swipe Game")
        }
    }
    
    // Get the unseen cards. Don't show the cards that the user has already seen.
    private func getUnseenCards() -> [GameCardData] {
        let selectedUUID = UUID(uuidString: activeUserID)
        let userProfile = profiles.first(where: { $0.id == selectedUUID }) ?? profiles.first
        guard let userProfile else { return gameManager.cards }
        return gameManager.cards.filter { !userProfile.seenGameCardIDs.contains($0.id) }
    }
}