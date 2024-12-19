import SwiftUI

// MARK: - PhotovoltaicPlantView

/// The PhotovoltaicPlantView
struct PhotovoltaicPlantView {
    
    // MARK: Properties
    
    /// The mode.
    @State
    private var mode: Mode = .personal
    
    /// The photovoltaic plant.
    private let photovoltaicPlant: PhotovoltaicPlant
    
    /// The photovoltaic plant data.
    @FirestoreEntityQuery
    private var photovoltaicPlantData: [PhotovoltaicPlantDataEntry]
    
    // MARK: Initializer
    
    /// Creates a new instance of ``PhotovoltaicPlantView``
    /// - Parameters:
    ///   - photovoltaicPlant: The photovoltaic plant.
    ///   - photovoltaicPlantEntityReference: The photovoltaic plant entity reference.
    init(
        photovoltaicPlant: PhotovoltaicPlant,
        photovoltaicPlantEntityReference: FirestoreEntityReference<PhotovoltaicPlant>
    ) {
        self.photovoltaicPlant = photovoltaicPlant
        self._photovoltaicPlantData = .init(
            context: photovoltaicPlantEntityReference,
            predicates: [
                PhotovoltaicPlantDataEntry.pastThirtyDaysPredicate
            ]
        )
    }
    
}

// MARK: - Mode

extension PhotovoltaicPlantView {
    
    /// A mode.
    enum Mode: String, Codable, Hashable, Sendable, Identifiable, CaseIterable {
        /// Personal.
        case personal
        /// Total.
        case total
        
        /// The stable identity of the entity associated with this instance.
        var id: RawValue {
            self.rawValue
        }
        
        /// The localized string.
        var localizedString: String {
            switch self {
            case .personal:
                return .init(localized: "Your Production")
            case .total:
                return .init(localized: "Total Production")
            }
        }
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            ChartSection(
                mode: self.$mode,
                photovoltaicPlantData: self.photovoltaicPlantData
            )
            HelpSection(
                photovoltaicPlant: photovoltaicPlant
            )
            InvestmentSection()
            InformationSection(
                photovoltaicPlant: photovoltaicPlant
            )
            TotalProductionSection(
                photovoltaicPlantData: self.photovoltaicPlantData
            )
        }
    }
    
}
