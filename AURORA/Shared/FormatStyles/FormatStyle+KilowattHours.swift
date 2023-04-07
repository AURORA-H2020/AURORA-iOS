import Foundation

// MARK: - KilowattHoursFormatStyle

/// A kilowatt hours format style.
struct KilowattHoursFormatStyle: FormatStyle {
    
    /// Converts a given double value to a formatted string representation of a engergy measurement.
    /// - Parameter value: The double value to be converted.
    /// - Returns: A formatted string representation of the given double value, or nil if the value is not a number.
    func format(
        _ value: Double
    ) -> String {
        let value = value.isNaN ? 0 : value
        return Measurement<UnitEnergy>(
            value: value,
            unit: .kilowattHours
        )
        .formatted(
            .measurement(
                width: .abbreviated,
                numberFormatStyle: .number.precision(.fractionLength(0...1))
            )
        )
    }
    
}

// MARK: - KilowattHoursFormatStyle+symbol

extension KilowattHoursFormatStyle {
    
    /// The kilowatt hours symbol
    static var symbol: String {
        UnitEnergy.kilowattHours.symbol
    }
    
}

// MARK: - FormatStyle+kilowattHours

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {

    /// A kilowatt hours format style.
    static var kilowattHours: KilowattHoursFormatStyle {
        .init()
    }
    
}
