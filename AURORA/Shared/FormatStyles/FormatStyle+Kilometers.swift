import Foundation

// MARK: - KilometersFormatStyle

/// A kilometers format style.
struct KilometersFormatStyle: FormatStyle {
    
    /// Converts a given double value to a formatted string representation of a length measurement.
    /// - Parameter value: The double value to be converted.
    /// - Returns: A formatted string representation of the given double value, or nil if the value is not a number.
    func format(
        _ value: Double
    ) -> String {
        let value = value.isNaN ? 0 : value
        return Measurement<UnitLength>(
            value: value,
            unit: .kilometers
        )
        .formatted(
            .measurement(
                width: .abbreviated,
                numberFormatStyle: .number.precision(.fractionLength(0...1))
            )
        )
    }
    
}

// MARK: - FormatStyle+kilometers

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {

    /// A kilometers format style.
    static var kilometers: KilometersFormatStyle {
        .init()
    }
    
}
