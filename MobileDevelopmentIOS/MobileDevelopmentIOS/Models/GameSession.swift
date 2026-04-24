//
//  GameSession.swift
//  MobileDevelopmentIOS


import Foundation
import SwiftData

@Model
class GameSession {
    var id: UUID
    var totalSwipes: Int
    var correctGuesses: Int
    var datePlayed: Date
    
    init(id: UUID = UUID(), totalSwipes: Int = 0, correctGuesses: Int = 0, datePlayed: Date = .now) {
        self.id = id
        self.totalSwipes = totalSwipes
        self.correctGuesses = correctGuesses
        self.datePlayed = datePlayed
    }
}