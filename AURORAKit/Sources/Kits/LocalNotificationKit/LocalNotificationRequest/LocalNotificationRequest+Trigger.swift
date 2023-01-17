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

public extension LocalNotificationRequest.Trigger {
    
    var repeats: Bool {
        switch self {
        case .timeInterval(_, let repeats),
                .calendar(_, let repeats),
                .location(_, let repeats):
            return repeats
        }
    }
    
}

public extension LocalNotificationRequest.Trigger {
    
    var timeInterval: Measurement<UnitDuration>? {
        if case .timeInterval(let timeInterval, _) = self {
            return timeInterval
        } else {
            return nil
        }
    }
    
}

public extension LocalNotificationRequest.Trigger {
    
    var matchingDateComponents: MatchingDateComponents? {
        if case .calendar(let dateMatching, _) = self {
            return dateMatching
        } else {
            return nil
        }
    }
    
}

public extension LocalNotificationRequest.Trigger {
    
    var region: CLRegion? {
        if case .location(let region, _) = self {
            return region
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
