import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    init() {
        // Load user data if available
        loadUserData()
    }
    
    private func loadUserData() {
        // Here you would typically load user data from UserDefaults or a persistence store
        // For now, we'll create a default user
        currentUser = User(
            name: "Demo User",
            email: "demo@example.com"
        )
    }
    
    func signIn(email: String, password: String) async throws {
        // Implement sign in logic
        isAuthenticated = true
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) {
        currentUser?.preferences = preferences
        // Save updated preferences
    }
} 