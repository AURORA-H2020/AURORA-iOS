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

// MARK: - PartialConvertible

extension Consumption.Electricity: PartialConvertible {
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        self.init(
            costs: try partial(\.costs),
            startDate: try partial(\.startDate),
            endDate: try partial(\.endDate)
        )
    }
    
}
