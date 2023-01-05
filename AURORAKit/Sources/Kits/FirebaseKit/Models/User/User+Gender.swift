import Foundation

// MARK: - User+Gender

public extension User {
    
    /// A Gender
    enum Gender: String, Codable, Hashable, CaseIterable {
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
