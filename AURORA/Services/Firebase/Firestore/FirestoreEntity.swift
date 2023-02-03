import FirebaseFirestore
import Foundation

// MARK: - FirestoreEntity

/// A Firestore Entity.
protocol FirestoreEntity: Codable, Hashable, Identifiable where Self.ID == String? {
    
    /// The CollectionReference Context type.
    associatedtype CollectionReferenceContext = Void
    
    /// The Firestore collection name.
    static var collectionName: String { get }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - context: The CollectionReferenceContext.
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore,
        context: CollectionReferenceContext
    ) -> FirebaseFirestore.CollectionReference
    
    /// The stable identity of the entity associated with this instance.
    var id: ID { get set }
    
}

// MARK: - Default-Implementation

extension FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        var collectionName = String(describing: Self.self)
        collectionName = collectionName.lowercased()
        let pluralSuffix: Character = "s"
        if collectionName.last != pluralSuffix {
            collectionName += .init(pluralSuffix)
        }
        return collectionName
    }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - context: The CollectionReferenceContext.
    static func collectionReference(
        context: CollectionReferenceContext
    ) -> FirebaseFirestore.CollectionReference {
        self.collectionReference(
            in: .firestore(),
            context: context
        )
    }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - context: The CollectionReferenceContext. Default value `()`
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore = .firestore(),
        context: CollectionReferenceContext = ()
    ) -> FirebaseFirestore.CollectionReference where CollectionReferenceContext == Void {
        firestore.collection(self.collectionName)
    }
    
}
