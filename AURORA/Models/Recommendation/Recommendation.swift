import FirebaseFirestore
import Foundation

// MARK: - Recommendation

/// A Recommendation
struct Recommendation {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The recommendation type.
    var type: String
    
    /// The creation date.
    @ServerTimestamp
    var createdAt: Timestamp?
    
    /// The date when the recommendation was updated.
    var updatedAt: Timestamp?
    
    /// The optional notification date.
    var notifyAt: Timestamp?
    
    /// The recommendation title.
    var title: String?
    
    /// The recommendation message.
    var message: String
    
    /// The rationale for the recommendation.
    var rationale: String
    
    /// The recommendation priority.
    var priority: Int
    
    /// The optional external link.
    var link: String?
    
    /// Bool value whether the recommendation was read.
    var isRead: Bool?
    
}

// MARK: - Recommendation+FirestoreSubcollectionEntity

extension Recommendation: FirestoreSubcollectionEntity {
    
    /// The parent FirestoreEntity.
    typealias ParentEntity = User
    
    /// The Firestore collection name.
    static var collectionName: String {
        "recommendations"
    }
    
    /// The order by created at predicate.
    static let orderByCreatedAtPredicate = QueryPredicate.order(by: "createdAt", descending: true)
    
}

// MARK: - Display Title

extension Recommendation {
    
    /// The recommendation title displayed in the UI.
    var displayTitle: String {
        let title = self.title?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return title?.isEmpty == false ? title! : String(localized: "Recommendation")
    }
    
    /// The created at date value, if available.
    var createdAtDate: Date? {
        self.createdAt?.dateValue()
    }
    
    /// The external link URL, if available.
    var linkURL: URL? {
        self.link.flatMap(URL.init)
    }
    
}
