import FirebaseFirestore
import Foundation

// MARK: - PhotovoltaicPlantDataEntry

/// A photovoltaic (PV) plant data entry.
struct PhotovoltaicPlantDataEntry {
    
    /// The identifier.
    @DocumentID
    var id: String?
    
    /// The date.
    let date: Timestamp
    
    /// The produced energy (Ep)
    let producedEnergy: Double
    
}

// MARK: - FirestoreSubcollectionEntity

extension PhotovoltaicPlantDataEntry: FirestoreSubcollectionEntity {
    
    /// The parent FirestoreEntity.
    typealias ParentEntity = PhotovoltaicPlant
    
    /// The Firestore collection name.
    static var collectionName: String {
        "data"
    }
    
    /// The order by created at predicate.
    static let pastThirtyDaysPredicate = QueryPredicate.whereField(
        "date",
        isGreaterThanOrEqualTo: Calendar.current.date(byAdding: .day, value: -30, to: .init()) ?? .init()
    )
    
    /// The coding keys.
    private enum CodingKeys: String, CodingKey {
        case date
        case producedEnergy = "Ep"
    }
    
    /// Creates a new instance of ``PhotovoltaicPlantDataEntry``
    /// - Parameter decoder: The decoder.
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try .init(from: decoder)
        self.date = try container.decode(Timestamp.self, forKey: .date)
        self.producedEnergy = try container.decode(Double.self, forKey: .producedEnergy)
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try self.id?.encode(to: encoder)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.producedEnergy, forKey: .producedEnergy)
    }
    
}
