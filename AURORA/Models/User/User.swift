import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - User

/// A User
struct User {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The first name.
    var firstName: String
    
    /// The last name.
    var lastName: String
    
    /// The year of birth.
    var yearOfBirth: Int?
    
    /// The gender.
    var gender: Gender?
    
    /// The Site Reference.
    var site: FirestoreEntityReference<Site>
    
    /// The optional consumption summary.
    let consumptionSummary: ConsumptionSummary?
    
}

// MARK: - User+FirestoreEntity

extension User: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "users"
    }
    
}

// MARK: - User+name

extension User {
    
    /// The formatted name.
    /// - Parameter formatter: The PersonNameComponentsFormatter. Default value `.init()`
    func name(
        formatter: PersonNameComponentsFormatter = .init()
    ) -> String {
        var components = PersonNameComponents()
        components.givenName = self.firstName
        components.familyName = self.lastName
        return formatter.string(from: components)
    }
    
}
