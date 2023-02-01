import FirebaseFirestore
import Foundation

// MARK: - Consumption+Electricity

extension Consumption {
    
    /// An Electricity Consumption
    struct Electricity: Codable, Hashable {
        
        /// The costs.
        var costs: Double
        
        /// The start date.
        var startDate: Timestamp
        
        /// The end date.
        var endDate: Timestamp
        
        /// Creates a new instance of `Consumption.Electricity`
        /// - Parameters:
        ///   - costs: The costs.
        ///   - startDate: The start date.
        ///   - endDate: The end date.
        init(
            costs: Double,
            startDate: Timestamp,
            endDate: Timestamp
        ) {
            self.costs = costs
            self.startDate = startDate
            self.endDate = endDate
        }
        
    }
    
}
