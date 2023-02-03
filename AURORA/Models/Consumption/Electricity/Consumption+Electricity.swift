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
        
    }
    
}
