import FirebaseAuth
import SwiftUI

// MARK: - UserEnvironmentKey

/// A User EnvironmentKey
private struct FirebaseUserEnvironmentKey: EnvironmentKey {
    
    /// The default value for the environment key.
    static var defaultValue: FirebaseAuth.User?
    
}

// MARK: - EnvironmentValues+user

public extension EnvironmentValues {
    
    /// The current Firebase User, if available.
    var firebaseUser: FirebaseAuth.User? {
        get {
            self[FirebaseUserEnvironmentKey.self]
        }
        set {
            self[FirebaseUserEnvironmentKey.self] = newValue
        }
    }
    
}
