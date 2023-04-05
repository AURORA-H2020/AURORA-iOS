import FirebaseFirestore
import Foundation

// MARK: - Consumption+Electricity

extension Consumption {
    
    /// An Electricity Consumption
    struct Electricity: Codable, Hashable {
        
        /// The costs.
        var costs: Double?
        
        /// The size of the household
        var householdSize: Int
        
        /// The start date.
        var startDate: Timestamp
        
        /// The end date.
        var endDate: Timestamp
        
    }
    
}

// MARK: - Consumption+Electricity+PartialConvertible

extension Consumption.Electricity: PartialConvertible {
    
    /// A `Partial` representation.
    var partial: Partial<Self> {
        [
            \.costs: self.costs,
             \.householdSize: self.householdSize,
             \.startDate: self.startDate,
             \.endDate: self.endDate
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        self.init(
            costs: try partial(\.costs),
            householdSize: try partial(\.householdSize),
            startDate: try partial(\.startDate),
            endDate: try partial(\.endDate)
        )
    }
    
}
