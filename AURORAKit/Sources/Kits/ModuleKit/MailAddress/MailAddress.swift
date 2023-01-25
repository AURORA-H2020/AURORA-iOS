import Foundation

// MARK: - MailAddress

/// A MailAddress
public struct MailAddress: Codable, Hashable, Sendable {
    
    // MARK: Static-Properties
    
    /// The mail address scheme
    private static let scheme = "mailto"
    
    /// The mail address validation cache.
    private static var cache = [String: Bool]()
    
    // MARK: Properties
    
    /// The E-Mail address.
    public let address: String
    
    // MARK: Initializer
    
    /// Creates a new instance of `MailAddress`
    /// or returns `nil` if the given `mailAddress` is not a valid E-Mail address.
    /// - Parameter mailAddress: The E-Mail address.
    public init?(
        _ mailAddress: String
    ) {
        // Verify mail addres is not empty and "@" sign is available
        guard !mailAddress.isEmpty && mailAddress.contains("@") else {
            // Otherwise return nil
            return nil
        }
        // Switch on cached result
        switch Self.cache[mailAddress] {
        case .some(true):
            // Initialize
            self.address = mailAddress
            // Return out of function
            return
        case .some(false):
            // Return nil as mail address is invalid
            return nil
        case .none:
            // Otherwise break out of switch
            break
        }
        // Remove scheme if it is already present
        let mailAddress = mailAddress
            .replacingOccurrences(of: Self.scheme, with: "")
        // Verify a DataDetector is available
        guard let dataDetector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            // Otherwise we assume that the mail address is valid
            self.address = mailAddress
            return
        }
        // Verify mail address is valid
        guard let firstMatch = dataDetector
            .firstMatch(
                in: mailAddress,
                options: .reportCompletion,
                range: .init(
                    location: 0,
                    length: mailAddress.utf16.count
                )
            ),
              firstMatch.range.location != NSNotFound,
              firstMatch.url?.scheme == Self.scheme else {
            // Cache result
            Self.cache[mailAddress] = false
            // Otherwise return nil
            return nil
        }
        // Initialize with valid mail address
        self.address = mailAddress
        // Cache Result
        Self.cache[mailAddress] = true
    }
    
    // MARK: Clear Cache
    
    /// Clear validation cache
    public static func clearCache() {
        Self.cache.removeAll()
    }
    
}
