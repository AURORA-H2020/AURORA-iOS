import FirebaseFirestore
import Foundation

// MARK: - Consumption+Transportation

extension Consumption {
    
    /// A Transportation Consumption
    struct Transportation: Codable, Hashable {
        
        /// The date of the travel.
        var dateOfTravel: Timestamp
        
        /// The end date of the travel.
        var dateOfTravelEnd: Timestamp?
        
        /// The type of transportation.
        var transportationType: TransportationType
        
        /// The private vehicle occupancy.
        var privateVehicleOccupancy: Int?
        
        /// The vehicle occupancy.
        var publicVehicleOccupancy: PublicVehicleOccupancy?
        
    }
    
}

// MARK: - PartialConvertible

extension Consumption.Transportation: PartialConvertible {
    
    /// A `Partial` representation.
    var partial: Partial<Self> {
        [
            \.dateOfTravel: self.dateOfTravel,
            \.dateOfTravelEnd: self.dateOfTravelEnd,
            \.transportationType: self.transportationType,
            \.privateVehicleOccupancy: self.privateVehicleOccupancy,
            \.publicVehicleOccupancy: self.publicVehicleOccupancy
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        let transportationType: TransportationType = try partial(\.transportationType)
        self.init(
            dateOfTravel: try partial(\.dateOfTravel),
            dateOfTravelEnd: partial.dateOfTravelEnd.flatMap { $0 },
            transportationType: transportationType,
            privateVehicleOccupancy: try {
                if transportationType.privateVehicleOccupancyRange != nil {
                    return try partial(\.privateVehicleOccupancy)
                } else {
                    return partial
                        .privateVehicleOccupancy?
                        .flatMap { $0 }
                }
            }(),
            publicVehicleOccupancy: try {
                if transportationType.isPublicVehicle {
                    return try partial(\.publicVehicleOccupancy)
                } else {
                    return partial
                        .publicVehicleOccupancy?
                        .flatMap { $0 }
                }
            }()
        )
    }
    
}
