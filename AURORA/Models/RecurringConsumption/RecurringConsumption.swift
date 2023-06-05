import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - RecurringConsumption

/// A recurring consumption
struct RecurringConsumption {

    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The creation date.
    @ServerTimestamp
    var createdAt: Timestamp?
    
    /// The category.
    var category: Consumption.Category
    
    /// The frequency.
    var frequency: Frequency
    
    /// The transportation information.
    var transportation: Transportation?
    
}

// MARK: - RecurringConsumption+FirestoreEntity

extension RecurringConsumption: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "recurring-consumptions"
    }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - parameter: The Firebase User Identifier.
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore,
        context userUID: User.UID
    ) -> FirebaseFirestore.CollectionReference {
        firestore
            .collection(User.collectionName)
            .document(userUID.id)
            .collection(self.collectionName)
    }
    
    /// The Firestore CollectionReference..
    static var collectionReference: FirebaseFirestore.CollectionReference {
        get throws {
            try self.collectionReference(context: .current())
        }
    }
    
    /// The order by created at predicate.
    static let orderByCreatedAtPredicate = QueryPredicate.order(
        by: "createdAt",
        descending: true
    )
    
}

// MARK: - RecurringConsumption+supportedCategories

extension RecurringConsumption {
    
    /// The supported consumption categories
    static let supportedCategories: [Consumption.Category] = [
        .transportation
    ]
    
}
