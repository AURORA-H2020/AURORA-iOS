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

// MARK: - User ID

public extension Firebase.Authentication {
    
    /// The User identifier or throws an error
    var userId: String {
        get throws {
            try self.state.userAccount.uid
        }
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
        /// Sign in with Provider
        /// - Note: Please use `.password(email: String, password: String)` instead of `.password`
        case provider(Provider)
    }
    
    /// A LoginError
    enum LoginError: Error {
        /// User is already authenticated.
        case alreadyAuthenticated
        /// Unsupported provider.
        case unsupportedProvider(Provider)
    }
    
    /// Login user using a given AuthenticationMethod
    /// - Parameter method: The Authentication Mode used to login the user.
    @discardableResult
    func login(
        using method: Method
    ) async throws -> FirebaseAuth.AuthDataResult {
        // Verify state is not authenticated
        guard !self.state.isAuthenticated else {
            // Otherwise throw already authenticated error
            throw LoginError.alreadyAuthenticated
        }
        // Switch on method
        switch method {
        case .password(let email, let password):
            do {
                // Try to sign in with E-Mail and password
                return try await self.firebase
                    .firebaseAuth
                    .signIn(
                        withEmail: email,
                        password: password
                    )
            }
            // Auto fallback on `userNotFound` error
            catch let error as AuthErrorCode where error.code == .userNotFound {
                // Create user with E-Mail and password
                return try await self.firebase
                    .firebaseAuth
                    .createUser(
                        withEmail: email,
                        password: password
                    )
            } catch {
                // Otherwise rethrow error
                throw error
            }
        case .provider(let provider):
            // Verify a FirebaseAuthenticationProvider is available for the given provider
            guard let firebaseAuthenticationProvider = self.firebase
                .firebaseAuthenticationProviders
                .first(where: { $0.provider == provider }) else {
                // Otherwise throw unsupported provider error
                throw LoginError.unsupportedProvider(provider)
            }
            // Record any error which occurs when trying to sign in
            return try await self.firebase.crashlytics.recordError {
                // Sign in with FirebaseAuthenticationProvider
                try await self.firebase
                    .firebaseAuth
                    .signIn(
                        with: firebaseAuthenticationProvider.signIn()
                    )
            }
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
    /// - Parameters:
    ///   - newMailAddress: The new E-Mail address
    ///   - currentPassword: The current password.
    func updateMailAddress(
        newMailAddress: String,
        currentPassword: String
    ) async throws {
        // Try to retrieve the user account
        let userAccount = try self.state.userAccount
        // Verify providers contains passsword and a mail address is available
        guard try self.providers.contains(.password),
              let email = userAccount.email else {
            // Otherwise return out of function
            return
        }
        // Reauthenticate user
        try await userAccount
            .reauthenticate(
                with: EmailAuthProvider.credential(
                    withEmail: email,
                    password: currentPassword
                )
            )
        // Update E-Mail
        try await userAccount
            .updateEmail(
                to: newMailAddress
            )
    }
    
}

// MARK: - Update Password

public extension Firebase.Authentication {
    
    /// Update Password.
    /// - Parameters:
    ///   - newPassword: The new password.
    ///   - currentPassword: The current password.
    func updatePassword(
        newPassword: String,
        currentPassword: String
    ) async throws {
        // Try to retrieve the user account
        let userAccount = try self.state.userAccount
        // Verify providers contains passsword and a mail address is available
        guard try self.providers.contains(.password),
              let email = userAccount.email else {
            // Otherwise return out of function
            return
        }
        // Reauthenticate user
        try await userAccount
            .reauthenticate(
                with: EmailAuthProvider.credential(
                    withEmail: email,
                    password: currentPassword
                )
            )
        // Update password
        try await userAccount
            .updatePassword(
                to: newPassword
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
        // For each authentication provider
        for firebaseAuthenticationProvider in self.firebase.firebaseAuthenticationProviders {
            // Sign out on authentication providers and ignore error
            try? firebaseAuthenticationProvider.signOut()
        }
    }
    
}

// MARK: - Delete Account

public extension Firebase.Authentication {
    
    /// Delete the currently authenticated user account.
    func deleteAccount() async throws {
        // Delete Firebase user account
        try await self.state.userAccount.delete()
        // For each authentication provider
        for firebaseAuthenticationProvider in self.firebase.firebaseAuthenticationProviders {
            // Sign out on authentication providers and ignore error
            try? firebaseAuthenticationProvider.signOut()
        }
    }
    
}
