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
        
        /// The heating fuel.
        var heatingFuel: HeatingFuel
        
        /// The district heating source.
        /// Only applicable if `heatingFuel` is equal to `.district`
        var districtHeatingSource: DistrictHeatingSource?
        
    }
    
}

// MARK: - PartialConvertible

extension Consumption.Heating: PartialConvertible {
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        self.init(
            costs: try partial(\.costs),
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
