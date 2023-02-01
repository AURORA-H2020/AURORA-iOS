import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Foundation

// MARK: - Firebase+Firestore

extension Firebase {
    
    /// The Firebase Firestore
    struct Firestore {
        
        /// The Firebase instance.
        let firebase: Firebase
        
    }
    
}

// MARK: - Get

extension Firebase.Firestore {
    
    /// Retrieve FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - context: The CollectionReferenceContext.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        context: Entity.CollectionReferenceContext,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> [Entity] {
        try await wherePredicate(
            Entity
                .collectionReference(
                    in: self.firebase.firebaseFirestore,
                    context: context
                )
        )
        .getDocuments()
        .documents
        .compactMap { snapshot in
            try? self.firebase.crashlytics.recordError {
                try snapshot.data(as: Entity.self)
            }
        }
    }
    
    /// Retrieve FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> [Entity] where Entity.CollectionReferenceContext == Void {
        try await self.get(
            entityType,
            context: (),
            where: wherePredicate
        )
    }
    
    /// Retrieve FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - context: The CollectionReferenceContext.
    func get<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        context: Entity.CollectionReferenceContext,
        id: String
    ) async throws -> Entity {
        try await Entity
            .collectionReference(
                in: self.firebase.firebaseFirestore,
                context: context
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
    ) async throws -> Entity where Entity.CollectionReferenceContext == Void {
        try await self.get(
            entityType,
            context: (),
            id: id
        )
    }
    
}

// MARK: - Publisher

extension Firebase.Firestore {
    
    /// A Publisher which emits FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - context: The CollectionReferenceContext.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        context: Entity.CollectionReferenceContext,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) -> AnyPublisher<[Result<Entity, Error>], Error> {
        wherePredicate(
            Entity
                .collectionReference(
                    in: self.firebase.firebaseFirestore,
                    context: context
                )
        )
        .snapshotPublisher()
        .map { snapshot in
            snapshot
                .documents
                .map { snapshot in
                    .init {
                        try self.firebase.crashlytics.recordError {
                            try snapshot.data(as: Entity.self)
                        }
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
    ) -> AnyPublisher<[Result<Entity, Error>], Error> where Entity.CollectionReferenceContext == Void {
        self.publisher(
            entityType,
            context: (),
            where: wherePredicate
        )
    }
    
    /// A Publisher that emits a FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - context: The CollectionReferenceContext.
    ///   - id: The FirestoreEntity Identifier
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        context: Entity.CollectionReferenceContext,
        id: String
    ) -> AnyPublisher<Result<Entity, Error>, Error> {
        Entity
            .collectionReference(
                in: self.firebase.firebaseFirestore,
                context: context
            )
            .document(id)
            .snapshotPublisher()
            .map { snapshot in
                .init {
                    try self.firebase.crashlytics.recordError {
                        try snapshot.data(as: Entity.self)
                    }
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
    ) -> AnyPublisher<Result<Entity, Error>, Error> where Entity.CollectionReferenceContext == Void {
        self.publisher(
            entityType,
            context: (),
            id: id
        )
    }
    
}

// MARK: - Add

extension Firebase.Firestore {
    
    /// Adds a new FirestoreEnttity with an automatically generated ID.
    /// - Parameters:
    ///   - entity: The FirestoreEntity to add.
    ///   - context: The FirestoreEntity CollectionReferenceContext.
    func add<Entity: FirestoreEntity>(
        _ entity: Entity,
        context: Entity.CollectionReferenceContext
    ) throws {
        // Check if the entity is type of User or has a non nil identifier
        if Entity.self is User.Type || entity.id != nil {
            // Update entity
            try self.update(
                entity,
                context: context
            )
        } else {
            // Otherwise add entity
            // which automatically assigns an identifier
            _ = Entity
                .collectionReference(
                    in: self.firebase.firebaseFirestore,
                    context: context
                )
                .addDocument(from: entity)
        }
    }
    
    /// Adds a new FirestoreEnttity with an automatically generated ID.
    /// - Parameters:
    ///   - entity: The FirestoreEntity to add.
    func add<Entity: FirestoreEntity>(
        _ entity: Entity
    ) throws where Entity.CollectionReferenceContext == Void {
        try self.add(
            entity,
            context: ()
        )
    }
    
}

// MARK: - Update

extension Firebase.Firestore {
    
    /// Update a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to update.
    ///   - context: The FirestoreEntity CollectionReferenceContext.
    func update<Entity: FirestoreEntity>(
        _ entity: Entity,
        context: Entity.CollectionReferenceContext
    ) throws {
        // Initialize mutable entity
        var entity = entity
        // Check if Entity is a User
        if Entity.self is User.Type {
            // Set identifier to UID of current Firebase user
            // as a User document id must always be equal
            // to the FirebaseAuth user
            entity.id = try self.firebase.authentication.state.userAccount.uid
        }
        // Verify entity identifier is available
        guard let entityId = entity.id else {
            // Otherwise throw an error
            throw FirestoreEntityIdentifierMissingError()
        }
        // Update document
        try Entity
            .collectionReference(
                in: self.firebase.firebaseFirestore,
                context: context
            )
            .document(entityId)
            .setData(from: entity, completion: nil)
    }
    
    /// Update a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to update.
    func update<Entity: FirestoreEntity>(
        _ entity: Entity
    ) throws where Entity.CollectionReferenceContext == Void {
        try self.update(
            entity,
            context: ()
        )
    }
    
}

// MARK: - Delete

extension Firebase.Firestore {
    
    /// Delete a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to delete.
    ///   - context: The FirestoreEntity CollectionReferenceContext.
    func delete<Entity: FirestoreEntity>(
        _ entity: Entity,
        context: Entity.CollectionReferenceContext
    ) throws {
        // Verify entity identifier is available
        guard let entityId = entity.id else {
            // Otherwise throw an error
            throw FirestoreEntityIdentifierMissingError()
        }
        // Delete
        Entity
            .collectionReference(
                in: self.firebase.firebaseFirestore,
                context: context
            )
            .document(entityId)
            .delete(completion: nil)
    }
    
    /// Delete a FirestoreEntity
    /// - Parameters:
    ///   - entity: The FirestoreEntity to delete.
    func delete<Entity: FirestoreEntity>(
        _ entity: Entity
    ) throws where Entity.CollectionReferenceContext == Void {
        try self.delete(
            entity,
            context: ()
        )
    }
    
    /// Delete a sequence of FirestoreEntities
    /// - Parameters:
    ///   - entities: The FirestoreEntities to delete.
    ///   - context: The FirestoreEntity CollectionReferenceContext.
    func delete<Entities: Sequence>(
        _ entities: Entities,
        context: Entities.Element.CollectionReferenceContext
    ) where Entities.Element: FirestoreEntity {
        for entity in entities {
            try? self.delete(
                entity,
                context: context
            )
        }
    }
    
    /// Delete a sequence of FirestoreEntities
    /// - Parameters:
    ///   - entities: The FirestoreEntities to delete.
    func delete<Entities: Sequence>(
        _ entities: Entities
    ) where Entities.Element: FirestoreEntity, Entities.Element.CollectionReferenceContext == Void {
        for entity in entities {
            try? self.delete(
                entity,
                context: ()
            )
        }
    }
    
}

// MARK: - FirestoreEntityIdentifierMissingError

extension Firebase.Firestore {
    
    /// An FirestoreEntity Identifier missing Error
    struct FirestoreEntityIdentifierMissingError: Error {}
    
}