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
    var hapticsEnabled: Bool

    init(
        id: UUID = UUID(),
        seenGameCardIDs: [String] = [],
        hapticsEnabled: Bool = true
    ) {
        self.id = id
        self.seenGameCardIDs = seenGameCardIDs
        self.hapticsEnabled = hapticsEnabled
    }
}