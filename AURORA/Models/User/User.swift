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
    
    /// The Country Reference.
    var country: FirestoreEntityReference<Country>
    
    /// The optional City Reference.
    var city: FirestoreEntityReference<City>?
    
    /// The home energy label.
    var homeEnergyLabel: HomeEnergyLabel?
    
    /// The household profile.
    var householdProfile: HouseholdProfile?
    
    /// Bool value if marketing consent is allowed.
    var isMarketingConsentAllowed: Bool?
    
    /// The accepted legal document version.
    var acceptedLegalDocumentVersion: Int?
    
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

// MARK: - FirestoreEntityReference<User>+current()

extension FirestoreEntityReference where Destination == User {
    
    /// Retrieve the currently authenticated user reference
    /// - Parameter firebase: The Firebase instance. Default value `.default`
    static func current(
        firebase: Firebase = .default
    ) throws -> Self {
        .init(
            id: try firebase
                .authentication
                .state
                .userAccount
                .id
        )
    }
    
}
