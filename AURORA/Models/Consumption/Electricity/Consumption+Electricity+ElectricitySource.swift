import Foundation

// MARK: - Consumption+Electricity+ElectricitySource

extension Consumption.Electricity {
    
    /// A consumption electricity source
    enum ElectricitySource: String, Codable, Hashable, Sendable, CaseIterable {
        /// Default
        case `default`
        /// Home Photovoltaics
        case homePhotovoltaics
    }
    
}

// MARK: - Consumption+Electricity+ElectricitySource+localizedString

extension Consumption.Electricity.ElectricitySource {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .default:
            return .init(localized: "Default")
        case .homePhotovoltaics:
            return .init(localized: "Home Photovoltaics")
        }
    }
    
}
