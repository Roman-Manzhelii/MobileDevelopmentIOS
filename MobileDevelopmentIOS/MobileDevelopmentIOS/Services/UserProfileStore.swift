import Foundation
import SwiftData

@ModelActor
actor UserProfileStore {
    func createUser(displayName: String) throws -> UUID {
        let profile = UserProfile(displayName: displayName, currentStreak: 1)
        modelContext.insert(profile)
        try modelContext.save()
        return profile.id
    }
}
