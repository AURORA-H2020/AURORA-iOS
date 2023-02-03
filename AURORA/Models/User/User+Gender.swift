import SwiftUI

// MARK: - User+Gender

extension User {
    
    /// A Gender
    enum Gender: String, Codable, Hashable, CaseIterable, Sendable {
        /// Male
        case male
        /// Female
        case female
        /// Non binary
        case nonBinary
        /// Other
        case other
    }
    
}

// MARK: - Localized String

extension User.Gender {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .male:
            return .init(localized: "Male")
        case .female:
            return .init(localized: "Female")
        case .nonBinary:
            return .init(localized: "Non Binary")
        case .other:
            return .init(localized: "Other")
        }
    }
    
}
