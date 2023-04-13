import FirebaseFirestore
import Foundation

// MARK: - Consumption+Heating

extension Consumption {
    
    /// A Heating Consumption
    struct Heating: Codable, Hashable {
        
        /// The costs in cents.
        var costs: Double?
        
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

// MARK: - Consumption+Heating+dateRange

extension Consumption.Heating {
    
    /// The date range from start to end date, if available.
    var dateRange: Range<Date>? {
        let startDate = self.startDate.dateValue()
        let endDate = self.endDate.dateValue()
        guard startDate <= endDate else {
            return nil
        }
        return startDate..<endDate
    }
    
}

// MARK: - Consumption+Heating+PartialConvertible

extension Consumption.Heating: PartialConvertible {
    
    /// A `Partial` representation.
    var partial: Partial<Self> {
        [
            \.costs: self.costs,
             \.householdSize: self.householdSize,
             \.startDate: self.startDate,
             \.endDate: self.endDate,
             \.heatingFuel: self.heatingFuel,
             \.districtHeatingSource: self.districtHeatingSource
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        self.init(
            costs: partial.costs?.flatMap { $0 },
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
