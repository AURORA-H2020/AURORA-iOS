import FirebaseFirestore
import Foundation

// MARK: - Consumption+Heating

extension Consumption {
    
    /// A Heating Consumption
    struct Heating: Codable, Hashable {
        
        /// The costs in cents.
        var costs: Int
        
        /// The start date.
        var startDate: Timestamp
        
        /// The end date.
        var endDate: Timestamp
        
        /// Creates a new instance of `Consumption.Heating`
        /// - Parameters:
        ///   - costs: The costs in cents.
        ///   - startDate: The start date.
        ///   - endDate: The end date.
        init(
            costs: Int,
            startDate: Timestamp,
            endDate: Timestamp
        ) {
            self.costs = costs
            self.startDate = startDate
            self.endDate = endDate
        }
        
    }
    
}
