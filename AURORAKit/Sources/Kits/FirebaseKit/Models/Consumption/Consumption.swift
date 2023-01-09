import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - Consumption

/// A Consumption
public struct Consumption {
    
    // MARK: Properties

    /// The identifier
    @DocumentID
    public var id: String?
    
    /// The Date
    @ServerTimestamp
    public var createdAt: Timestamp?
    
    /// The ConsumptionType
    public var type: ConsumptionType
    
    /// The value
    public var value: Double
    
    /// The carbon emissions
    public let carbonEmissions: Double?

    // MARK: Initializer

    /// Creates a new instance of `Consumption`
    /// - Parameters:
    ///   - id: The identifier. Default value `nil`
    ///   - createdAt: The creation date. Default value `nil`
    ///   - type: ConsumptionType
    ///   - value: The value
    ///   - carbonEmissions: The carbon emissions
    public init(
        id: String? = nil,
        createdAt: Timestamp? = nil,
        type: ConsumptionType,
        value: Double,
        carbonEmissions: Double? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.value = value
        self.carbonEmissions = carbonEmissions
    }
    
}

// MARK: - Consumption+FirestoreEntity

extension Consumption: FirestoreEntity {
    
    /// The Firestore collection name.
    public static var collectionName: String {
        "consumptions"
    }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - parameter: The Firebase User.
    public static func collectionReference(
        in firestore: FirebaseFirestore.Firestore,
        _ user: FirebaseAuth.User
    ) -> FirebaseFirestore.CollectionReference {
        firestore
            .collection(User.collectionName)
            .document(user.uid)
            .collection(self.collectionName)
    }
    
}
