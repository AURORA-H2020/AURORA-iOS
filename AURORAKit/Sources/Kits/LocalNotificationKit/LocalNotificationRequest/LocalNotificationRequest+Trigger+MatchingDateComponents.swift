import Foundation

public extension LocalNotificationRequest.Trigger {
    
    @dynamicMemberLookup
    struct MatchingDateComponents: Hashable {
        
        public var dateComponents: DateComponents
        
        public init(
            dateComponents: DateComponents = .init()
        ) {
            self.dateComponents = dateComponents
        }
        
    }
    
}

public extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
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

public extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    private static let dateFormatter = DateFormatter()
    
    static var monthSymbols: [String] {
        self.dateFormatter.monthSymbols
    }
    
    static var weekdaySymbols: [String] {
        self.dateFormatter.weekdaySymbols
    }
    
}

public extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    mutating func reset() {
        self.dateComponents = .init()
    }
    
}

public extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
    /// A Frequency
    enum Frequency: String, Codable, Hashable, CaseIterable {
        case daily
        case weekly
        case monthly
        case yearly
    }
    
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

public extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
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

public extension LocalNotificationRequest.Trigger.MatchingDateComponents {
    
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
