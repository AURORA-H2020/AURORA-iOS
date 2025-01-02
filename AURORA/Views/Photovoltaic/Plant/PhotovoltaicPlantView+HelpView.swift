import SwiftUI

// MARK: - PhotovoltaicPlantView+HelpView

extension PhotovoltaicPlantView {
    
    /// The HelpSection.
    struct HelpView {
        
        /// The PhotovoltaicPlant
        let photovoltaicPlant: PhotovoltaicPlant
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.HelpView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        ScrollView {
            Text("""
            Your investment in your local AURORA solar power installations helps reduce your
            carbon footprint. Here you can see a breakdown of the total energy produced by the
            installation (Total Production) and your investment's contribution (Your Production). Your
            contribution is automatically added as an offset to your profile each Friday morning to help
            you reach near-zero emissions.
            """)
            .multilineTextAlignment(.leading)
            .padding()
        }
        .navigationTitle("How does it work?")
        .toolbar {
            if let photovoltaicPlantDataURL = AURORAWebAppLink.photovoltaicPlantData(for: self.photovoltaicPlant)?.url {
                Button(
                    destination: photovoltaicPlantDataURL
                ) {
                    Text("See full data")
                }
            }
        }
    }
    
}
