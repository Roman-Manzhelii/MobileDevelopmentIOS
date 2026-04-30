import Foundation
import SwiftData

/**
 * UserProfile model using SwiftData
 * This model is used to store the user's profile data
 */

@Model
class UserProfile {
    @Attribute(.unique) var id: UUID
    var seenGameCardIDs: [String]
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDay: Date
    var imagesAnalyzed: Int

    init(id: UUID = UUID(), seenGameCardIDs: [String] = [], currentStreak: Int = 0, longestStreak: Int = 0, lastActiveDay: Date = .now, imagesAnalyzed: Int = 0) {
        self.id = id
        self.seenGameCardIDs = seenGameCardIDs
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDay = lastActiveDay
        self.imagesAnalyzed = imagesAnalyzed
    }
}