import Foundation

// MARK: - ConsumptionSummary

/// A consumption summary
struct ConsumptionSummary: Codable, Hashable, Sendable {
    
    /// The total carbon emissions.
    let totalCarbonEmissions: Decimal
    
    /// The entries
    let entries: [Entry]
    
}
