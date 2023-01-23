import FirebaseFirestore
import Foundation

// MARK: - FirestoreEntityReference

/// A FirestoreEntity Reference
public struct FirestoreEntityReference<Destination: FirestoreEntity>: Hashable, Identifiable, Sendable {
    
    // MARK: Properties
    
    /// The identifier.
    public var id: String
    
    // MARK: Initializer
    
    /// Creates a new instance of `FirestoreEntityReference`
    /// - Parameter id: The identifier.
    public init(
        id: String
    ) {
        self.id = id
    }
    
}

// MARK: - FirestoreEntityReference+init(destination:)

public extension FirestoreEntityReference {
    
    /// Creates a new instance of `FirestoreEntityReference`, if available
    /// - Parameter destination: The Destination.
    init?(
        _ destination: Destination
    ) {
        guard let id = destination.id else {
            return nil
        }
        self.init(id: id)
    }
    
}

// MARK: - FirestoreEntityReference+ExpressibleByStringLiteral

extension FirestoreEntityReference: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `FirestoreEntityReference`
    /// - Parameter id: The string literal identifier
    public init(
        stringLiteral id: String
    ) {
        self.init(id: id)
    }
    
}

// MARK: - FirestoreEntityReference+Codable

extension FirestoreEntityReference: Codable {
    
    /// Creates a new instance of `FirestoreEntityReference`
    /// - Parameter decoder: The Decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            id: try container.decode(String.self)
        )
    }
    
    /// Encode
    /// - Parameter encoder: The Encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
    
}
