import SwiftUI

private struct UserEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: User?
    
}

public extension EnvironmentValues {
    
    var user: User? {
        get {
            self[UserEnvironmentKey.self]
        }
        set {
            self[UserEnvironmentKey.self] = newValue
        }
    }
    
}
