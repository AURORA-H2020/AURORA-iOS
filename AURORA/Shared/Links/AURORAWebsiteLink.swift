import Foundation

// MARK: - AURORAWebsiteLink

/// An AURORA website link.
@dynamicMemberLookup
struct AURORAWebsiteLink: Codable, Hashable, Sendable {
    
    // MARK: Properties
    
    /// The url.
    let url: URL
    
    // MARK: Initializer
    
    /// Creates a new instance of ``AURORAWebsiteLink``
    /// - Parameters:
    ///   - pathComponents: The path components. Default value `.init()`
    ///   - queryItems: The query items. Default value `.init()`
    init?(
        pathComponents: [String] = .init(),
        queryItems: [URLQueryItem] = .init()
    ) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "aurora-h2020.eu"
        urlComponents.path = (CollectionOfOne("/") + pathComponents).joined(separator: "/")
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = urlComponents.url else {
            return nil
        }
        self.url = url
    }
    
    // MARK: Dynamic Member Lookup
    
    /// Access a member of the underlying ``URL`` via the given ``KeyPath``
    /// - Parameters:
    ///   - keyPath: The key path.
    subscript<Value>(
        dynamicMember keyPath: KeyPath<URL, Value>
    ) -> Value {
        self.url[keyPath: keyPath]
    }
    
}

// MARK: - Defaults

extension AURORAWebsiteLink {
    
    /// The home link.
    static let home = Self()!
    
    /// The app link.
    static let app = Self(
        pathComponents: [
            "aurora",
            "ourapp"
        ]
    )!
    
    /// The app support link.
    /// - Parameters:
    ///   - userAccountID: The user account identifier. Default value `nil`
    ///   - countryID: The country identifier. Default value `nil`
    static func appSupport(
        userAccountID: User.Account.ID? = nil,
        countryID: Country.ID = nil
    ) -> Self {
        .init(
            pathComponents: [
                "app-support"
            ],
            queryItems: [
                userAccountID.flatMap { userAccountID in
                    .init(
                        name: "user_id",
                        value: userAccountID
                    )
                },
                countryID.flatMap { countryID in
                    .init(
                        name: "country_id",
                        value: countryID
                    )
                }
            ]
            .compactMap { $0 }
        )!
    }
    
    /// The app imprint link.
    static let appImprint = Self(
        pathComponents: [
            "aurora",
            "app-imprint"
        ]
    )!
    
    /// The app privacy policy link.
    static let appPrivacyPolicy = Self(
        pathComponents: [
            "aurora",
            "app-privacy-policy"
        ]
    )!
    
    /// The app terms of services link.
    static let appTermsOfServices = Self(
        pathComponents: [
            "aurora",
            "app-tos"
        ]
    )!
    
    /// The tools link.
    static let tools = Self(
        pathComponents: [
            "tools"
        ]
    )!
    
}
