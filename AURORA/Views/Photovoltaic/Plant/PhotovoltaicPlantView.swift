import SwiftUI

// MARK: - PhotovoltaicPlantView

/// The PhotovoltaicPlantView
struct PhotovoltaicPlantView {
    
    // MARK: Properties
    
    /// The photovoltaic plant.
    private let photovoltaicPlant: PhotovoltaicPlant
    
    /// The user entity reference.
    private let userEntityReference: FirestoreEntityReference<User>
    
    /// Boolean if help is presented.
    @State
    private var isHelpPresented = false
    
    /// The presented photovoltaic plant investment form mode.
    @State
    private var presentedPhotovoltaicPlantInvestmentFormMode: PhotovoltaicPlantInvestmentForm.Mode?
    
    /// The photovoltaic plant data entries.
    @FirestoreEntityQuery
    private var photovoltaicPlantDataEntries: [PhotovoltaicPlantDataEntry]
    
    /// The photovoltaic plant investements.
    @FirestoreEntityQuery
    private var photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
    
    // MARK: Initializer
    
    /// Creates a new instance of ``PhotovoltaicPlantView``
    /// - Parameters:
    ///   - photovoltaicPlant: The photovoltaic plant.
    ///   - photovoltaicPlantEntityReference: The photovoltaic plant entity reference.
    ///   - userEntityReference: The user entity reference.
    init(
        photovoltaicPlant: PhotovoltaicPlant,
        photovoltaicPlantEntityReference: FirestoreEntityReference<PhotovoltaicPlant>,
        userEntityReference: FirestoreEntityReference<User>
    ) {
        self.photovoltaicPlant = photovoltaicPlant
        self.userEntityReference = userEntityReference
        self._photovoltaicPlantDataEntries = .init(
            context: photovoltaicPlantEntityReference,
            predicates: [
                PhotovoltaicPlantDataEntry.pastThirtyDaysPredicate,
                PhotovoltaicPlantDataEntry.orderByDatePredicate
            ]
        )
        self._photovoltaicPlantInvestments = .init(
            context: userEntityReference,
            predicates: [
                PhotovoltaicPlantInvestment
                    .photovoltaicPlantPredicate(
                        entityReference: photovoltaicPlantEntityReference
                    ),
                PhotovoltaicPlantInvestment.orderByInvestmentDatePredicate
            ]
        )
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            ChartSection(
                photovoltaicPlant: self.photovoltaicPlant,
                photovoltaicPlantDataEntries: self.photovoltaicPlantDataEntries,
                photovoltaicPlantInvestments: self.photovoltaicPlantInvestments,
                isHelpPresented: self.$isHelpPresented,
                presentedPhotovoltaicPlantInvestmentFormMode: self.$presentedPhotovoltaicPlantInvestmentFormMode
            )
            InvestmentSection(
                photovoltaicPlant: self.photovoltaicPlant,
                userEntityReference: self.userEntityReference,
                latestPhotovoltaicPlantInvestment: self.photovoltaicPlantInvestments.first,
                presentedPhotovoltaicPlantInvestmentFormMode: self.$presentedPhotovoltaicPlantInvestmentFormMode
            )
            InformationSection(
                photovoltaicPlant: photovoltaicPlant
            )
        }
        .sheet(
            item: self.$presentedPhotovoltaicPlantInvestmentFormMode
        ) { mode in
            SheetNavigationView {
                PhotovoltaicPlantInvestmentForm(
                    mode: mode
                )
            }
        }
        .sheet(
            isPresented: self.$isHelpPresented
        ) {
            SheetNavigationView {
                HelpView(
                    photovoltaicPlant: self.photovoltaicPlant
                )
            }
            .presentationDetents([.medium, .large])
        }
    }
    
}
