import FirebaseFirestoreSwift
import Foundation

// MARK: - Site

/// A Site
public struct Site {

    // MARK: Properties
    
    /// The identifier.
    @DocumentID
    public var id: String?
    
    /// The country code.
    public let countryCode: String
    
    /// The city.
    public let city: String
    
    // MARK: Initializer
    
    /// Creates a new instance of `Site`
    /// - Parameters:
    ///   - id: The identifier.
    ///   - countryCode: The country code.
    ///   - city: The city.
    public init(
        id: String? = nil,
        countryCode: String,
        city: String
    ) {
        self.id = id
        self.countryCode = countryCode
        self.city = city
    }
    
}

// MARK: - Site+FirestoreEntity

extension Site: FirestoreEntity {
    
    /// The Firestore collection name.
    public static var collectionName: String {
        "sites"
    }
    
}

// MARK: - Site+localizedCountryName

public extension Site {
    
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
