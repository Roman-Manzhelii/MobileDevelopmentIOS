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
    
    init(id: UUID = UUID(), seenGameCardIDs: [String] = []) {
        self.id = id
        self.seenGameCardIDs = seenGameCardIDs
    }
}