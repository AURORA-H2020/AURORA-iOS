import Foundation

// MARK: - Consumption+Transportation+PublicVehicleOccupancy

extension Consumption.Transportation {
    
    /// A Consumption Transportation PublicVehicleOccupancy
    enum PublicVehicleOccupancy: String, Codable, Hashable, CaseIterable, Sendable {
        /// Almost empty
        case almostEmpty
        /// Average
        case average
        /// Nearly full
        case nearlyFulll
    }
    
}

// MARK: - Consumption+Transportation+PublicVehicleOccupancy+localizedString

extension Consumption.Transportation.PublicVehicleOccupancy {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .almostEmpty:
            return .init(localized: "Almot empty")
        case .average:
            return .init(localized: "Average")
        case .nearlyFulll:
            return .init(localized: "Nearly full")
        }
    }
    
}
