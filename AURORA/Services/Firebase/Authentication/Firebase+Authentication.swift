import FirebaseAuth
import Foundation

// MARK: - Firebase+Authentication

extension Firebase {
    
    /// The Firebase Authentication
    struct Authentication {
        
        /// The Firebase instance
        let firebase: Firebase
        
    }
    
}

// MARK: - User ID

extension Firebase.Authentication {
    
    /// The User identifier or throws an error
    var userId: String {
        get throws {
            try self.state.userAccount.uid
        }
    }
    
}

// MARK: - Reload User

extension Firebase.Authentication {
    
    /// Reload User
    func reloadUser() {
        self.firebase.user = nil
        self.firebase.firebaseAuth.currentUser.flatMap(self.firebase.setup)
    }
    
}

// MARK: - AuthenticationState

extension Firebase.Authentication {
    
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

extension Firebase.Authentication {
    
    /// Login user using a given AuthenticationMethod
    /// - Parameter method: The Authentication Mode used to login the user.
    @discardableResult
    func login(
        using method: Method
    ) async throws -> FirebaseAuth.AuthDataResult {
        // Switch on method
        switch method {
        case .password(let method, let email, let password):
            switch method {
            case .login:
                // Try to sign in with email and password
                return try await self.firebase
                    .firebaseAuth
                    .signIn(
                        withEmail: email,
                        password: password
                    )
            case .register:
                // Create user with email and password
                return try await self.firebase
                    .firebaseAuth
                    .createUser(
                        withEmail: email,
                        password: password
                    )
            }
        case .provider(let provider):
            // Verify a FirebaseAuthenticationProvider is available for the given provider
            guard let firebaseAuthenticationProvider = self.firebase
                .firebaseAuthenticationProviders
                .first(where: { $0.provider == provider }) else {
                // Otherwise throw unsupported provider error
                throw AuthErrorCode.noSuchProvider
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

// MARK: - Send Password Reset email

extension Firebase.Authentication {
    
    /// Sends a password reset to the given email address
    /// - Parameter mailAddress: The email address.
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

extension Firebase.Authentication {
    
    /// A Firebase Authentication Provider
    enum Provider: String, Codable, Hashable, CaseIterable, Sendable {
        /// Email and Password
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
        
        /// Email and Password (Typealias for  `password` case)
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

// MARK: - Update Email

extension Firebase.Authentication {
    
    /// Update Email address.
    /// - Parameters:
    ///   - newMailAddress: The new email address
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
        // Update email
        try await userAccount
            .sendEmailVerification(
                beforeUpdatingEmail: newMailAddress
            )
    }
    
}

// MARK: - Update Password

extension Firebase.Authentication {
    
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

extension Firebase.Authentication {
    
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

extension Firebase.Authentication {
    
    /// Delete the currently authenticated user account.
    func deleteAccount() async throws {
        // Record Error
        try await self.firebase.crashlytics.recordError {
            // Delete Firebase user account
            try await self.state.userAccount.delete()
        }
        // For each authentication provider
        for firebaseAuthenticationProvider in self.firebase.firebaseAuthenticationProviders {
            // Sign out on authentication providers and ignore error
            try? firebaseAuthenticationProvider.signOut()
        }
    }
    
}
