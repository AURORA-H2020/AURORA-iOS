import Foundation

// MARK: - RecurringConsumption+Frequency

extension RecurringConsumption {
    
    /// A recurring consumption frequency
    struct Frequency: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The unit.
        var unit: Unit {
            didSet {
                if self.unit == .daily {
                    self.weekdays = nil
                    self.dayOfMonth = nil
                }
            }
        }
        
        /// The weekdays.
        /// Applicable if unit is set to `weekly`
        var weekdays: Set<Weekday>? {
            didSet {
                self.unit = .weekly
                self.dayOfMonth = nil
            }
        }
        
        /// The day of month.
        /// Applicable if unit is set to `monthly`
        var dayOfMonth: DayOfMonth? {
            didSet {
                self.unit = .monthly
                self.weekdays = nil
            }
        }
        
        // MARK: Initializer
        
        /// Creates a new instance of `RecurringConsumption.Frequency`
        /// - Parameters:
        ///   - unit: The unit.
        ///   - weekdays: The weekdays.
        ///   - dayOfMonth: The day of month.
        init(
            unit: Unit,
            weekdays: Set<Weekday>? = nil,
            dayOfMonth: DayOfMonth? = nil
        ) {
            self.unit = unit
            switch unit {
            case .daily:
                break
            case .weekly:
                self.weekdays = weekdays
            case .monthly:
                self.dayOfMonth = dayOfMonth
            }
        }
        
    }
    
}

// MARK: - RecurringConsumption+Frequency+Convenience

extension RecurringConsumption.Frequency {
    
    /// The daily frequency
    static let daily = Self(
        unit: .daily
    )
    
    /// Weekly frequency
    /// - Parameter weekdays: The weekdays
    static func weekly(
        weekdays: Set<Weekday>
    ) -> Self {
        .init(
            unit: .weekly,
            weekdays: weekdays
        )
    }
    
    /// Monthly frequency
    /// - Parameter dayOfMonth: The day of month
    static func monthly(
        dayOfMonth: DayOfMonth
    ) -> Self {
        .init(
            unit: .monthly,
            dayOfMonth: dayOfMonth
        )
    }
    
}

// MARK: - RecurringConsumption+Frequency+PartialConvertible

extension RecurringConsumption.Frequency: PartialConvertible {
    
    /// A `Partial` representation.
    var partial: Partial<Self> {
        [
            \.unit: self.unit,
             \.weekdays: self.weekdays,
             \.dayOfMonth: self.dayOfMonth
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        let unit = try partial(\.unit)
        self.init(
            unit: unit,
            weekdays: try {
                guard unit == .weekly else {
                    return nil
                }
                guard let weekdays = try partial(\.weekdays) else {
                    return nil
                }
                guard !weekdays.isEmpty else {
                    throw Partial<Self>
                        .Error
                        .nonEmptyValueRequired(\.weekdays)
                }
                return weekdays
            }(),
            dayOfMonth: unit == .monthly ? try partial(\.dayOfMonth) : nil
        )
    }
    
}
