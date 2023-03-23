import UIKit

// MARK: - ConsumptionSummary+Label

extension ConsumptionSummary {
    
    /// A consumption summary label.
    struct Label: Hashable, Sendable {
        
        /// The value.
        let value: String
        
    }
    
}

// MARK: - ConsumptionSummary+Label+Identifiable

extension ConsumptionSummary.Label: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: String {
        self.value
    }
    
}

// MARK: - ConsumptionSummary+Label+Codable

extension ConsumptionSummary.Label: Codable {
    
    /// Creates a new instance of `ConsumptionSummary.Label`
    /// - Parameter decoder: The Decoder
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            value: try container
                .decode(String.self)
                .uppercased()
        )
    }
    
    /// Encode
    /// - Parameter encoder: The Encoder
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
}

// MARK: - ConsumptionSummary+Label+ExpressibleByStringLiteral

extension ConsumptionSummary.Label: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `ConsumptionSummary.LabeledConsumption.Label`
    /// - Parameter value: The string literal value.
    init(
        stringLiteral value: String
    ) {
        self.init(
            value: value
        )
    }
    
}

// MARK: - ConsumptionSummary+Label+Well-Known-Values

extension ConsumptionSummary.Label {
    
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
    
}

// MARK: - ConsumptionSummary+Label+color

extension ConsumptionSummary.Label {
    
    /// The color, if any.
    var color: UIColor? {
        .init(
            named: [
                "LabelColor",
                self.value.uppercased()
            ]
            .joined(separator: "/")
        )
    }
    
}
