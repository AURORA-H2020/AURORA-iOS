import Foundation

// MARK: - Consumption+Electricity+ElectricitySource

extension Consumption.Electricity {
    
    /// A consumption electricity source
    enum ElectricitySource: String, Codable, Hashable, Sendable, CaseIterable {
        /// National Grid (Standard)
        case nationalGridStandard = "default"
        /// National Grid (Green Provider)
        case nationalGridGreenProvider = "defaultGreenProvider"
        /// Home Photovoltaics
        case homePhotovoltaics
    }
    
}

// MARK: - Consumption+Electricity+ElectricitySource+localizedString

extension Consumption.Electricity.ElectricitySource {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .nationalGridStandard:
            return .init(localized: "National Grid (standard)")
        case .nationalGridGreenProvider:
            return .init(localized: "National Grid (green provider)")
        case .homePhotovoltaics:
            return .init(localized: "Home Photovoltaics")
        }
    }
    
}
