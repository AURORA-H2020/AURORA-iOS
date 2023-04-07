import Foundation

// MARK: - ConsumptionSummary+Category

extension ConsumptionSummary {
    
    /// A category object of a consumption summary
    struct Category: Codable, Hashable, Sendable {
        
        /// The consumption category
        let category: Consumption.Category
        
        /// The carbon emission labeled consumption.
        let carbonEmission: ConsumptionSummary.LabeledConsumption
        
        /// The enerfy expended labeled consumption.
        let energyExpended: ConsumptionSummary.LabeledConsumption
        
    }
    
}

// MARK: - ConsumptionSummary+Category+Identifiable

extension ConsumptionSummary.Category: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Consumption.Category {
        self.category
    }
    
}

// MARK: - ConsumptionSummary+Category+labeledConsumption

extension ConsumptionSummary.Category {
    
    /// Retrieve a LabeledConsumption for a given Mode.
    /// - Parameter mode: The Mode.
    func labeledConsumption(
        for mode: ConsumptionSummary.Mode
    ) -> ConsumptionSummary.LabeledConsumption {
        switch mode {
        case .carbonEmission:
            return self.carbonEmission
        case .energyExpended:
            return self.energyExpended
        }
    }
    
}
