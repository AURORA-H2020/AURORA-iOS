import Foundation

// MARK: - Consumption+Transportation+PublicVehicleOccupancy

public extension Consumption.Transportation {
    
    /// A Consumption Transportation PublicVehicleOccupancy
    enum PublicVehicleOccupancy: String, Codable, Hashable, CaseIterable, Sendable {
        case almostEmpty
        case average
        case nearlyFulll
    }
    
}
