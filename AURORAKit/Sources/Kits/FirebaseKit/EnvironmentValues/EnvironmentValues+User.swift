import SwiftUI

// MARK: - UserEnvironmentKey

/// A User EnvironmentKey
private struct UserEnvironmentKey: EnvironmentKey {
    
    /// The default value for the environment key.
    static var defaultValue: User?
    
}

// MARK: - EnvironmentValues+user

public extension EnvironmentValues {
    
    /// The current User, if available.
    var user: User? {
        get {
            self[UserEnvironmentKey.self]
        }
        set {
            self[UserEnvironmentKey.self] = newValue
        }
    }
    
}
