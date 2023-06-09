import Foundation

// MARK: - RecurringConsumptionsReminderService

/// A recurring consumptions reminder service
final class RecurringConsumptionsReminderService: ObservableObject {
    
    // MARK: Static-Properties
    
    /// The shared RecurringConsumptionsReminderService instance.
    static let shared = RecurringConsumptionsReminderService()
    
    // MARK: Properties
    
    /// The days past threshold to show a reminder.
    private let reminderDaysPastThreshold: Int
    
    /// The calendar.
    private let calendar: Calendar
    
    /// The user defaults.
    private let userDefaults: UserDefaults
    
    /// The user defaults key.
    private let userDefaultsKey: String
    
    // MARK: Initializer
    
    /// Creates a new instance of `RecurringConsumptionsReminderService`
    /// - Parameters:
    ///   - reminderDaysPastThreshold: The days past threshold to show a reminder. Default value `14`
    ///   - calendar: The calendar. Default value `.current`
    ///   - userDefaults: The user defaults. Default value `.standard`
    ///   - userDefaultsKey: The user defaults key. Default value `RecurringConsumptionsReminder`
    init(
        reminderDaysPastThreshold: Int = 14,
        calendar: Calendar = .current,
        userDefaults: UserDefaults = .standard,
        userDefaultsKey: String = "RecurringConsumptionsReminder"
    ) {
        self.reminderDaysPastThreshold = reminderDaysPastThreshold
        self.calendar = calendar
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
    }
    
}

// MARK: - Should Show Reminder

extension RecurringConsumptionsReminderService {
    
    /// Retrieve a bool value if whether a reminder should be shown or not.
    var shouldShowReminder: Bool {
        // Verify reminder is available
        guard var reminder: Reminder = self.userDefaults[key: self.userDefaultsKey] else {
            // Otherwise set a new reminder
            self.userDefaults[key: self.userDefaultsKey] = Reminder()
            // Do not show a reminder
            return false
        }
        // Verify reminder is enabled
        guard reminder.isEnabled else {
            // Otherwise do not show a reminder
            return false
        }
        // Initialize the days past between the last reminder and the current date.
        let daysPast = self.calendar.dateComponents(
            [.day],
            from: self.calendar.startOfDay(for: reminder.lastReminderDate),
            to: self.calendar.startOfDay(for: .init())
        )
        .day ?? 0
        // Verify days past is greater or equal to the threshold
        guard daysPast >= self.reminderDaysPastThreshold else {
            // Otherwise do not show a reminder
            return false
        }
        // Update last reminder date
        reminder.lastReminderDate = .init()
        // Update reminder
        self.userDefaults[key: self.userDefaultsKey] = reminder
        // Send changes
        self.objectWillChange.send()
        // Show reminder
        return true
    }
    
}

// MARK: - Is Enabled

extension RecurringConsumptionsReminderService {
    
    /// Bool value if reminder is enabled
    var isEnabled: Bool {
        get {
            // Verify reminder is available
            guard let reminder: Reminder = self.userDefaults[key: self.userDefaultsKey] else {
                // Otherwise return true as a non present reminder
                // represents that the reminder is enabled
                return true
            }
            // Return is enabled state
            return reminder.isEnabled
        }
        set {
            // Update reminder
            self.userDefaults[key: self.userDefaultsKey] = {
                var reminder: Reminder = self.userDefaults[key: self.userDefaultsKey] ?? .init()
                reminder.isEnabled = newValue
                return reminder
            }()
            // Send changes
            self.objectWillChange.send()
        }
    }
    
}

// MARK: - Reset

extension RecurringConsumptionsReminderService {
    
    /// Reset reminder
    func reset() {
        self.userDefaults[Reminder.self, key: self.userDefaultsKey] = nil
    }
    
}

// MARK: - Reminder

private extension RecurringConsumptionsReminderService {
    
    /// A Reminder
    struct Reminder: Codable, Hashable, Sendable {
        
        /// Bool value if is enabled.
        var isEnabled = true
        
        /// The last reminder date.
        var lastReminderDate = Date()
        
    }
    
}

// MARK: - UserDefaults+Codable-Subscript

private extension UserDefaults {
    
    /// A subscript that allows for easy storage and retrieval of Codable values in UserDefaults.
    /// - Parameters:
    ///   - valueType: The type of the value being stored or retrieved. Defaults to the type of the value being assigned.
    ///   - key: The key to use when storing or retrieving the value.
    ///   - jsonDecoder: The JSONDecoder to use when decoding the stored data. Defaults to a new instance of JSONDecoder.
    ///   - jsonEncoder: The JSONEncoder to use when encoding the value to be stored. Defaults to a new instance of JSONEncoder.
    /// - Returns: The value stored at the specified key, or nil if no value is stored.
    subscript<Value: Codable>(
        _ valueType: Value.Type = Value.self,
        key key: String,
        jsonDecoder jsonDecoder: @autoclosure () -> JSONDecoder = .init(),
        jsonEncoder jsonEncoder: @autoclosure () -> JSONEncoder = .init()
    ) -> Value? {
        get {
            self.data(
                forKey: key
            )
            .flatMap { data in
                try? jsonDecoder()
                    .decode(
                        valueType,
                        from: data
                    )
            }
        }
        set {
            guard let newValue = newValue else {
                return self.removeObject(forKey: key)
            }
            guard let data = try? jsonEncoder().encode(newValue) else {
                return
            }
            self.set(data, forKey: key)
        }
    }
    
}
