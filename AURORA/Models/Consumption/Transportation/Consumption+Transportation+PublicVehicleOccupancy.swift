import Foundation

// MARK: - Consumption+Transportation+PublicVehicleOccupancy

extension Consumption.Transportation {
    
    /// A Consumption Transportation PublicVehicleOccupancy
    enum PublicVehicleOccupancy: String, Codable, Hashable, CaseIterable, Sendable {
        /// Almost empty
        case almostEmpty
        /// Medium
        case medium
        /// Nearly full
        case nearlyFull
    }
    
}

// MARK: - Consumption+Transportation+PublicVehicleOccupancy+localizedString

extension Consumption.Transportation.PublicVehicleOccupancy {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .almostEmpty:
            return .init(localized: "Almost empty")
        case .medium:
            return .init(localized: "Medium occupancy")
        case .nearlyFull:
            return .init(localized: "Nearly full")
        }
    }
    
}
