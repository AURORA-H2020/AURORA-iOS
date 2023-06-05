import SwiftUI

// MARK: - RecurringConsumption+Transportation

extension RecurringConsumption {
    
    /// A recurring consumption transportation information.
    struct Transportation: Codable, Hashable, Sendable {
        
        /// The type of transportation.
        var transportationType: Consumption.Transportation.TransportationType
        
        /// The hour of travel
        var hourOfTravel: Int
        
        /// The minute of travel
        var minuteOfTravel: Int
        
        /// The distance
        var distance: Double
        
    }
    
}

// MARK: - RecurringConsumption+Transportation+PartialConvertible

extension RecurringConsumption.Transportation: PartialConvertible {
    
    /// A `Partial` representation.
    var partial: Partial<Self> {
        [
            \.transportationType: self.transportationType,
             \.hourOfTravel: self.hourOfTravel,
             \.minuteOfTravel: self.minuteOfTravel,
             \.distance: self.distance
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        try self.init(
            transportationType: partial(\.transportationType),
            hourOfTravel: partial(\.hourOfTravel),
            minuteOfTravel: partial(\.minuteOfTravel),
            distance: partial(\.distance)
        )
    }
    
}

// MARK: - Partial<RecurringConsumption.Transportation>+timeOfTravel

extension Partial where Wrapped == RecurringConsumption.Transportation {
    
    /// The time of travel represented as a date.
    var timeOfTravel: Date {
        get {
            guard self.hourOfTravel != nil || self.minuteOfTravel != nil else {
                return .init()
            }
            return Calendar
                .current
                .date(
                    from: .init(
                        hour: self.hourOfTravel,
                        minute: self.minuteOfTravel
                    )
                )
                ??
                .init()
        }
        set {
            let dateComponents = Calendar
                .current
                .dateComponents(
                    [.hour, .minute],
                    from: newValue
                )
            self.hourOfTravel = dateComponents.hour
            self.minuteOfTravel = dateComponents.minute
        }
    }
    
}
