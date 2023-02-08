import Foundation

// MARK: - ConsumptionSummary+Entry

extension ConsumptionSummary {
    
    /// A consumption summary entry
    struct Entry: Codable, Hashable, Sendable {
        
        /// The consumption category.
        let category: Consumption.Category
        
        /// The value.
        let value: Double
        
    }
    
}

// MARK: - ConsumptionSummary+Entry+Identifiable

extension ConsumptionSummary.Entry: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Consumption.Category {
        self.category
    }
    
}

// MARK: - ConsumptionSummary+Entry+formattedValue

extension ConsumptionSummary.Entry {
    
    /// The NumberFormatter
    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        return numberFormatter
    }()
    
    /// A formatted representation of the value.
    var formattedValue: String {
        Self.numberFormatter
            .string(
                from: .init(value: self.value)
            )
            ??
            "\(Int(self.value * 100))%"
    }
    
}
