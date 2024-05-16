import Foundation

// MARK: - ConsumptionMeasurement

/// A numeric quantity labeled with a unit of measure of a consumption.
struct ConsumptionMeasurement: Codable, Hashable, Sendable {
    
    /// The value.
    let value: Double
    
    /// The unit.
    let unit: Unit
    
}

// MARK: - Convenience Initializer

extension ConsumptionMeasurement {
    
    /// Creates a new instance of ``ConsumptionMeasurement``
    /// - Parameters:
    ///   - consumption: The consumption.
    ///   - measurementSystem: The oirigin/source measurement system of the consumption.
    init(
        consumption: Consumption,
        measurementSystem: System
    ) {
        self.init(
            value: consumption.value.isNaN ? 0 : consumption.value,
            unit: .init(
                measurementSystem: measurementSystem,
                category: consumption.category,
                heatingFuel: consumption.heating?.heatingFuel
            )
        )
    }
    
}

// MARK: - Converted

extension ConsumptionMeasurement {
    
    /// Returns a new measurement created by converting to the specified measurement system.
    /// - Parameter measurementSystem: The measurement system.
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func converted(
        to measurementSystem: System
    ) -> Self {
        guard self.unit.measurementSystem != measurementSystem else {
            return self
        }
        return .init(
            value: {
                func convert<UnitType: Foundation.Unit>(
                    _ unitType: UnitType.Type,
                    from sourceUnit: UnitType,
                    to destinationUnit: UnitType
                ) -> Double where UnitType: Dimension {
                    Foundation.Measurement(
                        value: self.value,
                        unit: sourceUnit
                    )
                    .converted(
                        to: destinationUnit
                    )
                    .value
                }
                switch unit {
                case .kilometers:
                    return convert(
                        UnitLength.self,
                        from: .kilometers,
                        to: .miles
                    )
                case .miles:
                    return convert(
                        UnitLength.self,
                        from: .miles,
                        to: .kilometers
                    )
                case .liters:
                    return convert(
                        UnitVolume.self,
                        from: .liters,
                        to: .gallons
                    )
                case .gallons:
                    return convert(
                        UnitVolume.self,
                        from: .gallons,
                        to: .liters
                    )
                case .kilowattHours:
                    return self.value
                case .kilograms:
                    return convert(
                        UnitMass.self,
                        from: .kilograms,
                        to: .pounds
                    )
                case .pounds:
                    return convert(
                        UnitMass.self,
                        from: .pounds,
                        to: .kilograms
                    )
                case .litersPer100Kilometers:
                    return convert(
                        UnitFuelEfficiency.self,
                        from: .litersPer100Kilometers,
                        to: .milesPerGallon
                    )
                case .milesPerGallon:
                    return convert(
                        UnitFuelEfficiency.self,
                        from: .milesPerGallon,
                        to: .litersPer100Kilometers
                    )
                case .kilowattHoursPer100Kilometers, .milesPerKilowattHour:
                    // 1 kWh/100km = 62.137119 mi/kWh
                    let conversionFactor = 62.137119
                    if self.unit == .kilowattHoursPer100Kilometers && measurementSystem == .imperial {
                        return self.value * conversionFactor
                    } else if self.unit == .milesPerKilowattHour && measurementSystem == .metric {
                        return self.value / conversionFactor
                    } else {
                        return self.value
                    }
                }
            }(),
            unit: self.unit.converted(to: measurementSystem)
        )
    }
    
}

// MARK: - Formatted

extension ConsumptionMeasurement {
    
    /// Formats the measurement to a string representation.
    /// - Parameter isCarbonEmissions: Bool value if measurement is a carbon emissions. Default value `false`
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func formatted(
        isCarbonEmissions: Bool = false
    ) -> String {
        let numberFormatStyle: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(0...1))
        func simpleFormattedValue() -> String {
            [
                self.value.formatted(numberFormatStyle),
                self.unit.symbol
            ]
            .joined(separator: " ")
        }
        let formattedValue: String = {
            guard self.value > 0 else {
                return simpleFormattedValue()
            }
            switch self.unit {
            case .kilometers:
                return Measurement<UnitLength>(
                    value: self.value,
                    unit: .kilometers
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .miles:
                return Measurement<UnitLength>(
                    value: self.value,
                    unit: .miles
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .liters:
                return Measurement<UnitVolume>(
                    value: self.value,
                    unit: .liters
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .gallons:
                return Measurement<UnitVolume>(
                    value: self.value,
                    unit: .gallons
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .kilowattHours:
                return Measurement<UnitEnergy>(
                    value: self.value,
                    unit: .kilowattHours
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .kilograms:
                return Measurement<UnitMass>(
                    value: self.value,
                    unit: .kilograms
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .pounds:
                return Measurement<UnitMass>(
                    value: self.value,
                    unit: .pounds
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .litersPer100Kilometers:
                return Measurement<UnitFuelEfficiency>(
                    value: self.value,
                    unit: .litersPer100Kilometers
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .milesPerGallon:
                return Measurement<UnitFuelEfficiency>(
                    value: self.value,
                    unit: .milesPerGallon
                )
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .general,
                        numberFormatStyle: numberFormatStyle
                    )
                )
            case .kilowattHoursPer100Kilometers, .milesPerKilowattHour:
                return simpleFormattedValue()
            }
        }()
        return [
            formattedValue,
            isCarbonEmissions ? Unit.carbonEmissionsSymbol : nil
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
    
}
