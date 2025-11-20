import SwiftUI

// MARK: - PhotovoltaicScreen

/// The PhotovoltaicScreen
struct PhotovoltaicScreen {
    
    /// The User.
    let user: User
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension PhotovoltaicScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            Group {
                switch self.firebase.photovoltaicPlant {
                case .success(let photovoltaicPlant):
                    if let photovoltaicPlant,
                       photovoltaicPlant.active,
                       let photovoltaicPlantEntityReference = FirestoreEntityReference(photovoltaicPlant),
                       let userEntityReference = FirestoreEntityReference(self.user) {
                        PhotovoltaicPlantView(
                            photovoltaicPlant: photovoltaicPlant,
                            photovoltaicPlantEntityReference: photovoltaicPlantEntityReference,
                            userEntityReference: userEntityReference
                        )
                    } else {
                        self.unavailablePhotovoltaicPlantView
                    }
                case .failure:
                    self.unavailablePhotovoltaicPlantView
                case nil:
                    ProgressView()
                }
            }
            .navigationTitle("Your Solar Power")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let savingsCalculator = SavingsCalculator(firebase: self.firebase) {
                        NavigationLink(destination: savingsCalculator) {
                            Text("Estimate Savings")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
}

// MARK: - Unavailable Photovoltaic Plant View

private extension PhotovoltaicScreen {
    
    /// The unavailable photovoltaic plant view.
    var unavailablePhotovoltaicPlantView: some View {
        EmptyPlaceholder(
            systemImage: "sun.min",
            title: "Photovoltaic",
            subtitle: "This feature is currently not supported in your region."
        )
    }
    
}
