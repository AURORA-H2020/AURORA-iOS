import Foundation

// MARK: - String+isMailAddress

extension String {
    
    /// The mail address scheme
    private static let scheme = "mailto"
    
    /// The mail address validation cache.
    private static var cache = [String: Bool]()
    
    /// Bool value if this string represents a valid mail address
    var isMailAddress: Bool {
        // Verify mail addres is not empty and "@" sign is available
        guard !self.isEmpty && self.contains("@") else {
            // Otherwise return false
            return false
        }
        // Check if a cached result is available
        if let cachedResult = Self.cache[self] {
            // Return cached result
            return cachedResult
        }
        // Remove scheme if it is already present
        let mailAddress = self
            .replacingOccurrences(of: Self.scheme, with: "")
        // Verify a DataDetector is available
        guard let dataDetector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            // Otherwise we assume that the mail address is valid
            return true
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
            // Otherwise return false
            return false
        }
        // Cache Result
        Self.cache[mailAddress] = true
        // Return success
        return true
    }
    
}
