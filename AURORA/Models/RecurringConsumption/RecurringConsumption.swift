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
    
    /// Bool value if is enabled
    var isEnabled: Bool
    
    /// The category.
    var category: Consumption.Category
    
    /// The frequency.
    var frequency: Frequency
    
    /// The transportation information.
    var transportation: Transportation?
    
    /// The optional description
    var description: String?
    
}

// MARK: - RecurringConsumption+FirestoreSubcollectionEntity

extension RecurringConsumption: FirestoreSubcollectionEntity {
    
    /// The parent FirestoreEntity.
    typealias ParentEntity = User
    
    /// The Firestore collection name.
    static var collectionName: String {
        "recurring-consumptions"
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
