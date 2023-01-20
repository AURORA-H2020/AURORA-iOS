import CoreLocation
import Foundation
import UserNotifications

// MARK: - Trigger

public extension LocalNotificationRequest {
    
    /// A LocalNotificationRequest Trigger.
    enum Trigger: Hashable {
        /// TimeInterval
        case timeInterval(
            after: Measurement<UnitDuration>,
            repeats: Bool = false
        )
        /// Calendar
        case calendar(
            dateMatching: MatchingDateComponents,
            repeats: Bool = false
        )
        /// Location
        case location(
            region: CLRegion,
            repeats: Bool = false
        )
    }
    
}

// MARK: - Trigger+Repeats

public extension LocalNotificationRequest.Trigger {
    
    /// A Boolean value indicating whether the system reschedules the notification after it’s delivered.
    var repeats: Bool {
        switch self {
        case .timeInterval(_, let repeats),
                .calendar(_, let repeats),
                .location(_, let repeats):
            return repeats
        }
    }
    
}

// MARK: - Trigger+timeInterval

public extension LocalNotificationRequest.Trigger {
    
    /// The time interval, if available.
    var timeInterval: Measurement<UnitDuration>? {
        if case .timeInterval(let timeInterval, _) = self {
            return timeInterval
        } else {
            return nil
        }
    }
    
}

// MARK: - Trigger+matchingDateComponents

public extension LocalNotificationRequest.Trigger {
    
    /// The matching date components, if available.
    var matchingDateComponents: MatchingDateComponents? {
        if case .calendar(let dateMatching, _) = self {
            return dateMatching
        } else {
            return nil
        }
    }
    
}

// MARK: - Trigger+region

public extension LocalNotificationRequest.Trigger {
    
    /// The region, if available
    var region: CLRegion? {
        if case .location(let region, _) = self {
            return region
        } else {
            return nil
        }
    }
    
}

// MARK: - Trigger+nextTriggerDate

public extension LocalNotificationRequest.Trigger {
 
    /// The next date at which the trigger conditions are met.
    var nextTriggerDate: Date? {
        let rawValue = self.rawValue
        if let calendarNotificationTrigger = rawValue as? UNCalendarNotificationTrigger {
            return calendarNotificationTrigger.nextTriggerDate()
        } else if let timeIntervalNotificationTrigger = rawValue as? UNTimeIntervalNotificationTrigger {
            return timeIntervalNotificationTrigger.nextTriggerDate()
        } else {
            return nil
        }
    }
    
}

// MARK: - Trigger+rawValue

public extension LocalNotificationRequest.Trigger {
    
    /// The raw `UNNotificationTrigger` value.
    var rawValue: UNNotificationTrigger {
        switch self {
        case .timeInterval(let after, let repeats):
            return UNTimeIntervalNotificationTrigger(
                timeInterval: .init(after.converted(to: .seconds).value),
                repeats: repeats
            )
        case .calendar(let dateMatching, let repeats):
            return UNCalendarNotificationTrigger(
                dateMatching: dateMatching.dateComponents,
                repeats: repeats
            )
        case .location(let region, let repeats):
            return UNLocationNotificationTrigger(
                region: region,
                repeats: repeats
            )
        }
    }
    
    /// Creates a new instance of `LocalNotificationRequest.Trigger`
    /// - Parameter rawValue: The UNNotificationTrigger.
    init?(
        rawValue: UNNotificationTrigger
    ) {
        if let timeIntervalNotificationTrigger = rawValue as? UNTimeIntervalNotificationTrigger {
            self = .timeInterval(
                after: .init(
                    value: timeIntervalNotificationTrigger.timeInterval,
                    unit: .seconds
                ),
                repeats: timeIntervalNotificationTrigger.repeats
            )
        } else if let calendarNotificationTrigger = rawValue as? UNCalendarNotificationTrigger {
            self = .calendar(
                dateMatching: .init(
                    dateComponents: calendarNotificationTrigger.dateComponents
                ),
                repeats: calendarNotificationTrigger.repeats
            )
        } else if let locationNotificationTrigger = rawValue as? UNLocationNotificationTrigger {
            self = .location(
                region: locationNotificationTrigger.region,
                repeats: locationNotificationTrigger.repeats
            )
        } else {
            return nil
        }
    }
    
}
