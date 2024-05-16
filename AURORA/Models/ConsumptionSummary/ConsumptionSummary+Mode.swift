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

// MARK: - Mode+format(consumption:)

extension ConsumptionSummary.Mode {

    /// Formats a labeled consumption.
    /// - Parameters:
    ///   - consumption: The labeled consumption to format.
    ///   - measurementSystem: The measurment system. Default value `.init()`
    func format(
        consumption: ConsumptionSummary.LabeledConsumption,
        measurementSystem: ConsumptionMeasurement.System = .init()
    ) -> String {
        switch self {
        case .carbonEmission:
            return ConsumptionMeasurement(
                value: consumption.total,
                unit: .kilograms
            )
            .converted(to: measurementSystem)
            .formatted(isCarbonEmissions: true)
        case .energyExpended:
            return ConsumptionMeasurement(
                value: consumption.total,
                unit: .kilowattHours
            )
            .converted(to: measurementSystem)
            .formatted()
        }
    }
    
}
