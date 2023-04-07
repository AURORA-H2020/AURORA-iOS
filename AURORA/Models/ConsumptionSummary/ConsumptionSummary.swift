import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - ConsumptionSummary+Entry

/// A consumption summary entry
struct ConsumptionSummary {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The year.
    let year: Int
    
    /// The carbon emission labeled consumption.
    let carbonEmission: LabeledConsumption
    
    /// The enerfy expended labeled consumption.
    let energyExpended: LabeledConsumption
    
    /// The categories.
    let categories: [Category]
    
    /// The months.
    let months: [Month]
    
}

// MARK: - ConsumptionSummary+FirestoreEntity

extension ConsumptionSummary: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "consumption-summaries"
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
    
    /// The order by year predicate.
    static let orderByYearPredicate = QueryPredicate.order(by: "year", descending: true)
    
}

// MARK: - ConsumptionSummary+Comparable

extension ConsumptionSummary: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.year < rhs.year
    }
    
}

// MARK: - ConsumptionSummary+category

extension ConsumptionSummary {
    
    /// Returns the first category in the categories array that matches the specified category.
    /// - Parameter category: The category to match.
    func category(
        _ category: Consumption.Category
    ) -> Category? {
        self.categories.first { $0.category == category }
    }
    
}

// MARK: - ConsumptionSummary+labeledConsumption

extension ConsumptionSummary {
    
    /// Retrieve a LabeledConsumption for a given Mode.
    /// - Parameter mode: The Mode.
    func labeledConsumption(
        for mode: Mode
    ) -> LabeledConsumption {
        switch mode {
        case .carbonEmission:
            return self.carbonEmission
        case .energyExpended:
            return self.energyExpended
        }
    }
    
}
