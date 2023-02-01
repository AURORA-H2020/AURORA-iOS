import Foundation

// MARK: - Identified

/// An generic identified type.
struct Identified<Value>: Identifiable {
    
    // MARK: Properties
    
    /// The stable identity of the entity associated with this instance.
    var id: UUID
    
    /// The value.
    var value: Value
    
    // MARK: Initializer
    
    /// Creates a new instance of `Identified`
    /// - Parameters:
    ///   - id: The stable identity of the entity associated with this instance. Default value `.init()`
    ///   - value: The value.
    init(
        id: UUID = .init(),
        _ value: Value
    ) {
        self.id = id
        self.value = value
    }
    
}

// MARK: - Decodable

extension Identified: Decodable where Value: Decodable {}

// MARK: - Encodable

extension Identified: Encodable where Value: Encodable {}

// MARK: - Equatable

extension Identified: Equatable where Value: Equatable {}

// MARK: - Hashable

extension Identified: Hashable where Value: Hashable {}

// MARK: - Error

extension Identified: Error where Value: Error {}
