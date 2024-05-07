import Foundation

// MARK: - Consumption+Transportation+TransportationType+Group

extension Consumption.Transportation.TransportationType {
    
    /// A Consumption TransportationType Group
    enum Group: String, Codable, Hashable, CaseIterable, Sendable {
        /// Cars and Motorcycles
        case carsAndMotorcycles
        /// Busses
        case busses
        /// Trains and Trams
        case trainsAndTrams
        /// Aviation
        case aviation
        /// Other
        case other
    }
    
}

// MARK: - Consumption+Transportation+TransportationType+Group+elements

extension Consumption.Transportation.TransportationType.Group {
    
    /// The TransportationTypes
    var elements: [Consumption.Transportation.TransportationType] {
        switch self {
        case .carsAndMotorcycles:
            return [
                .fuelCar,
                .electricCar,
                .hybridCar,
                .motorcycle,
                .electricMotorcycle
            ]
        case .busses:
            return [
                .electricBus,
                .hybridElectricBus,
                .alternativeFuelBus,
                .dieselBus,
                .otherBus
            ]
        case .trainsAndTrams:
            return [
                .metroTramOrUrbanLightTrain,
                .electricPassengerTrain,
                .dieselPassengerTrain,
                .highSpeedTrain
            ]
        case .aviation:
            return [
                .planeDomestic,
                .planeIntraEu,
                .planeExtraEu
            ]
        case .other:
            return [
                .electricBike,
                .electricScooter,
                .bike,
                .walking
            ]
        }
    }
    
}

// MARK: - Consumption+Transportation+TransportationType+Group+localizedString

extension Consumption.Transportation.TransportationType.Group {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .carsAndMotorcycles:
            return .init(localized: "Cars & Motorcycles")
        case .busses:
            return .init(localized: "Busses")
        case .trainsAndTrams:
            return .init(localized: "Trains & Trams")
        case .aviation:
            return .init(localized: "Aviation")
        case .other:
            return .init(localized: "Other")
        }
    }
    
}
