import FirebaseFirestoreSwift
import Foundation

// MARK: - User

/// A User
public struct User: Codable, Hashable, Identifiable {
    
    // MARK: Properties
    
    /// The identifier.
    @DocumentID
    public var id: String?
    
    /// The first name.
    public var firstName: String
    
    /// The last name.
    public var lastName: String
    
    /// The year of birth.
    public var yearOfBirth: Int
    
    /// The gender.
    public var gender: Gender
    
    // MARK: Initializer
    
    /// Creates a new instance of `User`
    /// - Parameters:
    ///   - id: The identifier.
    ///   - firstName: The first name.
    ///   - lastName: The last name.
    ///   - yearOfBirth: The year of birth.
    ///   - gender: The Gender.
    public init(
        id: String? = nil,
        firstName: String,
        lastName: String,
        yearOfBirth: Int,
        gender: Gender
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.yearOfBirth = yearOfBirth
        self.gender = gender
    }
    
}
