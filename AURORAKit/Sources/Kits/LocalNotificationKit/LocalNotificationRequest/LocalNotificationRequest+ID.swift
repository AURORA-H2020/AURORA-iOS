import Foundation

// MARK: - LocalNotificationRequest+ID

public extension LocalNotificationRequest {

    /// A LocalNotificationRequest Identifier
    struct ID: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The raw value
        public let rawValue: String
        
        // MARK: Initializer
        
        /// Creates a new instance of `LocalNotificationRequest.ID`
        /// - Parameter rawValue: The raw value
        public init(
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
        
    }
    
}

// MARK: - LocalNotificationRequest+ID+ExpressibleByStringLiteral

extension LocalNotificationRequest.ID: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `LocalNotificationRequest.ID`
    /// - Parameter id: The string literal identifier
    public init(
        stringLiteral id: String
    ) {
        self.init(
            rawValue: id
        )
    }
    
}

// MARK: - LocalNotificationRequest+ID+Well-Known

public extension LocalNotificationRequest.ID {
    
    /// The Electricity Bill Reminder Identifier
    static let electricityBillReminder: Self = "ElectricityBillReminder"
    
    /// The Heating Bill Reminder Identifier
    static let heatingBillReminder: Self = "HeatingBillReminder"
    
    /// The Mobility Reminder Identifier
    static let mobilityReminder: Self = "MobilityReminder"
    
}
