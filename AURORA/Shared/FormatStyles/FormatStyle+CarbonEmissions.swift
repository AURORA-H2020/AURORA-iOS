import Foundation

// MARK: - CarbonEmissionsFormatStyle

/// A carbon emissions format style.
struct CarbonEmissionsFormatStyle: FormatStyle {
    
    /// Converts a given double value to a formatted string representation of a mass measurement.
    /// - Parameter value: The double value to be converted.
    /// - Returns: A formatted string representation of the given double value, or nil if the value is not a number.
    func format(
        _ value: Double
    ) -> String {
        Measurement<UnitMass>(
            value: value.isNaN ? 0 : value,
            unit: .kilograms
        )
        .formatted(
            .measurement(
                width: .abbreviated,
                usage: .general,
                numberFormatStyle: .number.precision(.fractionLength(0...1))
            )
        )
    }
    
}

// MARK: - CarbonEmissionsFormatStyle+symbol

extension CarbonEmissionsFormatStyle {
    
    /// The carbon emissions symbol
    static let symbol = String(localized: "CO₂")
    
}

// MARK: - FormatStyle+carbonEmissions

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {

    /// A carbon emissions format style.
    static var carbonEmissions: CarbonEmissionsFormatStyle {
        .init()
    }
    
}
