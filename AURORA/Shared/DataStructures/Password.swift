import Foundation

// MARK: - Password

/// A Password
struct Password: Codable, Hashable, Sendable {
    
    // MARK: Static-Properties
    
    /// The minimum length
    static let minimumLength = 8
    
    // MARK: Properties
    
    /// The raw value
    let rawValue: String
    
    /// The ValidationErrors
    let validationErrors: [ValidationError]
    
    /// Bool value if password is valid
    var isValid: Bool {
        self.validationErrors.isEmpty
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `Password`
    /// - Parameters:
    ///   - password: The password.
    ///   - passwordConfirmation: The password confirmation.
    init(
        password: String,
        passwordConfirmation: String
    ) {
        self.rawValue = password
        self.validationErrors = {
            var validationErrors = [ValidationError]()
            if password.count < Self.minimumLength {
                validationErrors.append(.insufficientLength)
            }
            if !password.contains(where: \.isNumber) {
                validationErrors.append(.missingNumber)
            }
            if !password.contains(where: \.isLetter) {
                validationErrors.append(.missingLetter)
            }
            if !password.contains(where: \.isUppercase) {
                validationErrors.append(.missingUppercaseLetter)
            }
            if password != passwordConfirmation {
                validationErrors.append(.mismatchingConfirmation)
            }
            return validationErrors
        }()
    }
    
}

// MARK: - Password+ValidationError

extension Password {
    
    /// A Password Validation Error
    enum ValidationError: String, Codable, Hashable, CaseIterable, Sendable {
        /// Length is insufficient. See ``Password.minimumLength`
        case insufficientLength
        /// At least one number is missing
        case missingNumber
        /// At least one letter is missing
        case missingLetter
        /// At least one uppercase letter is missing
        case missingUppercaseLetter
        /// Confirmation does not match
        case mismatchingConfirmation
    }
    
}

// MARK: - Password+ValidationError+LocalizedError

extension Password.ValidationError: LocalizedError {
    
    /// The localized description of the error.
    var localizedDescription: String {
        switch self {
        case .insufficientLength:
            return .init(
                localized: "At least \(Password.minimumLength) characters."
            )
        case .missingNumber:
            return .init(
                localized: "At least one number."
            )
        case .missingLetter:
            return .init(
                localized: "At least one letter."
            )
        case .missingUppercaseLetter:
            return .init(
                localized: "At least one uppercase letter."
            )
        case .mismatchingConfirmation:
            return .init(
                localized: "Password confirmation doesn't match."
            )
        }
    }
    
}
