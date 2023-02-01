import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - User

/// A User
struct User {
    
    // MARK: Properties
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The first name.
    var firstName: String
    
    /// The last name.
    var lastName: String
    
    /// The year of birth.
    var yearOfBirth: Int
    
    /// The gender.
    var gender: Gender
    
    /// The Site Reference.
    var site: FirestoreEntityReference<Site>
    
    /// The optional consumption summary.
    let consumptionSummary: ConsumptionSummary?
    
    // MARK: Initializer
    
    /// Creates a new instance of `User`
    /// - Parameters:
    ///   - id: The identifier. Default value `nil`
    ///   - firstName: The first name.
    ///   - lastName: The last name.
    ///   - yearOfBirth: The year of birth.
    ///   - gender: The Gender.
    ///   - site: The Site Reference.
    ///   - consumptionSummary: The optional consumption summary. Default value `nil`
    init(
        id: String? = nil,
        firstName: String,
        lastName: String,
        yearOfBirth: Int,
        gender: Gender,
        site: FirestoreEntityReference<Site>,
        consumptionSummary: ConsumptionSummary? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.yearOfBirth = yearOfBirth
        self.gender = gender
        self.site = site
        self.consumptionSummary = consumptionSummary
    }
    
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

// MARK: - User+age

extension User {
    
    /// The current age.
    /// - Parameter calendar: The Calendar. Default value `.current`
    func age(
        calendar: Calendar = .current
    ) -> Int {
        calendar.component(.year, from: .init()) - self.yearOfBirth
    }
    
}
