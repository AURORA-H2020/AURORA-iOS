import FirebaseAuth
import Foundation

// MARK: - FirebaseAuthenticationProvider

/// A Firebase Authentication Provider.
protocol FirebaseAuthenticationProvider {
    
    /// The Firebase Authentication Provider
    var provider: Firebase.Authentication.Provider { get }
    
    /// Sign in.
    /// - Returns: The Credential.
    func signIn() async throws -> FirebaseAuth.AuthCredential
    
    /// Sign out.
    func signOut() throws
    
    /// Handles the opened URL.
    /// - Parameter openedURL: The opened URL.
    func handle(openedURL: URL) -> Bool
    
}

// MARK: - Default Implementation

extension FirebaseAuthenticationProvider {
    
    /// Sign out.
    func signOut() throws {}
    
    /// Handles the opened URL.
    /// - Parameter openedURL: The opened URL.
    func handle(openedURL: URL) -> Bool {
        false
    }
    
}
