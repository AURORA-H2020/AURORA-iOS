import Foundation

// MARK: - State

public extension Firebase.Authentication {
    
    /// A Firebase Authentication State
    enum State: Hashable {
        /// Authenticated
        case authenticated(UserAccount)
        /// Unauthenticated
        case unauthenticated
    }
    
}

// MARK: - State+isAuthenticated

public extension Firebase.Authentication.State {
    
    /// Bool value if authentication state is `authenticated`
    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: - State+userAccount

public extension Firebase.Authentication.State {
    
    /// An Firebase AuthenticationState unauthenticated Error
    struct UnauthenticatedError: Error {}
    
    /// The user account.
    /// Otherwise throws an `Firebase.Authentication.State.UnauthenticatedError`
    var userAccount: UserAccount {
        get throws {
            switch self {
            case .authenticated(let userAccount):
                return userAccount
            case .unauthenticated:
                throw UnauthenticatedError()
            }
        }
    }
    
}
