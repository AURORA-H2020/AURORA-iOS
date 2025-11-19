import SwiftUI

// MARK: - PhotovoltaicPlantInvestmentList

/// The PhotovoltaicPlantInvestmentList
struct PhotovoltaicPlantInvestmentList {
    
    // MARK: Properties
    
    /// The photovoltaic plant.
    private let photovoltaicPlant: PhotovoltaicPlant
    
    /// The presented photovoltaic plant investment form mode.
    @State
    private var presentedPhotovoltaicPlantInvestmentFormMode: PhotovoltaicPlantInvestmentForm.Mode?
    
    /// The photovoltaic plant investements.
    @FirestoreEntityQuery
    private var photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
    
    // MARK: Initializer
    
    /// Creates a new instance of ``PhotovoltaicPlantInvestmentList``
    /// - Parameters:
    ///   - photovoltaicPlant: The photovoltaic plant.
    ///   - userEntityReference: The user entity reference.
    init(
        photovoltaicPlant: PhotovoltaicPlant,
        userEntityReference: FirestoreEntityReference<User>
    ) {
        self.photovoltaicPlant = photovoltaicPlant
        self._photovoltaicPlantInvestments = .init(
            context: userEntityReference,
            predicates: [
                PhotovoltaicPlantInvestment.orderByInvestmentDatePredicate
            ]
        )
    }
    
}

// MARK: - View

extension PhotovoltaicPlantInvestmentList: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            ForEach(self.photovoltaicPlantInvestments) { photovoltaicPlantInvestment in
                Cell(
                    photovoltaicPlantInvestment: photovoltaicPlantInvestment,
                    presentedPhotovoltaicPlantInvestmentFormMode: self.$presentedPhotovoltaicPlantInvestmentFormMode
                )
            }
        }
        .navigationTitle("Your Investments")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.presentedPhotovoltaicPlantInvestmentFormMode = .create(self.photovoltaicPlant)
                } label: {
                    Image(systemName: "plus")
                }
            }
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
    }
    
}
