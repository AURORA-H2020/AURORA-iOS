import FirebaseAuth
import Foundation

// MARK: - Firebase+Authentication

public extension Firebase {
    
    /// The Firebase Authentication
    struct Authentication {
        
        /// The Firebase instance
        let firebase: Firebase
        
    }
    
}

// MARK: - User

public extension Firebase.Authentication {
    
    /// The User
    var user: Result<User?, Error>? {
        self.firebase.user
    }
    
}

// MARK: - Reload User

public extension Firebase.Authentication {
    
    /// Reload User
    func reloadUser() {
        self.firebase.user = nil
        self.firebase.firebaseAuth.currentUser.flatMap(self.firebase.setup)
    }
    
}

// MARK: - Firebase+authenticationState

public extension Firebase.Authentication {
    
    /// The Authentication State
    var state: State {
        self.firebase
            .firebaseAuth
            .currentUser
            .flatMap { .authenticated($0) }
            ?? .unauthenticated
    }
    
}

// MARK: - Login

public extension Firebase.Authentication {
    
    /// A Firebase Authentication Method
    enum Method {
        /// E-Mail and Password
        case password(email: String, password: String)
        /// Sign in with Apple
        case apple
        /// Sign in with Google
        case google
    }
    
    /// An error that represents that the user is already authenticated
    struct AlreadyAuthenticatedError: Error {}
    
    /// Login user using a given AuthenticationMethod
    /// - Parameter authenticationMode: The Authentication Mode used to login the user.
    @discardableResult
    func login(
        using authenticationMode: Method
    ) async throws -> FirebaseAuth.AuthDataResult {
        guard !self.state.isAuthenticated else {
            throw AlreadyAuthenticatedError()
        }
        switch authenticationMode {
        case .password(let email, let password):
            do {
                return try await self.firebase
                    .firebaseAuth
                    .signIn(
                        withEmail: email,
                        password: password
                    )
            } catch let error as AuthErrorCode where error.code == .userNotFound {
                return try await self.firebase
                    .firebaseAuth
                    .createUser(
                        withEmail: email,
                        password: password
                    )
            } catch {
                throw error
            }
        case .apple:
            let appleFirebaseAuthenticationProvider = AppleFirebaseAuthenticationProvider()
            let credential = try await appleFirebaseAuthenticationProvider.signIn()
            return try await self.firebase.firebaseAuth.signIn(with: credential)
        case .google:
            let googleFirebaseAuthenticationProvider = GoogleFirebaseAuthenticationProvider()
            let credential = try await googleFirebaseAuthenticationProvider.signIn()
            return try await self.firebase.firebaseAuth.signIn(with: credential)
        }
    }
    
}

// MARK: - Send Password Reset E-Mail

public extension Firebase.Authentication {
    
    /// Sends a password reset to the given E-Mail address
    /// - Parameter mailAddress: The E-Mail address.
    func sendPasswordReset(
        to mailAddress: String
    ) async throws {
        try await self.firebase
            .firebaseAuth
            .sendPasswordReset(
                withEmail: mailAddress
            )
    }
    
}

// MARK: - Providers

public extension Firebase.Authentication {
    
    /// A Firebase Authentication Provider
    enum Provider: String, Codable, Hashable, CaseIterable {
        /// E-Mail and Password
        case password
        /// Phone
        case phone
        /// Google
        case google = "google.com"
        /// Facebook
        case facebook = "facebook.com"
        /// Twitter
        case twitter = "twitter.com"
        /// GitHub
        case gitHub = "github.com"
        /// Apple
        case apple = "apple.com"
        /// Yahoo
        case yahoo = "yahoo.com"
        /// Microsoft
        case microsoft = "hotmail.com"
        
        /// E-Mail and Password (Typealias for  `password` case)
        static let email: Self = .password
    }
    
    /// The Authentication Providers
    var providers: Set<Provider> {
        get throws {
            .init(
                try self.state
                    .userAccount
                    .providerData
                    .map(\.providerID)
                    .compactMap(Provider.init)
            )
        }
    }
    
}

// MARK: - Update E-Mail

public extension Firebase.Authentication {
    
    /// Update E-Mail address.
    /// - Parameter email: The new E-Mail address
    func update(
        email: String
    ) async throws {
        // Verify providers contains password
        guard try self.providers.contains(.password) else {
            // Otherwise return out of function
            return
        }
        // Update E-Mail
        try await self.state
            .userAccount
            .updateEmail(
                to: email
            )
    }
    
}

// MARK: - Update Password

public extension Firebase.Authentication {
    
    /// Update Password.
    /// - Parameter password: The new password.
    func update(
        password: String
    ) async throws {
        // Verify providers contains password
        guard try self.providers.contains(.password) else {
            // Otherwise return out of function
            return
        }
        // Update password
        try await self.state
            .userAccount
            .updatePassword(
                to: password
            )
    }
    
}

// MARK: - Logout

public extension Firebase.Authentication {
    
    /// Logout the currently authenticated user.
    func logout() throws {
        // Verify user account is available / authenticated
        _ = try self.state.userAccount
        // Sign out
        try self.firebase.firebaseAuth.signOut()
    }
    
}

// MARK: - Delete Account

public extension Firebase.Authentication {
    
    /// Delete the currently authenticated user account.
    func deleteAccount() async throws {
        try await self.state.userAccount.delete()
    }
    
}
