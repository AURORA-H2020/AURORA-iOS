import Foundation

// MARK: - Consumption+Transportation+TransportationType

extension Consumption.Transportation {
    
    /// A Consumption TransportationType
    enum TransportationType: String, Codable, Hashable, CaseIterable, Sendable {
        // MARK: Cars & Motorcycles
        
        /// Fuel car
        case fuelCar
        /// Electric car
        case electricCar
        /// Hybrid car
        case hybridCar
        /// Motorcycle
        case motorcycle
        /// Electric motorcycle
        case electricMotorcycle
        
        // MARK: Busses
        
        /// Electric bus
        case electricBus
        /// Hybrid electric bus
        case hybridElectricBus
        /// Alternative fuel bus
        case alternativeFuelBus
        /// Diesel bus
        case dieselBus
        /// Other bus
        case otherBus
        
        // MARK: Trains & Trams
        
        /// Metro, Tram or urban light train
        case metroTramOrUrbanLightTrain
        /// Electric passenger train
        case electricPassengerTrain
        /// Diesel passenger train
        case dieselPassengerTrain
        /// High speed train
        case highSpeedTrain
        
        // MARK: Aviation
        
        /// Plane
        case planeDomestic = "plane"
        case planeIntraEu
        case planeExtraEu
        
        // MARK: Other
        
        /// Electric bike
        case electricBike
        /// Electric scooter
        case electricScooter
        /// Bike
        case bike
        /// Walking
        case walking
    }
    
}

// MARK: - Consumption+Transportation+TransportationType+isPublicVehicle

extension Consumption.Transportation.TransportationType {
    
    /// Bool value if the transporation type represents a public vehicle
    var isPublicVehicle: Bool {
        [
            Group.busses,
            .trainsAndTrams
        ]
        .flatMap(\.elements)
        .contains(self)
    }
    
}

// MARK: - Consumption+Transportation+TransportationType+privateVehicleOccupancyRange

extension Consumption.Transportation.TransportationType {
    
    /// The private vehicle occupancy range, if available
    var privateVehicleOccupancyRange: ClosedRange<Int>? {
        guard !self.isPublicVehicle else {
            return nil
        }
        switch self {
        case .fuelCar, .electricCar, .hybridCar:
            return 1...15
        case .motorcycle, .electricMotorcycle:
            return 1...3
        default:
            return nil
        }
    }
    
}

// MARK: - Consumption+Transportation+TransportationType+localizedString

extension Consumption.Transportation.TransportationType {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .fuelCar:
            return .init(localized: "Fuel car")
        case .electricCar:
            return .init(localized: "Electric car")
        case .hybridCar:
            return .init(localized: "Hybrid car")
        case .motorcycle:
            return .init(localized: "Motorcycle")
        case .electricMotorcycle:
            return .init(localized: "Electric motorcycle")
        case .electricBus:
            return .init(localized: "Electric bus")
        case .hybridElectricBus:
            return .init(localized: "Hybrid-electric bus")
        case .alternativeFuelBus:
            return .init(localized: "Alternative fuel bus")
        case .dieselBus:
            return .init(localized: "Diesel bus")
        case .otherBus:
            return .init(localized: "Other bus")
        case .metroTramOrUrbanLightTrain:
            return .init(localized: "Metro, tram, or urban light train")
        case .electricPassengerTrain:
            return .init(localized: "Electric passenger train")
        case .dieselPassengerTrain:
            return .init(localized: "Diesel passenger train")
        case .highSpeedTrain:
            return .init(localized: "High speed train")
        case .planeDomestic:
            return .init(localized: "Plane (domestic)")
        case .planeIntraEu:
            return .init(localized: "Plane (intra EU)")
        case .planeExtraEu:
            return .init(localized: "Plane (extra EU)")
        case .electricBike:
            return .init(localized: "Electric bike")
        case .electricScooter:
            return .init(localized: "Electric scooter")
        case .bike:
            return .init(localized: "Bike")
        case .walking:
            return .init(localized: "Walking")
        }
    }
    
}
