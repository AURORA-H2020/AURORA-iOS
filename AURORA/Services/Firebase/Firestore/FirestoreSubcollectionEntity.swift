import FirebaseFirestore
import Foundation

// MARK: - FirestoreSubcollectionEntity

/// A Firestore Subcollection Entity.
protocol FirestoreSubcollectionEntity: FirestoreEntity {
    
    /// The parent FirestoreEntity.
    associatedtype ParentEntity: FirestoreEntity
    
}

// MARK: - Default-Implementation

extension FirestoreSubcollectionEntity {
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - context: The FirestoreEntityReference to the parent FirestoreEntity.
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore,
        context: FirestoreEntityReference<ParentEntity>
    ) -> FirebaseFirestore.CollectionReference {
        firestore
            .collection(ParentEntity.collectionName)
            .document(context.id)
            .collection(Self.collectionName)
    }
    
}

// MARK: - CollectionGroup Query

extension FirestoreSubcollectionEntity {
    
    /// The Firestore CollectionGroup Query
    /// - Parameter firestore: The Firestore instance.
    static func collectionGroupQuery(
        in firestore: FirebaseFirestore.Firestore
    ) -> FirebaseFirestore.Query {
        firestore.collectionGroup(Self.collectionName)
    }
    
}

// MARK: - CollectionReference

extension FirestoreSubcollectionEntity where CollectionReferenceContext == FirestoreEntityReference<User> {
    
    /// The Firestore CollectionReference using the FirestoreEntityReference of the currently authenticated user.
    static var collectionReference: FirebaseFirestore.CollectionReference {
        get throws {
            try self.collectionReference(context: .current())
        }
    }
    
}
