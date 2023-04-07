import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - City

/// A City
struct City {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The name of the city.
    let name: String
    
    /// Bool value if the city has a photovoltaic installation
    let hasPhotovoltaics: Bool?
    
    /// The PVGIS parameters
    let pvgisParams: PVGISParams?
    
}

// MARK: - City+FirestoreEntity

extension City: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "cities"
    }
    
    /// The Firestore CollectionReference.
    /// - Parameters:
    ///   - firestore: The Firestore instance.
    ///   - parameter: The Firebase User Identifier.
    static func collectionReference(
        in firestore: FirebaseFirestore.Firestore,
        context countryId: String
    ) -> FirebaseFirestore.CollectionReference {
        firestore
            .collection(Country.collectionName)
            .document(countryId)
            .collection(self.collectionName)
    }
    
}

// MARK: - Country+Comparable

extension City: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
    
}
