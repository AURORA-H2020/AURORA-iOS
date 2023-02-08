import Foundation

// MARK: - ConsumptionSummary

/// A consumption summary
struct ConsumptionSummary: Codable, Hashable, Sendable {
    
    /// The total carbon emissions.
    let totalCarbonEmissions: Double
    
    /// The entries
    let entries: [Entry]
    
}

// MARK: - ConsumptionSummary+formattedTotalCarbonEmissions

extension ConsumptionSummary {
    
    /// A formatted representation of the total carbon emissions.
    var formattedTotalCarbonEmissions: String {
        Measurement<UnitMass>(
            value: self.totalCarbonEmissions,
            unit: .kilograms
        )
        .formatted()
    }
    
}
