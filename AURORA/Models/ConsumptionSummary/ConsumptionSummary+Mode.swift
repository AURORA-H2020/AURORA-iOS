import Foundation

// MARK: - ConsumptionSummary+Mode

extension ConsumptionSummary {
    
    /// A consumption summary mode.
    enum Mode: String, Hashable, CaseIterable {
        /// Carbon emission.
        case carbonEmission
        /// Energy expenditure.
        case energyExpended
    }
    
}

// MARK: - Mode+localizedString

extension ConsumptionSummary.Mode {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .carbonEmission:
            return .init(localized: "Carbon Emissions")
        case .energyExpended:
            return .init(localized: "Energy Used")
        }
    }
    
}

// MARK: - Mode+symbol

extension ConsumptionSummary.Mode {
    
    /// The symbol
    var symbol: String {
        switch self {
        case .carbonEmission:
            return CarbonEmissionsFormatStyle.symbol
        case .energyExpended:
            return KilowattHoursFormatStyle.symbol
        }
    }
    
}

// MARK: - Mode+format(consumption:)

extension ConsumptionSummary.Mode {
    
    /// Format a labeled consumption.
    /// - Parameter consumption: The labeled consumption to format.
    func format(
        consumption: ConsumptionSummary.LabeledConsumption
    ) -> String {
        switch self {
        case .carbonEmission:
            return "\(consumption.total.formatted(.carbonEmissions)) \(self.symbol)"
        case .energyExpended:
            return consumption.total.formatted(.kilowattHours)
        }
    }
    
}
