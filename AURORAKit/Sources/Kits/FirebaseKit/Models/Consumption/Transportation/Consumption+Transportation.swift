import Foundation

// MARK: - Consumption+Transportation

public extension Consumption {
    
    /// A Transportation Consumption
    struct Transportation: Codable, Hashable {
        
        // MARK: Properties
        
        /// The date of the travel.
        public var dateOfTravel: Timestamp
        
        /// The type of transportation.
        public var transportationType: TransportationType?
        
        /// The private vehicle occupancy.
        public var privateVehicleOccupancy: Int?
        
        /// The public vehicle occupancy.
        public var publicVehicleOccupancy: PublicVehicleOccupancy?
        
        // MARK: Initializer
        
        /// Creates a new instance of `Consumption.Transportation`
        /// - Parameters:
        ///   - dateOfTravel: The date of the travel.
        ///   - transportationType: The type of transportation.
        ///   - privateVehicleOccupancy: The private vehicle occupancy.
        ///   - publicVehicleOccupancy: The public vehicle occupancy.
        public init(
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
