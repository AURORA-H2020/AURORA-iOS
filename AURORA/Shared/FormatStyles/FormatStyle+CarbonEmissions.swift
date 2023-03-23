import Foundation

// MARK: - CarbonEmissionsFormatStyle

/// A carbon emissions format style.
struct CarbonEmissionsFormatStyle: FormatStyle {
    
    /// Converts a given double value to a formatted string representation of a mass measurement.
    /// - Parameter value: The double value to be converted.
    /// - Returns: A formatted string representation of the given double value, or nil if the value is not a number.
    func format(
        _ value: Double
    ) -> String? {
        guard !value.isNaN else {
            return nil
        }
        let measurement = Measurement<UnitMass>(
            value: value,
            unit: .kilograms
        )
        if measurement.value <= 0 {
            return measurement
                .converted(to: .grams)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .asProvided
                    )
                )
        } else {
            return measurement
                .formatted()
        }
    }
    
}

// MARK: - FormatStyle+carbonEmissions

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {

    /// A carbon emissions format style.
    static var carbonEmissions: CarbonEmissionsFormatStyle {
        .init()
    }
    
}
