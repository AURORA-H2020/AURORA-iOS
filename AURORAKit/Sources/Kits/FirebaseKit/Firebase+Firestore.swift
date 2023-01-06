import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Foundation

// MARK: - Firebase+get

public extension Firebase {
    
    /// Retrieve FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - collectionReferenceParameter: The CollectionReferenceParameter.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        collectionReferenceParameter: Entity.CollectionReferenceParameter,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> [Entity] {
        try await wherePredicate(
            Entity
                .collectionReference(
                    in: self.firestore,
                    collectionReferenceParameter
                )
        )
        .getDocuments()
        .documents
        .compactMap { snapshot in
            try? snapshot.data(as: Entity.self)
        }
    }
    
    /// Retrieve FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> [Entity] where Entity.CollectionReferenceParameter == Void {
        try await self.get(
            entityType,
            collectionReferenceParameter: (),
            where: wherePredicate
        )
    }
    
    /// Retrieve FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - collectionReferenceParameter: The CollectionReferenceParameter.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        collectionReferenceParameter: Entity.CollectionReferenceParameter,
        id: String
    ) async throws -> Entity {
        try await Entity
            .collectionReference(
                in: self.firestore,
                collectionReferenceParameter
            )
            .document(id)
            .getDocument(as: Entity.self)
    }
    
    /// Retrieve FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        id: String
    ) async throws -> Entity where Entity.CollectionReferenceParameter == Void {
        try await self.get(
            entityType,
            collectionReferenceParameter: (),
            id: id
        )
    }
    
}

// MARK: - Firebase+publisher

public extension Firebase {
    
    /// A Publisher which emits FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - collectionReferenceParameter: The CollectionReferenceParameter.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        collectionReferenceParameter: Entity.CollectionReferenceParameter,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) -> AnyPublisher<[Result<Entity, Error>], Error> {
        wherePredicate(
            Entity
                .collectionReference(
                    in: self.firestore,
                    collectionReferenceParameter
                )
        )
        .snapshotPublisher()
        .map { snapshot in
            snapshot
                .documents
                .map { snapshot in
                    .init {
                        try snapshot.data(as: Entity.self)
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// A Publisher which emits FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) -> AnyPublisher<[Result<Entity, Error>], Error> where Entity.CollectionReferenceParameter == Void {
        self.publisher(
            entityType,
            collectionReferenceParameter: (),
            where: wherePredicate
        )
    }
    
    /// A Publisher that emits a FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - collectionReferenceParameter: The CollectionReferenceParameter.
    ///   - id: The FirestoreEntity Identifier
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        collectionReferenceParameter: Entity.CollectionReferenceParameter,
        id: String
    ) -> AnyPublisher<Result<Entity, Error>, Error> {
        Entity
            .collectionReference(
                in: self.firestore,
                collectionReferenceParameter
            )
            .document(id)
            .snapshotPublisher()
            .map { snapshot in
                .init {
                    try snapshot.data(as: Entity.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// A Publisher that emits a FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - id: The FirestoreEntity Identifier
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        id: String
    ) -> AnyPublisher<Result<Entity, Error>, Error> where Entity.CollectionReferenceParameter == Void {
        self.publisher(
            entityType,
            collectionReferenceParameter: (),
            id: id
        )
    }
    
}

// MARK: - Firebase+add(entity:)

public extension Firebase {
    
    /// Adds a new FirestoreEnttity with an automatically generated ID.
    /// - Parameters:
    ///   - entity: The FirestoreEntity to add.
    ///   - collectionReferenceParameter: The FirestoreEntity CollectionReferenceParameter.
    @discardableResult
    func add<Entity: FirestoreEntity>(
        _ entity: Entity,
        collectionReferenceParameter: Entity.CollectionReferenceParameter
    ) throws -> FirebaseFirestore.DocumentReference {
        try Entity
            .collectionReference(
                in: self.firestore,
                collectionReferenceParameter
            )
            .addDocument(from: entity)
    }
    
    /// Adds a new FirestoreEnttity with an automatically generated ID.
    /// - Parameters:
    ///   - entity: The FirestoreEntity to add.
    @discardableResult
    func add<Entity: FirestoreEntity>(
        _ entity: Entity
    ) throws -> FirebaseFirestore.DocumentReference where Entity.CollectionReferenceParameter == Void {
        try self.add(
            entity,
            collectionReferenceParameter: ()
        )
    }
    
}

// MARK: - Firebase+update(entity:)

public extension Firebase {
    
    /// Update a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to update.
    ///   - collectionReferenceParameter: The FirestoreEntity CollectionReferenceParameter.
    func update<Entity: FirestoreEntity>(
        _ entity: Entity,
        collectionReferenceParameter: Entity.CollectionReferenceParameter
    ) throws {
        // Initialize mutable entity
        var entity = entity
        // Check if Entity is a User
        if Entity.self is User.Type {
            // Set identifier to UID of current Firebase user
            // as a User document id must always be equal
            // to the FirebaseAuth user
            entity.id = self.auth.currentUser?.uid
        }
        // Verify entity identifier is available
        guard let entityId = entity.id else {
            // Otherwise throw an error
            throw FirestoreEntityIdentifierMissingError()
        }
        // Update document
        try Entity
            .collectionReference(
                in: self.firestore,
                collectionReferenceParameter
            )
            .document(entityId)
            .setData(from: entity, completion: nil)
        // Check if the entity is an instance of user
        if let user = entity as? User {
            // Pre-update the stored user
            self.user = .success(user)
        }
    }
    
    /// Update a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to update.
    func update<Entity: FirestoreEntity>(
        _ entity: Entity
    ) throws where Entity.CollectionReferenceParameter == Void {
        try self.update(
            entity,
            collectionReferenceParameter: ()
        )
    }
    
}

// MARK: - Firebase+delete(entity:)

public extension Firebase {
    
    /// Delete a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to delete.
    ///   - collectionReferenceParameter: The FirestoreEntity CollectionReferenceParameter.
    func delete<Entity: FirestoreEntity>(
        _ entity: Entity,
        collectionReferenceParameter: Entity.CollectionReferenceParameter
    ) throws {
        // Verify entity identifier is available
        guard let entityId = entity.id else {
            // Otherwise throw an error
            throw FirestoreEntityIdentifierMissingError()
        }
        // Delete
        Entity
            .collectionReference(
                in: self.firestore,
                collectionReferenceParameter
            )
            .document(entityId)
            .delete(completion: nil)
    }
    
    /// Delete a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to delete.
    func delete<Entity: FirestoreEntity>(
        _ entity: Entity
    ) throws where Entity.CollectionReferenceParameter == Void {
        try self.delete(
            entity,
            collectionReferenceParameter: ()
        )
    }
    
}

// MARK: - Firebase+FirestoreEntityIdentifierMissingError

public extension Firebase {
    
    /// An FirestoreEntity Identifier missing Error
    struct FirestoreEntityIdentifierMissingError: Error {}
    
}
