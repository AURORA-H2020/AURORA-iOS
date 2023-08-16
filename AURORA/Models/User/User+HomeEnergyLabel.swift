import Foundation

// MARK: - User+HomeEnergyLabel

extension User {
    
    /// The home energy label
    struct HomeEnergyLabel: Hashable {
        
        /// The value
        let value: String
        
    }
    
}

// MARK: - Codable

extension User.HomeEnergyLabel: Codable {
    
    /// Creates a new instance of `User.HomeEnergyLabel`
    /// - Parameter decoder: The decoder.
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            value: try container.decode(String.self)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension User.HomeEnergyLabel: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `User.HomeEnergyLabel`
    /// - Parameter value: The value.
    init(
        stringLiteral value: String
    ) {
        self.init(value: value)
    }
    
}

// MARK: - Well Known Values

extension User.HomeEnergyLabel {
    
    /// A+
    static let aPlus: Self = "A+"
    
    /// A
    static let a: Self = "A"
    
    /// B
    static let b: Self = "B"
    
    /// C
    static let c: Self = "C"
    
    /// D
    static let d: Self = "D"
    
    /// E
    static let e: Self = "E"
    
    /// F
    static let f: Self = "F"
    
    /// G
    static let g: Self = "G"
    
    /// Unsure
    static let unsure: Self = "unsure"
    
}

// MARK: - CaseIterable

extension User.HomeEnergyLabel: CaseIterable {
    
    /// A collection of all values of this type.
    static let allCases: [Self] = [
        .aPlus,
        .a,
        .b,
        .c,
        .d,
        .e,
        .f,
        .g,
        .unsure
    ]
    
}

// MARK: - Localized String

extension User.HomeEnergyLabel {
    
    /// A localized string.
    var localizedString: String {
        if self == .unsure {
            return .init(localized: "Unsure")
        } else {
            return self.value
        }
    }
    
}
