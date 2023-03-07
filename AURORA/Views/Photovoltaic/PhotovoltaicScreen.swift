import SwiftUI

// MARK: - PhotovoltaicScreen

/// The PhotovoltaicScreen.
struct PhotovoltaicScreen {
    
    /// The Country.
    let country: Country
    
    /// The City.
    let city: City
    
    /// The PVGIS parameters of the city.
    let pvgisParams: City.PVGISParams
    
    /// The PVGISService
    private let pvgisService = PVGISService()
    
}

// MARK: - View

extension PhotovoltaicScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                AsyncButton {
                    try await self.pvgisService.calculcatePhotovoltaicInvestment(
                        amount: 900,
                        using: self.pvgisParams,
                        in: self.country
                    )
                } label: {
                    Text("Test")
                }
            }
            .navigationTitle("Photovoltaics")
        }
    }
    
}
