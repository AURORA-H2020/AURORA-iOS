import Foundation

// MARK: - ConsumptionMeasurement+Unit

extension ConsumptionMeasurement {
    
    /// A dimensional unit of measure.
    enum Unit: String, Codable, Hashable, Sendable, CaseIterable {
        /// Kilometers.
        case kilometers
        /// Miles.
        case miles
        /// Liters.
        case liters
        /// Gallons.
        case gallons
        /// Kilowatt-hours.
        case kilowattHours
        /// Kilograms.
        case kilograms
        /// Pounds.
        case pounds
        /// Liters per 100 kilometers.
        case litersPer100Kilometers
        /// Miles per gallon.
        case milesPerGallon
        /// Kilowatt-hours per 100 kilometers.
        case kilowattHoursPer100Kilometers
        /// Miles per kilowatt hour
        case milesPerKilowattHour
    }
    
}

// MARK: - Convenience Initializer

extension ConsumptionMeasurement.Unit {
    
    /// Creates a new instance of ``ConsumptionMeasurement.Unit``
    /// - Parameters:
    ///   - measurementSystem: The measurement system.
    ///   - category: The category of a consumption.
    ///   - heatingFuel: The heating fuel. Default value `nil`
    // swiftlint:disable:next cyclomatic_complexity
    init(
        measurementSystem: ConsumptionMeasurement.System,
        category: Consumption.Category,
        heatingFuel: Consumption.Heating.HeatingFuel? = nil
    ) {
        self = { () -> Self in
            switch category {
            case .electricity:
                return .kilowattHours
            case .heating:
                switch heatingFuel {
                case .oil:
                    return .liters
                case .naturalGas:
                    return .kilowattHours
                case .liquifiedPetroGas:
                    return .liters
                case .biomass:
                    return .kilograms
                case .locallyProducedBiomass:
                    return .kilograms
                case .geothermal:
                    return .kilowattHours
                case .solarThermal:
                    return .kilowattHours
                case .district:
                    return .kilowattHours
                case .electric:
                    return .kilowattHours
                case .firewood:
                    return .kilograms
                case .butane:
                    return .kilograms
                case nil:
                    return .kilowattHours
                }
            case .transportation:
                return .kilometers
            }
        }()
        .converted(to: measurementSystem)
    }
    
}

// MARK: - Symbol

extension ConsumptionMeasurement.Unit {
    
    /// A carbon emissions symbolic representation.
    static let carbonEmissionsSymbol = "CO₂"
    
    /// The symbolic representation of the unit.
    var symbol: String {
        switch self {
        case .kilometers:
            return UnitLength.kilometers.symbol
        case .miles:
            return UnitLength.miles.symbol
        case .liters:
            return UnitVolume.liters.symbol
        case .gallons:
            return UnitVolume.imperialGallons.symbol
        case .kilowattHours:
            return UnitEnergy.kilowattHours.symbol
        case .kilograms:
            return UnitMass.kilograms.symbol
        case .pounds:
            return UnitMass.pounds.symbol
        case .litersPer100Kilometers:
            return UnitFuelEfficiency.litersPer100Kilometers.symbol
        case .milesPerGallon:
            return UnitFuelEfficiency.milesPerGallon.symbol
        case .kilowattHoursPer100Kilometers:
            return "kWh/100km"
        case .milesPerKilowattHour:
            return "mi/kWh"
        }
    }
    
}

// MARK: - Measurement System

extension ConsumptionMeasurement.Unit {
    
    /// The measurement system.
    var measurementSystem: ConsumptionMeasurement.System {
        switch self {
        case .kilometers:
            return .metric
        case .miles:
            return .imperial
        case .liters:
            return .metric
        case .gallons:
            return .imperial
        case .kilowattHours:
            return .metric
        case .kilograms:
            return .metric
        case .pounds:
            return .imperial
        case .litersPer100Kilometers:
            return .metric
        case .milesPerGallon:
            return .imperial
        case .kilowattHoursPer100Kilometers:
            return .metric
        case .milesPerKilowattHour:
            return .imperial
        }
    }
    
}

// MARK: - Converted

extension ConsumptionMeasurement.Unit {
    
    /// Returns a new unit created by converting to the specified measurement system.
    /// - Parameter measurementSystem: The measurement system.
    // swiftlint:disable:next cyclomatic_complexity
    func converted(
        to measurementSystem: ConsumptionMeasurement.System
    ) -> Self {
        guard self.measurementSystem != measurementSystem else {
            return self
        }
        switch self {
        case .kilometers:
            return .miles
        case .miles:
            return .kilometers
        case .liters:
            return .gallons
        case .gallons:
            return .liters
        case .kilowattHours:
            return self
        case .kilograms:
            return .pounds
        case .pounds:
            return .kilograms
        case .litersPer100Kilometers:
            return .milesPerGallon
        case .milesPerGallon:
            return .litersPer100Kilometers
        case .kilowattHoursPer100Kilometers:
            return .milesPerKilowattHour
        case .milesPerKilowattHour:
            return .kilowattHoursPer100Kilometers
        }
    }
    
}
