import Foundation

// MARK: - ConsumptionSummary

/// A consumption summary
struct ConsumptionSummary: Codable, Hashable, Sendable {
    
    // MARK: Properties
    
    /// The total carbon emissions.
    let totalCarbonEmissions: Decimal
    
    /// The entries
    let entries: [Entry]
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionSummary`
    /// - Parameters:
    ///   - totalCarbonEmissions: The total carbon emissions.
    ///   - entries: The entries.
    init(
        totalCarbonEmissions: Decimal,
        entries: [Entry]
    ) {
        self.totalCarbonEmissions = totalCarbonEmissions
        self.entries = entries
    }
    
}
