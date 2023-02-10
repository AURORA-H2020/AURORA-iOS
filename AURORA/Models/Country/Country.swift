import FirebaseFirestoreSwift
import Foundation

// MARK: - Country

/// A Country
struct Country {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The ISO 3166 Alpha-2 country code.
    let countryCode: String
    
}

// MARK: - Country+FirestoreEntity

extension Country: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "countries"
    }
    
}

// MARK: - Country+Comparable

extension Country: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.localizedString() < rhs.localizedString()
    }
    
}

// MARK: - Country+europe

private extension Country {
    
    /// A Country representing Europe (EU)
    static let europe = Self(countryCode: "EU")
    
}

// MARK: - Country+localizedString

extension Country {
    
    /// The localized country name based on the current country code, if available.
    /// - Parameter locale: The Locale. Default value `.current`
    func localizedString(
        locale: Locale = .current
    ) -> String {
        if self.countryCode == Self.europe.countryCode {
            return .init(
                localized: "Europe"
            )
        } else {
            return locale
                .localizedString(
                    forRegionCode: self.countryCode
                )
                ??
                self.countryCode
        }
    }
    
}
