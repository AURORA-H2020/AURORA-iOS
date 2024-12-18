import Foundation

// MARK: - AURORAWebAppLink

/// An AURORA web app link.
@dynamicMemberLookup
struct AURORAWebAppLink: Codable, Hashable, Sendable {
    
    // MARK: Properties
    
    /// The url.
    let url: URL
    
    // MARK: Initializer
    
    /// Creates a new instance of ``AURORAWebAppLink``
    /// - Parameters:
    ///   - pathComponents: The path components. Default value `.init()`
    ///   - queryItems: The query items. Default value `.init()`
    init?(
        pathComponents: [String] = .init(),
        queryItems: [URLQueryItem] = .init()
    ) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = {
            #if DEBUG
            return "aurora-dashboard-git-develop-aurora-h2020.vercel.app"
            #else
            return "dashboard.aurora-h2020.eu"
            #endif
        }()
        urlComponents.path = (CollectionOfOne("/") + pathComponents).joined(separator: "/")
        urlComponents.queryItems = queryItems
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

extension AURORAWebAppLink {
    
    /// Photovoltaic plant data link.
    /// - Parameter photovoltaicPlant: The photovoltaic plant.
    static func photovoltaicPlantData(
        for photovoltaicPlant: PhotovoltaicPlant
    ) -> Self? {
        guard let photovoltaicPlantID = photovoltaicPlant.id else {
            return nil
        }
        return .init(
            pathComponents: [
                "pv-data"
            ],
            queryItems: [
                .init(
                    name: "site",
                    value: photovoltaicPlantID
                )
            ]
        )
    }
    
}
