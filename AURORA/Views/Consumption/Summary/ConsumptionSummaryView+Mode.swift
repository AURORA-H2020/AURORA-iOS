import Foundation

// MARK: - ConsumptionSummaryView+Mode

extension ConsumptionSummaryView {
    
    /// A ConsumptionSummaryView mode.
    enum Mode: String, Hashable, CaseIterable {
        /// Carbon emission.
        case carbonEmission
        /// Energy expenditure.
        case energyExpended
    }
    
}

// MARK: - Mode+localizedString

extension ConsumptionSummaryView.Mode {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .carbonEmission:
            return .init(localized: "Carbon Emissions")
        case .energyExpended:
            return .init(localized: "Energy Expended")
        }
    }
    
}

// MARK: - Mode+localizedNavigationTitle

extension ConsumptionSummaryView.Mode {
    
    /// A localized navigation title.
    var localizedNavigationTitle: String {
        switch self {
        case .carbonEmission:
            return .init(localized: "Your Carbon Emissions Labels")
        case .energyExpended:
            return .init(localized: "Your Energy Labels")
        }
    }
    
}

// MARK: - Mode+localizedNavigationTitle

extension ConsumptionSummaryView.Mode {
    
    func format(
        consumption: ConsumptionSummary.LabeledConsumption
    ) -> String? {
        switch self {
        case .carbonEmission:
            guard let formattedCarbonEmissions = consumption.total.formatted(.carbonEmissions) else {
                return nil
            }
            return "\(formattedCarbonEmissions) CO₂"
        case .energyExpended:
            return Measurement<UnitEnergy>(
                value: consumption.total,
                unit: .kilowattHours
            )
            .formatted()
        }
    }
    
}
