import Foundation

// MARK: - FirestoreEntityIdentifierMissingError

/// An FirestoreEntity Identifier missing Error
struct FirestoreEntityIdentifierMissingError<Entity: FirestoreEntity>: Error, Codable, Hashable {
    
    /// The FirestoreEntity.
    let entity: Entity
    
}
