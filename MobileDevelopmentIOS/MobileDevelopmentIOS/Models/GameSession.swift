//
//  GameSession.swift
//  MobileDevelopmentIOS


import Foundation
import SwiftData

@Model
class GameSession {
    var userId: UUID
    var totalSwipes: Int
    var correctGuesses: Int
    
    init(id: UUID = UUID(), totalSwipes: Int = 0, correctGuesses: Int = 0) {
        self.userId = id
        self.totalSwipes = totalSwipes
        self.correctGuesses = correctGuesses
    }
}
