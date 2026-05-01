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
    
    
    func incrementCorrect() {
            totalSwipes += 1
            correctGuesses += 1
        }
    
    func incrementIncorrect() {
            totalSwipes += 1
        }
    
    var accuracyScore: Double {
            guard totalSwipes > 0 else { return 0.0 }
            return (Double(correctGuesses) / Double(totalSwipes)) * 100
        }
}
