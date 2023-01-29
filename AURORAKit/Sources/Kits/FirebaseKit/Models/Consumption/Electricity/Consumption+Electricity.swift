import FirebaseFirestore
import Foundation

// MARK: - Consumption+Electricity

public extension Consumption {
    
    /// An Electricity Consumption
    struct Electricity: Codable, Hashable {
        
        /// The costs.
        public var costs: Double
        
        /// The start date.
        public var startDate: Timestamp
        
        /// The end date.
        public var endDate: Timestamp
        
        /// Creates a new instance of `Consumption.Electricity`
        /// - Parameters:
        ///   - costs: The costs.
        ///   - startDate: The start date.
        ///   - endDate: The end date.
        public init(
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
