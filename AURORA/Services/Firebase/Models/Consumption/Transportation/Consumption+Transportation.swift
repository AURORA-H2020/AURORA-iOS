import FirebaseFirestore
import Foundation

// MARK: - Consumption+Transportation

extension Consumption {
    
    /// A Transportation Consumption
    struct Transportation: Codable, Hashable {
        
        // MARK: Properties
        
        /// The date of the travel.
        var dateOfTravel: Timestamp
        
        /// The type of transportation.
        var transportationType: TransportationType?
        
        /// The private vehicle occupancy.
        var privateVehicleOccupancy: Int?
        
        /// The vehicle occupancy.
        var publicVehicleOccupancy: PublicVehicleOccupancy?
        
        // MARK: Initializer
        
        /// Creates a new instance of `Consumption.Transportation`
        /// - Parameters:
        ///   - dateOfTravel: The date of the travel.
        ///   - transportationType: The type of transportation.
        ///   - privateVehicleOccupancy: The private vehicle occupancy.
        ///   - publicVehicleOccupancy: The vehicle occupancy.
        init(
            dateOfTravel: Timestamp,
            transportationType: TransportationType? = nil,
            privateVehicleOccupancy: Int? = nil,
            publicVehicleOccupancy: PublicVehicleOccupancy? = nil
        ) {
            self.dateOfTravel = dateOfTravel
            self.transportationType = transportationType
            self.privateVehicleOccupancy = privateVehicleOccupancy
            self.publicVehicleOccupancy = publicVehicleOccupancy
        }
        
    }
    
}
