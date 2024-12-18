import SwiftUI

// MARK: - PhotovoltaicPlantScreen

/// The PhotovoltaicPlantScreen
struct PhotovoltaicPlantScreen {
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension PhotovoltaicPlantScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            Group {
                let unavailablePhotovoltaicPlantView = EmptyPlaceholder(
                    systemImage: "sun.min",
                    title: "Photovoltaic",
                    subtitle: "This feature is currently not supported in your region."
                )
                switch self.firebase.photovoltaicPlant {
                case .success(let photovoltaicPlant):
                    if let photovoltaicPlant,
                       photovoltaicPlant.active,
                       let photovoltaicPlantEntityReference = FirestoreEntityReference(photovoltaicPlant) {
                        PhotovoltaicPlantView(
                            photovoltaicPlant: photovoltaicPlant,
                            photovoltaicPlantEntityReference: photovoltaicPlantEntityReference
                        )
                    } else {
                        unavailablePhotovoltaicPlantView
                    }
                case .failure:
                    unavailablePhotovoltaicPlantView
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
