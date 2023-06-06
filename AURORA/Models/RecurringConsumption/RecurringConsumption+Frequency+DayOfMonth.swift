import Foundation

// MARK: - RecurringConsumption+Frequency+DayOfMonth

extension RecurringConsumption.Frequency {
    
    /// A day of month
    struct DayOfMonth: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The value.
        let value: Int
        
        // MARK: Initializer
        
        /// Creates a new instance of `DayOfMonth`
        /// - Parameter value: The value.
        init(
            _ value: Int
        ) {
            self.value = value
        }
        
    }
    
}

// MARK: - DayOfMonth+range

extension RecurringConsumption.Frequency.DayOfMonth {
    
    /// The range of supported values from 1 to 31
    static let range = 1...31
    
}

// MARK: - DayOfMonth+CaseIterable

extension RecurringConsumption.Frequency.DayOfMonth: CaseIterable {
    
    /// The first day of month
    static let first = Self(Self.range.lowerBound)
    
    /// The last day of month
    static let last = Self(Self.range.upperBound)
    
    /// A collection of all values of this type.
    static var allCases: [Self] {
        self.range.map(Self.init)
    }
    
}

// MARK: - DayOfMonth+Codable

extension RecurringConsumption.Frequency.DayOfMonth: Codable {
    
    /// Creates a new instance of `DayOfMonth`
    /// - Parameter decoder: The Decoder
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Int.self))
    }
    
    /// Encode
    /// - Parameter encoder: The Encoder.
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
}
