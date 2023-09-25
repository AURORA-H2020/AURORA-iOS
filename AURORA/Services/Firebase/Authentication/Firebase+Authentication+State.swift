import Foundation

// MARK: - State

extension Firebase.Authentication {
    
    /// A Firebase Authentication State
    enum State: Hashable {
        /// Authenticated
        case authenticated(User.Account)
        /// Unauthenticated
        case unauthenticated
    }
    
}

// MARK: - Display Name Components

extension Firebase.Authentication.State {
    
    /// The display name components.
    static var displayNameComponents: PersonNameComponents?
    
    /// The preferred display name components.
    static var preferredDisplayNameComponents: PersonNameComponents? {
        if let displayNameComponents = self.displayNameComponents {
            self.displayNameComponents = nil
            return displayNameComponents
        } else if let userAccount = try? Firebase.default.authentication.state.userAccount,
                  let displayName = userAccount.displayName {
            let displayNameComponents = displayName.components(separatedBy: " ")
            return .init(
                givenName: displayNameComponents.first,
                familyName: displayNameComponents.last
            )
        } else {
            return nil
        }
    }
    
}

// MARK: - State+isAuthenticated

extension Firebase.Authentication.State {
    
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

extension Firebase.Authentication.State {
    
    /// An Firebase AuthenticationState unauthenticated Error
    struct UnauthenticatedError: Error {}
    
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
