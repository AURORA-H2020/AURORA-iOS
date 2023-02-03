import FirebaseFirestore
import Foundation

// MARK: - Consumption+Transportation

extension Consumption {
    
    /// A Transportation Consumption
    struct Transportation: Codable, Hashable {
        
        /// The date of the travel.
        var dateOfTravel: Timestamp
        
        /// The type of transportation.
        var transportationType: TransportationType?
        
        /// The private vehicle occupancy.
        var privateVehicleOccupancy: Int?
        
        /// The vehicle occupancy.
        var publicVehicleOccupancy: PublicVehicleOccupancy?
        
    }
    
}
