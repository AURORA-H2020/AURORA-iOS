import FirebaseAuth
import Foundation

// MARK: - Firebase+AuthenticationState

public extension Firebase {
    
    /// An AuthenticationState
    enum AuthenticationState: Hashable {
        /// Authenticated
        case authenticated(FirebaseAuth.User)
        /// Unauthenticated
        case unauthenticated
    }
    
}

// MARK: - Firebase+AuthenticationState+isAuthenticated

public extension Firebase.AuthenticationState {
    
    /// Bool value if authentication state is `authenticated`
    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: - Firebase+AuthenticationState+user

public extension Firebase.AuthenticationState {
    
    /// An Firebase AuthenticationState unauthenticated Error
    struct UnauthenticatedError: Error {}
    
    /// The FirebaseAuth User, if available
    /// Otherwise throws an `Firebase.AuthenticationState.UnauthenticatedError`
    var user: FirebaseAuth.User {
        get throws {
            switch self {
            case .authenticated(let user):
                return user
            case .unauthenticated:
                throw UnauthenticatedError()
            }
        }
    }
    
}

// MARK: - Firebase+authenticationState

public extension Firebase {
    
    /// The AuthenticationState
    var authenticationState: AuthenticationState {
        self.auth.currentUser.flatMap { .authenticated($0) } ?? .unauthenticated
    }
    
}

// MARK: - Firebase+login

public extension Firebase {
    
    /// A Firebase Authentication Method
    enum AuthenticationMethod {
        /// Password
        case password(email: String, password: String)
    }
    
    /// Login user using a given AuthenticationMethod
    /// - Parameter authenticationMode: The AuthenticationMode used to login the user.
    @discardableResult
    func login(
        using authenticationMode: AuthenticationMethod
    ) async throws -> FirebaseAuth.AuthDataResult {
        switch authenticationMode {
        case .password(let email, let password):
            do {
                return try await self.auth
                    .signIn(
                        withEmail: email,
                        password: password
                    )
            } catch let error as AuthErrorCode where error.code == .userNotFound {
                return try await self.auth
                    .createUser(
                        withEmail: email,
                        password: password
                    )
            } catch {
                throw error
            }
        }
    }
    
}

// MARK: - Firebase+logout

public extension Firebase {
    
    /// Logout the currently authenticated user.
    func logout() throws {
        _ = try self.authenticationState.user
        try self.auth.signOut()
    }
    
}

// MARK: - Firebase+deleteAccount

public extension Firebase {
    
    /// Delete the currently authenticated user account.
    func deleteAccount() async throws {
        try await self.authenticationState.user.delete()
        self.user = nil
        self.userDocumentSnapshotSubscription?.remove()
        self.userDocumentSnapshotSubscription = nil
    }
    
}
