import Foundation

// MARK: - ConsumptionSummary+Month

extension ConsumptionSummary {
    
    /// A month of a consumption summary
    struct Month: Codable, Hashable, Sendable {
        
        /// The number of the month.
        let number: Int
        
        /// The carbon emission labeled consumption.
        let carbonEmission: ConsumptionSummary.LabeledConsumption
        
        /// The enerfy expended labeled consumption.
        let energyExpended: ConsumptionSummary.LabeledConsumption
        
        /// The categories.
        let categories: [Category]
        
    }
    
}

// MARK: - ConsumptionSummary+Month+Identifiable

extension ConsumptionSummary.Month: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Int {
        self.number
    }
    
}

// MARK: - ConsumptionSummary+Month+Comparable

extension ConsumptionSummary.Month: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.number < rhs.number
    }
    
}

// MARK: - ConsumptionSummary+Month+localizedString

extension ConsumptionSummary.Month {
    
    /// Returns the localized string of the month number in the current calendar.
    /// - Parameter calendar: The Calendar. Default value `.default`
    func localizedString(
        calendar: Calendar = .current
    ) -> String? {
        let monthSymbols = calendar.monthSymbols
        let index = self.number - 1
        guard monthSymbols.indices.contains(index) else {
            return nil
        }
        return monthSymbols[index]
    }
    
}

// MARK: - ConsumptionSummary+Month+date

extension ConsumptionSummary.Month {
    
    /// Return a date representing this month
    /// - Parameter calendar: The Calendar. Default value `.default`
    func date(
        calendar: Calendar = .current
    ) -> Date? {
        calendar.date(
            from: {
                var components = DateComponents()
                components.month = self.number
                return components
            }()
        )
    }
    
}
