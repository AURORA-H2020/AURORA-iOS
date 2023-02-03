import FirebaseFirestoreSwift
import Foundation

// MARK: - Site

/// A Site
struct Site {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The country code.
    let countryCode: String
    
    /// The city.
    let city: String
    
}

// MARK: - Site+FirestoreEntity

extension Site: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "sites"
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

extension Site {
    
    func localizedString(
        locale: Locale = .current
    ) -> String {
        [
            self.city,
            self.localizedCountryName(locale: locale)
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
    
}
