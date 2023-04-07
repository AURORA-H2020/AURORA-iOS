import Foundation
import SwiftUI

// MARK: - ConsumptionSummary+LabeledConsumption

extension ConsumptionSummary {
    
    /// A consumption summary labeled consumption.
    struct LabeledConsumption: Codable, Hashable, Sendable {
        
        /// The total value.
        let total: Double
        
        /// The percentage value.
        let percentage: Double?
        
        /// The label.
        let label: Label?
        
    }
    
}

// MARK: - ConsumptionSummary+LabeledConsumption+formatted

extension ConsumptionSummary.LabeledConsumption {
    
    /// Format labeled consumption using a given mode.
    /// - Parameter mode: The mode.
    func formatted(
        using mode: ConsumptionSummary.Mode
    ) -> String {
        mode.format(consumption: self)
    }
    
}

// MARK: - ConsumptionSummary+LabeledConsumption+localizedLabelDisplayString

extension ConsumptionSummary.LabeledConsumption {
    
    /// A localized display string for the label.
    var localizedLabelDisplayString: String {
        if let localizedDisplayString = self.label?.localizedDisplayString {
            return localizedDisplayString
        } else {
            return .init(
                localized: "No consumption entered yet (?)"
            )
        }
    }
    
}

// MARK: - ConsumptionSummary+LabeledConsumption+labelColor

extension ConsumptionSummary.LabeledConsumption {
    
    /// The label color.
    var labelColor: Color {
        self.label?.color.flatMap(Color.init) ?? .gray
    }
    
}

// MARK: - ConsumptionSummary+LabeledConsumption+foregroundColor

extension ConsumptionSummary.LabeledConsumption {
    
    /// The foreground color.
    var foregroundColor: Color {
        self.label == .c || self.label == .d ? .black : .white
    }
    
}
