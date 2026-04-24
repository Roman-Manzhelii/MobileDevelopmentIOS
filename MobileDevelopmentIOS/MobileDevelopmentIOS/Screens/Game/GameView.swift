//
//  GameView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

struct GameView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    
    @State private var gameManager = GameManager()
    
    var body: some View {
        VStack {
            Text("Swipe Game")
        }
    }
    
    // Get the unseen cards. Don't show the cards that the user has already seen.
    private func getUnseenCards() -> [GameCard] {
        guard let userProfile = profiles.first else { return gameManager.cards }
        return gameManager.cards.filter { !userProfile.seenGameCardIDs.contains($0.id) }
    }
}