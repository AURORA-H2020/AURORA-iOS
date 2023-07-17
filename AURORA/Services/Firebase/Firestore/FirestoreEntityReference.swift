import FirebaseFirestore
import Foundation

// MARK: - FirestoreEntityReference

/// A FirestoreEntity Reference
struct FirestoreEntityReference<Destination: FirestoreEntity>: Hashable, Identifiable, Sendable {
    
    /// The identifier.
    var id: String
    
}

// MARK: - FirestoreEntityReference+init(destination:)

extension FirestoreEntityReference {
    
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
    init(
        stringLiteral id: String
    ) {
        self.init(id: id)
    }
    
}

// MARK: - FirestoreEntityReference+Codable

extension FirestoreEntityReference: Codable {
    
    /// Creates a new instance of `FirestoreEntityReference`
    /// - Parameter decoder: The Decoder.
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            id: try container.decode(String.self)
        )
    }
    
    /// Encode
    /// - Parameter encoder: The Encoder.
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
    
}
