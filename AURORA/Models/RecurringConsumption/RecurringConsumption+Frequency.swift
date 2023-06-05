import Foundation

// MARK: - RecurringConsumption+Frequency

extension RecurringConsumption {
    
    /// A recurring consumption frequency
    struct Frequency: Codable, Hashable, Sendable {
        
        /// The unit.
        let unit: Unit
        
        /// The value.
        let value: Int?
        
    }
    
}

// MARK: - RecurringConsumption+Frequency+PartialConvertible

extension RecurringConsumption.Frequency: PartialConvertible {
    
    /// A `Partial` representation.
    var partial: Partial<Self> {
        [
            \.unit: self.unit,
             \.value: self.value
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        try self.init(
            unit: partial(\.unit),
            value: partial.value.flatMap { $0 }
        )
    }
    
}
