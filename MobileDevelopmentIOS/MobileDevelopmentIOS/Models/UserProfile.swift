import Foundation
import SwiftData

/**
 * UserProfile model using SwiftData
 * This model is used to store the user's profile data
 */
@Model
class UserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var seenGameCardIDs: [String]
    var currentStreak: Int = 1
    var longestStreak: Int = 1
    var lastActiveDay: Date = Date()
    var imagesAnalyzed: Int

    init(
        id: UUID = UUID(),
        displayName: String = "User",
        seenGameCardIDs: [String] = [],
        currentStreak: Int = 1,
        longestStreak: Int = 1,
        lastActiveDay: Date = .now,
        imagesAnalyzed: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.seenGameCardIDs = seenGameCardIDs
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDay = lastActiveDay
        self.imagesAnalyzed = imagesAnalyzed
    }
}
