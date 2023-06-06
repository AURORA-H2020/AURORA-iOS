import SwiftUI

// MARK: - RecurringConsumption+Transportation

extension RecurringConsumption {
    
    /// A recurring consumption transportation information.
    struct Transportation: Codable, Hashable, Sendable {
        
        /// The type of transportation.
        var transportationType: Consumption.Transportation.TransportationType
        
        /// The private vehicle occupancy.
        var privateVehicleOccupancy: Int?
        
        /// The vehicle occupancy.
        var publicVehicleOccupancy: Consumption.Transportation.PublicVehicleOccupancy?
        
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
             \.privateVehicleOccupancy: self.privateVehicleOccupancy,
             \.publicVehicleOccupancy: self.publicVehicleOccupancy,
             \.hourOfTravel: self.hourOfTravel,
             \.minuteOfTravel: self.minuteOfTravel,
             \.distance: self.distance
        ]
    }
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws {
        let transportationType = try partial(\.transportationType)
        self.init(
            transportationType: transportationType,
            privateVehicleOccupancy: transportationType.privateVehicleOccupancyRange != nil
                ? try partial(\.privateVehicleOccupancy)
                : partial.privateVehicleOccupancy.flatMap { $0 },
            publicVehicleOccupancy: transportationType.isPublicVehicle
                ? try partial(\.publicVehicleOccupancy)
                : partial.publicVehicleOccupancy.flatMap { $0 },
            hourOfTravel: try partial(\.hourOfTravel),
            minuteOfTravel: try partial(\.minuteOfTravel),
            distance: try partial(\.distance)
        )
    }
    
}

// MARK: - Partial<RecurringConsumption.Transportation>+timeOfTravel

extension Partial where Wrapped == RecurringConsumption.Transportation {
    
    /// A default partial recurring consumption transportation instance.
    /// Where time of travel (hourOfTravel, minuteOfTravel) is set to the current time.
    static func `default`() -> Self {
        var partial = Self()
        partial.timeOfTravel = .init()
        return partial
    }
    
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
