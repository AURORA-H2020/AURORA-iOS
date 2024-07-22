import Foundation

// MARK: - ConsumptionMeasurement+System

extension ConsumptionMeasurement {
    
    /// A type that represents the measurement system used by a consumption.
    enum System: String, Codable, Hashable, Sendable, CaseIterable {
        /// Metric
        case metric
        /// Imperial
        case imperial
    }
    
}

// MARK: - Convenience Initializer

extension ConsumptionMeasurement.System {
    
    /// Creates a new instance of ``ConsumptionMeasurement.System``
    /// - Parameter locale: The locale. Default value `.current`
    init(
        locale: Locale = .current
    ) {
        let usesMetricSystem: Bool = {
            if #available(iOS 16, *) {
                return locale.measurementSystem == .metric
            } else {
                return locale.usesMetricSystem
            }
        }()
        self = usesMetricSystem ? .metric : .imperial
    }
    
}
