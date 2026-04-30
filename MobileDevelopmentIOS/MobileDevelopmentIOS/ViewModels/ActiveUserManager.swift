import Foundation
import SwiftData

class ActiveUserManager: ObservableObject {
    private let storageKey = "activeUserID"

    @Published var activeUserID: String {
        didSet {
            UserDefaults.standard.set(activeUserID, forKey: storageKey)
        }
    }

    init() {
        activeUserID = UserDefaults.standard.string(forKey: storageKey) ?? ""
    }

    var selectedUserUUID: UUID? {
        UUID(uuidString: activeUserID)
    }

    func selectUser(_ profile: UserProfile) {
        activeUserID = profile.id.uuidString
    }

    func clearActiveUser() {
        activeUserID = ""
    }

    func selectedProfile(using modelContext: ModelContext) -> UserProfile? {
        do {
            let profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
            if profiles.isEmpty { return nil }
            if let selectedUserUUID = selectedUserUUID {
                for profile in profiles {
                    if profile.id == selectedUserUUID {
                        return profile
                    }
                }
            }
            return profiles[0]
        } catch {
            print("Failed to load selected user- \(error.localizedDescription)")
            return nil
        }
    }
}
