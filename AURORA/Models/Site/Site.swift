import FirebaseFirestoreSwift
import Foundation

// MARK: - Site

/// A Site
struct Site {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The city.
    let city: String?
    
    /// The country code.
    let countryCode: String
    
}

// MARK: - Site+FirestoreEntity

extension Site: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "sites"
    }
    
}

// MARK: - Site+Comparable

extension Site: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.city != nil && rhs.city == nil {
            return true
        } else {
            return (lhs.city ?? .init()) < (rhs.city ?? .init())
        }
    }
    
}

// MARK: - Site+localizedCountryName

extension Site {
    
    /// The localized country name based on the current country code, if available.
    /// - Parameter locale: The Locale. Default value `.current`
    func localizedCountryName(
        locale: Locale = .current
    ) -> String? {
        locale.localizedString(
            forRegionCode: self.countryCode
        )
    }
    
}

// MARK: - Site+localizedString

extension Site {
    
    /// A localized string.
    /// - Parameter locale: The Locale. Default value `.current`
    func localizedString(
        locale: Locale = .current
    ) -> String {
        let countryName = self.localizedCountryName(locale: locale) ?? self.countryCode
        if let city = self.city {
            return "\(city), \(countryName)"
        } else {
            return .init(
                localized: "Other city in \(countryName)"
            )
        }
    }
    
}
