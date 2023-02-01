import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit

// MARK: - GoogleFirebaseAuthenticationProvider

/// A Google Firebase Authentication Provider.
final class GoogleFirebaseAuthenticationProvider: NSObject {
    
    // MARK: Properties
    
    /// The Google SignIn instance
    private let googleSignIn: GoogleSignIn.GIDSignIn
    
    // MARK: Initializer
    
    /// Creates a new instance of `GoogleFirebaseAuthenticationProvider`
    /// - Parameters:
    ///   - googleSignIn: The GoogleSignIn instance. Default value `.sharedInstance`
    ///   - clientId: The optional GoogleSignIn Client ID. Default value `FirebaseApp.app()?.options.clientID`
    init(
        googleSignIn: GoogleSignIn.GIDSignIn = .sharedInstance,
        clientId: String? = FirebaseCore.FirebaseApp.app()?.options.clientID
    ) {
        self.googleSignIn = googleSignIn
        if let clientID = clientId {
            self.googleSignIn.configuration = .init(
                clientID: clientID
            )
        }
    }
    
}

// MARK: - SignInError

extension GoogleFirebaseAuthenticationProvider {
    
    /// An ID Token Missing Error
    struct IDTokenMissingError: Error, Sendable {}
    
}

// MARK: - FirebaseOAuthController

extension GoogleFirebaseAuthenticationProvider: FirebaseAuthenticationProvider {
    
    /// The Firebase Authentication Provider
    var provider: Firebase.Authentication.Provider {
        .google
    }
    
    /// Sign in.
    /// - Returns: The Credential.
    func signIn() async throws -> FirebaseAuth.AuthCredential {
        // Declare sign in result
        let signInResult: GoogleSignIn.GIDSignInResult
        do {
            // Try to sign in
            signInResult = try await self.googleSignIn.signIn()
        } catch {
            // Check if error is cancelled
            if (error as? GoogleSignIn.GIDSignInError)?.code == .canceled {
                // Throw CancellationError
                throw CancellationError()
            } else {
                // Otherwise throw Error as it is
                throw error
            }
        }
        // Verify id token is available
        guard let idToken = signInResult.user.idToken?.tokenString else {
            // Otherwise throw error
            throw IDTokenMissingError()
        }
        // Return credential
        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: signInResult.user.accessToken.tokenString
        )
    }
    
    /// Sign out.
    func signOut() throws {
        self.googleSignIn.signOut()
    }
    
    /// Handles the opened URL.
    /// - Parameter openedURL: The opened URL.
    func handle(openedURL: URL) -> Bool {
        self.googleSignIn.handle(openedURL)
    }
    
}

// MARK: - GIDSignIn+signIn(presentationContext)

private extension GoogleSignIn.GIDSignIn {
    
    /// Starts an interactive sign-in flow on iOS on the `MainActor`.
    @MainActor
    func signIn() async throws -> GoogleSignIn.GIDSignInResult {
        // Verify root ViewController is available
        guard let rootViewController: UIViewController = UIApplication
            .shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController else {
            // Otherwise throw error
            throw GoogleSignIn.GIDSignInError(.unknown)
        }
        // Sign in
        return try await self.signIn(withPresenting: rootViewController)
    }
    
}
