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
    
    /// An error that represents that the user is already authenticated
    struct AlreadyAuthenticatedError: Error {}
    
    /// Login user using a given AuthenticationMethod
    /// - Parameter authenticationMode: The AuthenticationMode used to login the user.
    @discardableResult
    func login(
        using authenticationMode: AuthenticationMethod
    ) async throws -> FirebaseAuth.AuthDataResult {
        guard !self.authenticationState.isAuthenticated else {
            throw AlreadyAuthenticatedError()
        }
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

// MARK: - Firebase+isLoggedInViaPassword

public extension Firebase {
    
    var isLoggedInViaPassword: Bool {
        get throws {
            try self.authenticationState
                .user
                .providerData
                .map(\.providerID)
                .contains("password")
        }
    }
    
}

// MARK: - Firebase+update(email:)

public extension Firebase {
    
    func update(
        email: String
    ) async throws {
        guard try self.isLoggedInViaPassword else {
            return
        }
        try await self.authenticationState
            .user
            .updateEmail(
                to: email
            )
    }
    
}

// MARK: - Firebase+update(password:)

public extension Firebase {
    
    func update(
        password: String
    ) async throws {
        guard try self.isLoggedInViaPassword else {
            return
        }
        try await self.authenticationState
            .user
            .updatePassword(
                to: password
            )
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
        self.userDocumentSnapshotSubscription?.remove()
        self.userDocumentSnapshotSubscription = nil
        self.user = nil
    }
    
}
