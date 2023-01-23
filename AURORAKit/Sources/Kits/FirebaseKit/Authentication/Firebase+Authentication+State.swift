import Foundation

// MARK: - State

public extension Firebase.Authentication {
    
    /// A Firebase Authentication State
    enum State: Hashable {
        /// Authenticated
        case authenticated(User.Account)
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
    struct UnauthenticatedError: Error {
        
        /// Creates a new instance of `Firebase.Authentication.State.UnauthenticatedError`
        public init() {}
        
    }
    
    /// The user account.
    /// Otherwise throws an `Firebase.Authentication.State.UnauthenticatedError`
    var userAccount: User.Account {
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
