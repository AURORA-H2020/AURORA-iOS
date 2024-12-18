import FirebaseFirestore
import Foundation

// MARK: - PhotovoltaicPlantInvestment

/// A photovoltaic plant investment.
struct PhotovoltaicPlantInvestment {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The creation date.
    @ServerTimestamp
    var createdAt: Timestamp?
    
    /// The date when the consumption has been updated.
    var updatedAt: Timestamp?
    
    /// The city entity reference.
    var city: FirestoreEntityReference<City>
    
    /// The photovoltaic plant entity reference.
    var pvPlant: FirestoreEntityReference<PhotovoltaicPlant>
    
    /// The user's monetary investment in the installation.
    var investmentPrice: Double?
    
    /// The user's investment capacity in the installation in kW.
    var investmentCapacity: Double?
    
    /// The user's share in the installation.
    var share: Double
    
    /// The user's investment date.
    var investmentDate: Timestamp
    
    /// The user's note about the investment.
    var note: String?
    
}

// MARK: - FirestoreSubcollectionEntity

extension PhotovoltaicPlantInvestment: FirestoreSubcollectionEntity {
    
    /// The parent FirestoreEntity.
    typealias ParentEntity = User
    
    /// The Firestore collection name.
    static var collectionName: String {
        "pv-investments"
    }
    
}
