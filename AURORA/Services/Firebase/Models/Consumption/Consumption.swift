import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

// MARK: - Consumption

/// A Consumption
struct Consumption {
    
    // MARK: Properties

    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The creation date.
    @ServerTimestamp
    var createdAt: Timestamp?
    
    /// The date when the consumption has been update.
    var updatedAt: Timestamp?
    
    /// The category of the consumption.
    var category: Category
    
    /// The optional electricity information.
    var electricity: Electricity?
    
    /// The optional heating information.
    var heating: Heating?
    
    /// The optional transportation information.
    var transportation: Transportation?
    
    /// The value
    var value: Double
    
    /// The carbon emissions
    let carbonEmissions: Decimal?

    // MARK: Initializer

    /// Creates a new instance of `Consumption`
    /// - Parameters:
    ///   - id: The identifier. Default value `nil`
    ///   - createdAt: The creation date. Default value `nil`
    ///   - updatedAt: The date when the consumption has been updated. Default value `nil`
    ///   - category: The category of the consumption.
    ///   - electricity: The optional electricity information. Default value `nil`
    ///   - heating: The optional heating information. Default value `nil`
    ///   - transportation: The optional transportation information. Default value `nil`
    ///   - value: The value.
    ///   - carbonEmissions: The carbon emissions.
    init(
        id: String? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil,
        category: Category,
        electricity: Electricity? = nil,
        heating: Heating? = nil,
        transportation: Transportation? = nil,
        value: Double,
        carbonEmissions: Decimal? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.electricity = electricity
        self.heating = heating
        self.transportation = transportation
        self.value = value
        self.carbonEmissions = carbonEmissions
    }
    
}

// MARK: - Consumption+FirestoreEntity

extension Consumption: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "consumptions"
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
    static let orderByCreatedAtPredicate = QueryPredicate.order(by: "createdAt")
    
}

// MARK: - Consumption+formattedValue

extension Consumption {
    
    /// A formatted representation of the consumptions' value.
    var formattedValue: String {
        switch self.category {
        case .transportation:
            return Measurement<UnitLength>(
                value: self.value,
                unit: .kilometers
            )
            .formatted()
        case .heating, .electricity:
            return Measurement<UnitPower>(
                value: self.value,
                unit: .kilowatts
            )
            .formatted()
        }
    }
    
}