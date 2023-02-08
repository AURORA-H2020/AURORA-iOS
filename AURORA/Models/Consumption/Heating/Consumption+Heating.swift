import FirebaseFirestore
import Foundation

// MARK: - Consumption+Heating

extension Consumption {
    
    /// A Heating Consumption
    struct Heating: Codable, Hashable {
        
        /// The costs in cents.
        var costs: Int
        
        /// The size of the household
        var householdSize: Int
        
        /// The start date.
        var startDate: Timestamp
        
        /// The end date.
        var endDate: Timestamp
        
        /// The heating fuel.
        var heatingFuel: HeatingFuel
        
        /// The district heating source.
        /// Only applicable if `heatingFuel` is equal to `.district`
        var districtHeatingSource: DistrictHeatingSource?
        
    }
    
}

// MARK: - Consumption+Heating+PartialConvertible

extension Consumption.Heating: PartialConvertible {
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        self.init(
            costs: try partial(\.costs),
            householdSize: try partial(\.householdSize),
            startDate: try partial(\.startDate),
            endDate: try partial(\.endDate),
            heatingFuel: try partial(\.heatingFuel),
            districtHeatingSource: try {
                guard try partial(\.heatingFuel) == .district else {
                    return nil
                }
                return try partial(\.districtHeatingSource)
            }()
        )
    }
    
}

// MARK: - Consumption+Heating+formattedCosts

extension Consumption.Heating {
    
    /// A formatted representation of the costs.
    var formattedCosts: String {
        self.costs.formatted(.currency(code: "EUR"))
    }
    
}
