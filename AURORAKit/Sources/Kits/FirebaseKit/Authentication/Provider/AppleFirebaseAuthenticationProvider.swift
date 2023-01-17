import AuthenticationServices
import Combine
import CryptoKit
import FirebaseAuth
import Foundation

// MARK: - AppleFirebaseAuthenticationProvider

/// An Apple Firebase Authentication Provider.
final class AppleFirebaseAuthenticationProvider: NSObject {}

// MARK: - SignInContext

private extension AppleFirebaseAuthenticationProvider {
    
    /// A SignIn Context
    final class SignInContext {
        
        // MARK: Properties
        
        /// The Nonce.
        let nonce: Nonce
        
        /// The PassthroughSubject.
        var subject = PassthroughSubject<FirebaseAuth.AuthCredential, Error>()
        
        /// The subject subscription.
        var cancellable: AnyCancellable?
        
        /// Creates a new instance of `AppleFirebaseAuthenticationProvider.SignInContext`
        /// - Parameters:
        ///   - nonce: The Nonce.
        ///   - subject: The PassthroughSubject. Default value `.init()`
        init(
            nonce: Nonce,
            subject: PassthroughSubject<FirebaseAuth.AuthCredential, Error> = .init()
        ) {
            self.nonce = nonce
            self.subject = subject
        }
        
    }
    
}

// MARK: - SignInError

extension AppleFirebaseAuthenticationProvider {
    
    /// A SignIn Error
    enum SignInError: String, Codable, Hashable, Error {
        case nonceInitializationFailed
        case credentialMissing
        case identitiyTokenMissing
    }
    
}

// MARK: - AuthorizationController

private extension AppleFirebaseAuthenticationProvider {
    
    /// The AuthorizationController
    final class AuthorizationController: AuthenticationServices.ASAuthorizationController {
        
        // MARK: Properties
        
        /// The SignInContext
        let signInContext: SignInContext
        
        // MARK: Initializer
        
        /// Creates a new instance of `AuthorizationController`
        /// - Parameter signInContext: The SignInContext.
        init(
            signInContext: SignInContext
        ) {
            self.signInContext = signInContext
            // Initialize Apple ID Provider
            let appleIDProvider = AuthenticationServices.ASAuthorizationAppleIDProvider()
            // Create Request
            let request = appleIDProvider.createRequest()
            // Set Scopes
            request.requestedScopes = [.fullName, .email]
            // Set Nonce
            request.nonce = signInContext.nonce.sha256Representation
            super.init(
                authorizationRequests: [request]
            )
        }
        
    }
    
}

// MARK: - FirebaseOAuthController

extension AppleFirebaseAuthenticationProvider: FirebaseAuthenticationProvider {
    
    /// The Firebase Authentication Provider
    var provider: Firebase.Authentication.Provider {
        .apple
    }
    
    /// Sign in.
    /// - Returns: The Credential.
    func signIn() async throws -> FirebaseAuth.AuthCredential {
        // Initialize SignInContext
        let context = SignInContext(
            nonce: try .init()
        )
        // Initialize AuthorizationController
        let authorizationController = AuthorizationController(
            signInContext: context
        )
        // Set delegate
        authorizationController.delegate = self
        // Set presentation context provider
        authorizationController.presentationContextProvider = self
        // Perform requests
        authorizationController.performRequests()
        // Perform with checked throwing continuation
        return try await withCheckedThrowingContinuation { continuation in
            // Subscribe to subject
            context.cancellable = context
                .subject
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            // Simply do nothing
                            break
                        case .failure(let error):
                            // Throw error
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: continuation.resume
                )
        }
    }
    
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleFirebaseAuthenticationProvider: AuthenticationServices.ASAuthorizationControllerDelegate {
    
    /// ASAuthorizationController did complete with ASAuthorization
    /// - Parameters:
    ///   - controller: The ASAuthorizationController
    ///   - authorization: The ASAuthorization
    func authorizationController(
        controller: AuthenticationServices.ASAuthorizationController,
        didCompleteWithAuthorization authorization: AuthenticationServices.ASAuthorization
    ) {
        // Verify AuthorizationController is available
        guard let authorizationController = controller as? AuthorizationController else {
            // Otherwise return out of function
            return
        }
        // Verify Apple ID Credential is available
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            // Otherwise complete with failure
            return authorizationController
                .signInContext
                .subject
                .send(completion: .failure(SignInError.credentialMissing))
        }
        // Verify Apple ID identitiy token is available
        guard let appleIdentitiyToken = appleIDCredential.identityToken else {
            // Otherwise complete with failure
            return authorizationController
                .signInContext
                .subject
                .send(completion: .failure(SignInError.identitiyTokenMissing))
        }
        // Initialize OAuthCredential
        let oAuthCredential = FirebaseAuth.OAuthProvider.credential(
            withProviderID: Firebase.Authentication.Provider.apple.rawValue,
            idToken: .init(
                decoding: appleIdentitiyToken,
                as: UTF8.self
            ),
            rawNonce: authorizationController
                .signInContext
                .nonce
                .stringRepresentation
        )
        // Send OAuthCredential
        authorizationController
            .signInContext
            .subject
            .send(oAuthCredential)
        // Send finished signal
        authorizationController
            .signInContext
            .subject
            .send(completion: .finished)
    }
    
    /// ASAuthorizationController did complete with Error
    /// - Parameters:
    ///   - controller: The ASAuthorizationController
    ///   - error: The Error
    func authorizationController(
        controller: AuthenticationServices.ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // Verify AuthorizationController is available
        guard let authorizationController = controller as? AuthorizationController else {
            // Otherwise return out of function
            return
        }
        // Reinitialize error
        let error: Error = {
            // Check if error is cancelled
            if (error as? ASAuthorizationError)?.code == .canceled {
                // Use CancellationError
                return CancellationError()
            } else {
                // Otherwise use error as it is
                return error
            }
        }()
        // Send failure
        authorizationController
            .signInContext
            .subject
            .send(completion: .failure(error))
    }
    
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

// swiftlint:disable:next line_length
extension AppleFirebaseAuthenticationProvider: AuthenticationServices.ASAuthorizationControllerPresentationContextProviding {
    
    /// Retrieve ASPresentationAnchor for ASAuthorizationController
    /// - Parameter controller: The ASAuthorizationController
    func presentationAnchor(
        for controller: AuthenticationServices.ASAuthorizationController
    ) -> AuthenticationServices.ASPresentationAnchor {
        if let keyWindow = UIApplication
            .shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow) {
            return keyWindow
        } else {
            return .init(
                frame: UIScreen.main.bounds
            )
        }
    }
    
}

// MARK: - Nonce

private extension AppleFirebaseAuthenticationProvider {
    
    /// A Nonce
    struct Nonce: Codable, Equatable, Hashable {
        
        // MARK: Static-Properties
        
        /// The character set
        static let charset = [Character](
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        )
        
        // MARK: Properties
        
        /// The nonce string representation
        let stringRepresentation: String
        
        /// The sha256 representation
        let sha256Representation: String
        
        // MARK: Initializer
        
        /// Creates a new instance of `AppleFirebaseAuthenticationProvider.Nonce`
        /// Otherwise throws an `SignInError.nonceInitializationFailed`
        /// - Parameter length: The length of the nonce. Default value `32`
        init(
            length: Int = 32
        ) throws {
            var nonce = String()
            var remainingLength = length
            while remainingLength > 0 {
                let randoms: [UInt8] = try (0..<16).map { _ in
                    var random: UInt8 = 0
                    let errorCode = Security.SecRandomCopyBytes(
                        Security.kSecRandomDefault,
                        1,
                        &random
                    )
                    if errorCode != Security.errSecSuccess {
                        throw AppleFirebaseAuthenticationProvider
                            .SignInError
                            .nonceInitializationFailed
                    }
                    return random
                }
                randoms.forEach { random in
                    if remainingLength == 0 {
                        return
                    }
                    if random < Self.charset.count {
                        nonce.append(Self.charset[Int(random)])
                        remainingLength -= 1
                    }
                }
            }
            self.stringRepresentation = nonce
            self.sha256Representation = CryptoKit
                .SHA256
                .hash(
                    data: Data(nonce.utf8)
                )
                .compactMap { .init(format: "%02x", $0) }
                .joined()
        }
        
    }
    
}
