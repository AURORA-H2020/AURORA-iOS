import Foundation

// MARK: - Method

extension Firebase.Authentication {
    
    /// A Firebase Authentication Method
    enum Method: Codable, Hashable, Sendable {
        /// Email and Password
        case password(
            method: PasswordMethod,
            email: String,
            password: String
        )
        /// Sign in with Provider
        /// - Note: Please use `.password(method:,email:,password:)` instead of `.password`
        case provider(Provider)
    }
    
}

// MARK: - PasswordMethod

extension Firebase.Authentication {
    
    /// A Firebase Authentication Password Method
    enum PasswordMethod: String, Codable, Hashable, CaseIterable, Sendable {
        /// Login
        case login
        /// Register
        case register
    }
    
}

// MARK: - PasswordMethod+localizedString

extension Firebase.Authentication.PasswordMethod {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .login:
            return .init(
                localized: "Login"
            )
        case .register:
            return .init(
                localized: "Register"
            )
        }
    }
    
}
