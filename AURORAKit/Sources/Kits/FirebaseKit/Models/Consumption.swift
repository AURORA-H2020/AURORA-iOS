import FirebaseFirestoreSwift
import Foundation

// MARK: - Consumption

/// A Consumption
public struct Consumption: Codable, Hashable, Identifiable {
    
    // MARK: Properties

    /// The identifier
    @DocumentID
    public var id: String?
    
    /// The Date
    public let date: Date
    
    /// The ConsumptionType
    public let type: ConsumptionType
    
    /// The value
    public let value: Double
    
    /// The carbon emissions
    public let carbonEmissions: Double

    // MARK: Initializer

    /// Creates a new instance of `Consumption`
    /// - Parameters:
    ///   - id: The identifier. Default value `nil`
    ///   - date: The Date
    ///   - type: ConsumptionType
    ///   - value: The value
    ///   - carbonEmissions: The carbon emissions
    public init(
        id: String? = nil,
        date: Date,
        type: ConsumptionType,
        value: Double,
        carbonEmissions: Double
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.value = value
        self.carbonEmissions = carbonEmissions
    }
    
}
