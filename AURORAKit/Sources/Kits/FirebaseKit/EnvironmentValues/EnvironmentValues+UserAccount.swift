import SwiftUI

// MARK: - UserAccountEnvironmentKey

/// A User Account EnvironmentKey
private struct UserAccountEnvironmentKey: EnvironmentKey {
    
    /// The default value for the environment key.
    static var defaultValue: UserAccount?
    
}

// MARK: - EnvironmentValues+user

public extension EnvironmentValues {
    
    /// The current User Account, if available.
    var userAccount: UserAccount? {
        get {
            self[UserAccountEnvironmentKey.self]
        }
        set {
            self[UserAccountEnvironmentKey.self] = newValue
        }
    }
    
}
