import Foundation

// MARK: - ConsumptionType

/// A Consumption Type
public enum ConsumptionType: String, Codable, Hashable, CaseIterable {
    case carRide
    case trainRide
    case electricityBill
}
