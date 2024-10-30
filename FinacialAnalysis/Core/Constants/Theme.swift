import SwiftUI

enum Theme {
    static let accentColor = Color("AccentColor")
    static let backgroundColor = Color("BackgroundColor")
    static let cardBackground = Color("CardBackground")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    
    static let spacing: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 4
    
    enum FontSize {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 24
    }
} 