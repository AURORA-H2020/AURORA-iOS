import FirebaseFirestore
import Foundation

// MARK: - FirestoreEntity

/// A Firestore Entity.
public protocol FirestoreEntity: Codable, Hashable, Identifiable where Self.ID == String? {
    
    /// The CollectionReference Parameter type.
    associatedtype CollectionReferenceParameter = Void
    
    /// The Firestore collection name.
    static var collectionName: String { get }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - parameter: The CollectionReferenceParameter.
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore,
        _ parameter: CollectionReferenceParameter
    ) -> FirebaseFirestore.CollectionReference
    
    /// The stable identity of the entity associated with this instance.
    var id: ID { get set }
    
}

// MARK: - Default-Implementations

public extension FirestoreEntity {
    
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
    ///   - parameter: The CollectionReferenceParameter.
    static func collectionReference(
        _ parameter: CollectionReferenceParameter
    ) -> FirebaseFirestore.CollectionReference {
        self.collectionReference(
            in: .firestore(),
            parameter
        )
    }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - parameter: The CollectionReferenceParameter. Default value `()`
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore = .firestore(),
        _ parameter: CollectionReferenceParameter = ()
    ) -> FirebaseFirestore.CollectionReference where CollectionReferenceParameter == Void {
        firestore.collection(self.collectionName)
    }
    
}
