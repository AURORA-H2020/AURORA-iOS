import FirebaseFirestore
import Foundation

// MARK: - PhotovoltaicPlant

/// A photovoltaic (PV) plant.
struct PhotovoltaicPlant {
    
    /// The identifier
    @DocumentID
    var id: String?
    
    /// The photovoltaic installation identifier.
    let plantId: String
    
    /// The name.
    let name: String
    
    /// The date when the photovoltaic plant was first operational.
    let installationDate: Timestamp?
    
    /// The country entity reference.
    let country: FirestoreEntityReference<Country>
    
    /// The city entity reference.
    let city: FirestoreEntityReference<City>
    
    /// The manufacturer
    let manufacturer: String?
    
    /// The technology
    let technology: String?
    
    /// The capacity.
    let capacity: Double?
    
    /// The price per share
    let pricePerShare: Double?
    
    /// The kilowatt per share.
    let kwPerShare: Double?
    
    /// Boolean if the photovoltaic plant is active.
    let active: Bool
    
    /// The URL to the investment guide.
    let infoURL: String?
    
}

// MARK: - FirestoreEntity

extension PhotovoltaicPlant: FirestoreEntity {
    
    /// The Firestore collection name.
    static var collectionName: String {
        "pv-plants"
    }
    
}

extension PhotovoltaicPlant {
    
    var capacityMeasurement: Measurement<UnitPower>? {
        self.capacity.flatMap { capacity in
            .init(
                value: capacity,
                unit: .kilowatts
            )
        }
    }
    
}
