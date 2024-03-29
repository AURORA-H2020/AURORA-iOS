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
    
    /// The date when the consumption has been updated.
    var updatedAt: Timestamp?
    
    /// The category of the consumption.
    var category: Category
    
    /// The optional electricity information.
    var electricity: Electricity?
    
    /// The optional heating information.
    var heating: Heating?
    
    /// The optional transportation information.
    var transportation: Transportation?
    
    /// The value.
    var value: Double
    
    /// The optional description
    var description: String?
    
    /// The carbon emissions.
    let carbonEmissions: Double?
    
    /// The energy expenditure.
    let energyExpended: Double?
    
    /// The recurring consumption reference which auto generated this consumption.
    let generatedByRecurringConsumptionId: FirestoreEntityReference<RecurringConsumption>?
    
    // MARK: Initializer
    
    /// Creates a new instance of `Consumption`
    /// - Parameters:
    ///   - id: The identifier
    ///   - createdAt: The creation date.
    ///   - updatedAt: The date when the consumption has been updated.
    ///   - category: The category of the consumption.
    ///   - electricity: The optional electricity information.
    ///   - heating: The optional heating information.
    ///   - transportation: The optional transportation information.
    ///   - value: The value
    ///   - description: The optional description.
    ///   - carbonEmissions: The carbon emissions.
    ///   - energyExpended: The energy expenditure.
    ///   - generatedByRecurringConsumptionId: The recurring consumption reference which auto generated this consumption.
    init(
        id: String? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil,
        category: Category,
        electricity: Electricity? = nil,
        heating: Heating? = nil,
        transportation: Transportation? = nil,
        value: Double,
        description: String? = nil,
        carbonEmissions: Double? = nil,
        energyExpended: Double? = nil,
        generatedByRecurringConsumptionId: FirestoreEntityReference<RecurringConsumption>? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.electricity = electricity
        self.heating = heating
        self.transportation = transportation
        self.value = value
        self.description = description
        self.carbonEmissions = carbonEmissions
        self.energyExpended = energyExpended
        self.generatedByRecurringConsumptionId = generatedByRecurringConsumptionId
    }
    
}

// MARK: - Consumption+FirestoreSubcollectionEntity

extension Consumption: FirestoreSubcollectionEntity {

    /// The parent FirestoreEntity.
    typealias ParentEntity = User
    
    /// The Firestore collection name.
    static var collectionName: String {
        "consumptions"
    }
    
    /// The order by created at predicate.
    static let orderByCreatedAtPredicate = QueryPredicate.order(by: "createdAt", descending: true)
    
}

// MARK: - Consumption+formattedValue

extension Consumption {
    
    /// A formatted representation of the consumptions' value.
    var formattedValue: String {
        switch self.category {
        case .transportation:
            return self.value.formatted(.kilometers)
        case .heating, .electricity:
            return self.value.formatted(.kilowattHours)
        }
    }
    
}

// MARK: - Consumption+startDate

extension Consumption {
    
    /// The date when the consumption has been started, if available
    var startDate: Date? {
        switch self.category {
        case .electricity:
            return self.electricity?.startDate.dateValue()
        case .heating:
            return self.heating?.startDate.dateValue()
        case .transportation:
            return self.transportation?.dateOfTravel.dateValue()
        }
    }
    
}
