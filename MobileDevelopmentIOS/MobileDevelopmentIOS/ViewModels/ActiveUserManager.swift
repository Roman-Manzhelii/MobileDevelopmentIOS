import Foundation
import SwiftData
import Combine

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

    func selectUser(id: UUID) {
        activeUserID = id.uuidString
    }

    func clearActiveUser() {
        activeUserID = ""
    }

    func selectedProfile(using modelContext: ModelContext) -> UserProfile? {
        do {
            if let selectedUserUUID = selectedUserUUID {
                var selectedDescriptor = FetchDescriptor<UserProfile>(
                    predicate: #Predicate<UserProfile> { profile in
                        profile.id == selectedUserUUID
                    }
                )
                selectedDescriptor.fetchLimit = 1

                if let selectedProfile = try modelContext.fetch(selectedDescriptor).first {
                    return selectedProfile
                }
            }

            var fallbackDescriptor = FetchDescriptor<UserProfile>(
                sortBy: [SortDescriptor(\.displayName)]
            )
            fallbackDescriptor.fetchLimit = 1
            return try modelContext.fetch(fallbackDescriptor).first
        } catch {
            print("Failed to load selected user- \(error.localizedDescription)")
            return nil
        }
    }
}
