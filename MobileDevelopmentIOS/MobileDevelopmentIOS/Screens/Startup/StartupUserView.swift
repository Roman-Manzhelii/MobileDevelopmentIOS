import SwiftUI
import SwiftData

struct StartupUserView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Query(sort: \UserProfile.displayName) private var profiles: [UserProfile]

    @State private var newUserName = ""
    @State private var createUserError = ""
    @State private var isCreatingUser = false

    var body: some View {
        ZStack {
            Color.ffBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Spacer()
                        Image("FakeFinder")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        Spacer()
                    }
                    .padding(.top, 8)

                    Text("Welcome")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.ffTextPrimary)

                    Rectangle()
                        .fill(Color.ffBorder)
                        .frame(height: 1)

                    SectionLabel(title: "Choose a User")

                    if profiles.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(profiles) { profile in
                                Button {
                                    activeUserManager.selectUser(profile)
                                } label: {
                                    HStack {
                                        Text(profile.displayName)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(Color.ffTextPrimary)
                                        Spacer()
                                        Text("Use")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.ffGold)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.ffCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .strokeBorder(Color.ffBorder, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Rectangle()
                        .fill(Color.ffBorder)
                        .frame(height: 1)

                    SectionLabel(title: "Create New User")

                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Enter user name", text: $newUserName)
                            .textInputAutocapitalization(.words)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.ffCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.ffBorder, lineWidth: 1)
                                    )
                            )

                        Button(isCreatingUser ? "Creating..." : "Create User") {
                            Task {
                                await createUser()
                            }
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ffTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.ffGold.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.ffGold, lineWidth: 1)
                                )
                        )
                        .buttonStyle(.plain)
                        .disabled(isCreatingUser)
                        .opacity(isCreatingUser ? 0.7 : 1)

                        if !createUserError.isEmpty {
                            Text(createUserError)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }
        }
    }

    private var emptyState: some View {
        Text("No users yet. Create one below.")
            .font(.subheadline)
            .foregroundStyle(Color.ffTextMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.ffCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.ffBorder, lineWidth: 1)
                    )
            )
    }

    @MainActor
    private func createUser() async {
        guard !isCreatingUser else { return }

        let trimmedName = newUserName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            createUserError = "Please enter a user name."
            return
        }

        isCreatingUser = true
        createUserError = ""

        do {
            let store = UserProfileStore(modelContainer: modelContext.container)
            let userID = try await store.createUser(displayName: trimmedName)
            newUserName = ""
            isCreatingUser = false
            activeUserManager.selectUser(id: userID)
            return
        } catch {
            createUserError = "Could not create user. Please try again."
            print("Failed to create user- \(error.localizedDescription)")
        }

        isCreatingUser = false
    }
}

#Preview {
    StartupUserView()
        .environmentObject(ActiveUserManager())
        .background(Color.ffBackground)
}
