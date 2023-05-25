import Foundation

// MARK: - LocalNotificationRequest+Trigger+MatchingDateComponents

extension LocalNotificationRequest.Trigger {
    
    /// The matching date components of a local notification request trigger.
    @dynamicMemberLookup
    struct MatchingDateComponents: Hashable {
        
        // MARK: Properties
        
        /// The date components.
        var dateComponents: DateComponents
        
        // MARK: Initializer
        
        /// Creates a new instance of `LocalNotificationRequest.Trigger.MatchingDateComponents`
        /// - Parameter dateComponents: The date components.
        init(
            dateComponents: DateComponents = .init()
        ) {
            self.dateComponents = dateComponents
        }
        
    }
    
}

// MARK: - Convenience Initializer

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// Creates a new instance of `LocalNotificationRequest.Trigger.MatchingDateComponents`
    /// - Parameters:
    ///   - frequency: The Frequency.
    ///   - time: The time information. Default value `nil`
    init(
        frequency: Frequency,
        time: (hour: Int, minute: Int)? = nil
    ) {
        self.init()
        self.frequency = frequency
        if let time = time {
            self.time = Calendar.current.date(
                from: {
                    var dateComponents = DateComponents()
                    dateComponents.hour = time.hour
                    dateComponents.minute = time.minute
                    return dateComponents
                }()
            )
        }
    }
    
}

// MARK: - DynamicMemberLookup

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// Access a property of `DateComponents`
    /// - Parameter keyPath: The key path.
    subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<DateComponents, Value>
    ) -> Value {
        get {
            self.dateComponents[keyPath: keyPath]
        }
        set {
            self.dateComponents[keyPath: keyPath] = newValue
        }
    }
    
}

// MARK: - Symbols

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// An instance of DateFormatter
    private static let dateFormatter = DateFormatter()
    
    /// The month symbols.
    static var monthSymbols: [String] {
        self.dateFormatter.monthSymbols
    }
    
    /// The array of weekday symbols
    static var weekdaySymbols: [String] {
        self.dateFormatter.weekdaySymbols
    }
    
}

// MARK: - Reset

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// Reset date components
    mutating func reset() {
        self.dateComponents = .init()
    }
    
}

// MARK: - Frequency

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// A Frequency.
    enum Frequency: String, Codable, Hashable, CaseIterable {
        /// Daily
        case daily
        /// Weekly
        case weekly
        /// Monthly
        case monthly
        /// Yearly
        case yearly
    }
    
    /// The Frequency.
    var frequency: Frequency {
        get {
            if self.dateComponents.day != nil && self.dateComponents.month != nil {
                return .yearly
            } else if self.dateComponents.day != nil {
                return .monthly
            } else if self.dateComponents.weekday != nil {
                return .weekly
            } else {
                return .daily
            }
        }
        set {
            self.reset()
            switch newValue {
            case .daily:
                self.hour = 10
                self.minute = 0
            case .weekly:
                self.weekday = 0
            case .monthly:
                self.day = 30
            case .yearly:
                self.day = 30
                self.month = 12
            }
        }
    }
    
}

// MARK: - Frequency+localizedString

extension LocalNotificationRequest.Trigger.MatchingDateComponents.Frequency {
    
    /// The localized string.
    var localizedString: String {
        switch self {
        case .daily:
            return .init(localized: "Daily")
        case .weekly:
            return .init(localized: "Weekly")
        case .monthly:
            return .init(localized: "Monthly")
        case .yearly:
            return .init(localized: "Yearly")
        }
    }
    
}

// MARK: - Days

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// The range of days.
    var days: [Int] {
        if self.dateComponents.month != nil,
           let date = Calendar.current.date(from: self.dateComponents),
           let range = Calendar.current.range(of: .day, in: .month, for: date) {
            return .init(range)
        } else {
            return .init(1...30)
        }
    }
    
}

// MARK: - Time

extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// The time information represented as an instance of a date.
    var time: Date? {
        get {
            Calendar.current.date(
                from: {
                    var dateComponents = DateComponents()
                    dateComponents.hour = self.dateComponents.hour
                    dateComponents.minute = self.dateComponents.minute
                    dateComponents.second = self.dateComponents.second
                    dateComponents.nanosecond = self.dateComponents.nanosecond
                    return dateComponents
                }()
            )
        }
        set {
            let dateComponents = newValue
                .flatMap { date in
                    Calendar
                        .current
                        .dateComponents(
                            [.hour, .minute, .second],
                            from: date
                        )
                }
            self.dateComponents.hour = dateComponents?.hour
            self.dateComponents.minute = dateComponents?.minute
            self.dateComponents.second = dateComponents?.second
            self.dateComponents.nanosecond = dateComponents?.nanosecond
        }
    }
    
}
