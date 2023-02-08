import Foundation

// MARK: - Consumption+Heating+DistrictHeatingSource

extension Consumption.Heating {
    
    /// A Consumption DistrictHeatingSource
    enum DistrictHeatingSource: String, Codable, Hashable, CaseIterable, Sendable {
        /// Coal
        case coal
        /// Natural gas
        case naturalGas
        /// Oil
        case oil
        /// Electric
        case electric
        /// Solar thermal energy
        case solarThermal
        /// Geothermal energy
        case geothermal
        /// Biomass
        case biomass
        /// Waste treatment
        case wasteTreatment
        /// Default
        case `default`
    }
    
}

// MARK: - Consumption+Heating+DistrictHeatingSource+localizedString

extension Consumption.Heating.DistrictHeatingSource {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .coal:
            return .init(localized: "Coal")
        case .naturalGas:
            return .init(localized: "Natural gas")
        case .oil:
            return .init(localized: "Oil")
        case .electric:
            return .init(localized: "Electricity")
        case .solarThermal:
            return .init(localized: "Solar thermal energy")
        case .geothermal:
            return .init(localized: "Geothermal energy")
        case .biomass:
            return .init(localized: "Biomass")
        case .wasteTreatment:
            return .init(localized: "Waste treatment")
        case .default:
            return .init(localized: "Default")
        }
    }
    
}
