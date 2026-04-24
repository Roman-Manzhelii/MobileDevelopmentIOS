//
//  GameSession.swift
//  MobileDevelopmentIOS
//
//  Canonical game session metrics model.
//

import Foundation

struct GameSession: Identifiable, Codable, Hashable {
    let id: UUID
    let totalSwipes: Int
    let correctGuesses: Int
    let datePlayed: Date
}
