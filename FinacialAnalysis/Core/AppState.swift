import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    init() {
        // Initialize app state
    }
} 