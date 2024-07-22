import Foundation

// MARK: - Consumption+Heating+HeatingFuel

extension Consumption.Heating {
    
    /// A Consumption Heating Fuel
    enum HeatingFuel: String, Codable, Hashable, CaseIterable, Sendable {
        /// Oil
        case oil
        /// Gas
        case naturalGas
        /// Liquified Petro gas (LPG)
        case liquifiedPetroGas
        /// Biomass
        case biomass
        /// Locally-produced biomass
        case locallyProducedBiomass
        /// Geothermal
        case geothermal
        /// Solar Thermal
        case solarThermal
        /// District Heating
        case district
        /// Electric
        case electric
        /// Firewood
        case firewood
        /// Butane
        case butane
    }
    
}

// MARK: - Consumption+Heating+HeatingFuel+localizedString

extension Consumption.Heating.HeatingFuel {
    
    /// A localized string
    var localizedString: String {
        switch self {
        case .oil:
            return .init(localized: "Heating oil")
        case .naturalGas:
            return .init(localized: "Natural gas")
        case .liquifiedPetroGas:
            return .init(localized: "LPG")
        case .biomass:
            return .init(localized: "Biomass")
        case .locallyProducedBiomass:
            return .init(localized: "Locally-produced biomass")
        case .geothermal:
            return .init(localized: "Geothermal")
        case .solarThermal:
            return .init(localized: "Solar thermal")
        case .district:
            return .init(localized: "District heating")
        case .electric:
            return .init(localized: "Electric heating")
        case .firewood:
            return .init(localized: "Firewood")
        case .butane:
            return .init(localized: "Butane")
        }
    }
    
}
