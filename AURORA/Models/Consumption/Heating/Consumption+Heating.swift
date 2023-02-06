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
