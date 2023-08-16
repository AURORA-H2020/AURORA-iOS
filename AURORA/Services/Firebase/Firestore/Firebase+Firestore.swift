import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

// swiftlint:disable file_length

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
            // Verify document exists
            guard snapshot.exists else {
                // Otherwise return nil
                return nil
            }
            // Try to decode data as Entity
            return try? self.firebase.crashlytics.recordError(
                userInfo: [
                    "Path": snapshot.reference.path
                ]
            ) {
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
    
    /// Retrieve FirestoreSubcollectionEntity
    /// - Parameters:
    ///   - entityType: The FirestoreSubcollectionEntity Type.
    ///   - wherePredicate: A closure which takes in a Query to attach where conditions.
    func getCollectionGroup<Entity: FirestoreSubcollectionEntity>(
        _ entityType: Entity.Type,
        where wherePredicate: (FirebaseFirestore.Query) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> [Entity] {
        try await wherePredicate(
            Entity
                .collectionGroupQuery(
                    in: self.firebase.firebaseFirestore
                )
        )
        .getDocuments()
        .documents
        .compactMap { snapshot in
            // Verify document exists
            guard snapshot.exists else {
                // Otherwise return nil
                return nil
            }
            // Try to decode data as Entity
            return try? self.firebase.crashlytics.recordError(
                userInfo: [
                    "Path": snapshot.reference.path
                ]
            ) {
                try snapshot.data(as: Entity.self)
            }
        }
    }
    
}

// MARK: - Count

extension Firebase.Firestore {
    
    /// Retrieve the count of FirestoreEntities which are saved in Firestore.
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - context: The CollectionReferenceContext
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func count<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        context: Entity.CollectionReferenceContext,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> Int {
        try await wherePredicate(
            Entity
                .collectionReference(
                    in: self.firebase.firebaseFirestore,
                    context: context
                )
        )
        .count
        .getAggregation(source: .server)
        .count
        .intValue
    }
    
    /// Retrieve the count of FirestoreEntities which are saved in Firestore.
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func count<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) async throws -> Int where Entity.CollectionReferenceContext == Void {
        try await self.count(
            entityType,
            context: (),
            where: wherePredicate
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
    ) -> some Publisher<[Result<Entity, Error>], Never> {
        wherePredicate(
            Entity
                .collectionReference(
                    in: self.firebase.firebaseFirestore,
                    context: context
                )
        )
        .snapshotPublisher()
        .map { result in
            switch result {
            case .success(let snapshot):
                return snapshot
                    .documents
                    .compactMap { snapshot in
                        guard snapshot.exists else {
                            return nil
                        }
                        return .init {
                            try self.firebase.crashlytics.recordError(
                                userInfo: [
                                    "Path": snapshot.reference.path
                                ]
                            ) {
                                try snapshot.data(as: Entity.self)
                            }
                        }
                    }
            case .failure(let error):
                self.firebase.crashlytics.record(error: error)
                return [.failure(error)]
            }
        }
    }
    
    /// A Publisher which emits FirestoreEntities
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - wherePredicate: A closure which takes in a CollectionReference to attach where conditions.
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        where wherePredicate: (FirebaseFirestore.CollectionReference) -> FirebaseFirestore.Query = { $0 }
    ) -> some Publisher<[Result<Entity, Error>], Never> where Entity.CollectionReferenceContext == Void {
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
    ) -> some Publisher<Result<Entity?, Error>, Never> {
        Entity
            .collectionReference(
                in: self.firebase.firebaseFirestore,
                context: context
            )
            .document(id)
            .snapshotPublisher()
            .map { result in
                switch result {
                case .success(let snapshot):
                    guard snapshot.exists else {
                        return .success(nil)
                    }
                    return .init {
                        try self.firebase.crashlytics.recordError(
                            userInfo: [
                                "Path": snapshot.reference.path
                            ]
                        ) {
                            try snapshot.data(as: Entity.self)
                        }
                    }
                case .failure(let error):
                    self.firebase.crashlytics.record(error: error)
                    return .failure(error)
                }
            }
    }
    
    /// A Publisher that emits a FirestoreEntity
    /// - Parameters:
    ///   - entityType: The FirestoreEntity Type.
    ///   - id: The FirestoreEntity Identifier
    func publisher<Entity: FirestoreEntity>(
        _ entityType: Entity.Type,
        id: String
    ) -> some Publisher<Result<Entity?, Error>, Never> where Entity.CollectionReferenceContext == Void {
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
            try self.firebase.crashlytics.recordError {
                try Entity
                    .collectionReference(
                        in: self.firebase.firebaseFirestore,
                        context: context
                    )
                    .addDocument(from: entity)
            }
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
        try self.firebase.crashlytics.recordError {
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
                throw FirestoreEntityIdentifierMissingError(entity: entity)
            }
            // Update document
            try Entity
                .collectionReference(
                    in: self.firebase.firebaseFirestore,
                    context: context
                )
                .document(entityId)
                .setData(
                    from: entity,
                    merge: true
                )
        }
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
            throw FirestoreEntityIdentifierMissingError(entity: entity)
        }
        // Delete
        Entity
            .collectionReference(
                in: self.firebase.firebaseFirestore,
                context: context
            )
            .document(entityId)
            .delete()
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

// MARK: - FirebaseFirestore+Query+snapshotPublisher

private extension FirebaseFirestore.Query {
    
    /// Returns a publisher that emits a `Result` containing a `FirebaseFirestore.QuerySnapshot` or an `Error` if one occurs.
    /// - Parameters:
    ///     - includeMetadataChanges: A boolean value indicating whether metadata-only changes should trigger snapshot events.
    /// - Returns: An `AnyPublisher` that emits a `Result` containing a `FirebaseFirestore.QuerySnapshot` or an `Error`.
    func snapshotPublisher(
        includeMetadataChanges: Bool = false
    ) -> some Publisher<Result<FirebaseFirestore.QuerySnapshot, Error>, Never> {
        let subject = PassthroughSubject<Result<FirebaseFirestore.QuerySnapshot, Error>, Never>()
        let snapshotListenerRegistration = self.addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges
        ) { snapshot, error in
            if let error = error {
                subject.send(.failure(error))
            } else if let snapshot = snapshot {
                subject.send(.success(snapshot))
            }
        }
        return subject
            .handleEvents(
                receiveCancel: snapshotListenerRegistration.remove
            )
    }
    
}

// MARK: - FirebaseFirestore+DocumentReference+snapshotPublisher

private extension FirebaseFirestore.DocumentReference {
    
    /// Returns a publisher that emits a `Result` containing a `FirebaseFirestore.DocumentSnapshot` or an `Error` if an error occurs.
    /// - Parameters:
    ///     - includeMetadataChanges: A boolean value indicating whether metadata changes should be included in the snapshot.
    /// - Returns: An `AnyPublisher` that emits a `Result` containing a `FirebaseFirestore.DocumentSnapshot` or an `Error`.
    func snapshotPublisher(
        includeMetadataChanges: Bool = false
    ) -> some Publisher<Result<FirebaseFirestore.DocumentSnapshot, Error>, Never> {
        let subject = PassthroughSubject<Result<FirebaseFirestore.DocumentSnapshot, Error>, Never>()
        let snapshotListenerRegistration = self.addSnapshotListener(
            includeMetadataChanges: includeMetadataChanges
        ) { snapshot, error in
            if let error = error {
                subject.send(.failure(error))
            } else if let snapshot = snapshot {
                subject.send(.success(snapshot))
            }
        }
        return subject
            .handleEvents(
                receiveCancel: snapshotListenerRegistration.remove
            )
    }
    
}
