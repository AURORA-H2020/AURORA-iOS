import Foundation

// MARK: - Consumption+Transportation+TransportationType

extension Consumption.Transportation {
    
    /// A Consumption TransportationType
    enum TransportationType: String, Codable, Hashable, CaseIterable, Sendable {
        case walking
        case bike
        case combustionEngineCar
        case electricCar
        case hybridCar
        case motorcycle
        case electricMotorcycle
        case electricBike
        case electricScooter
        case electricBus
        case hybridElectricBus
        case combustionEngineBus
        case metro
        case tram
        case urbanLightTrain
        case electricPassengerTrain
        case dieselPassengerTrain
        case highSpeedTrain
        case airTransport
    }
    
}
