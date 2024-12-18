import SwiftUI

// MARK: - PhotovoltaicPlantView+HelpSection

extension PhotovoltaicPlantView {
    
    /// The HelpSection.
    struct HelpSection {
        
        /// The PhotovoltaicPlant
        let photovoltaicPlant: PhotovoltaicPlant
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.HelpSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
        } header: {
            Text("How does it work?")
        } footer: {
            VStack(spacing: 24) {
                Text("""
                Your investment in your local AURORA solar power installations helps reduce your
                carbon footprint. Here you can see a breakdown of the total energy produced by the
                installation (Total Production) and your investment's contribution (Your Production). Your
                contribution is automatically added as an offset to your profile each Friday morning to help
                you reach near-zero emissions.
                """)
                .multilineTextAlignment(.leading)
                if let photovoltaicPlantDataURL = AURORAWebAppLink.photovoltaicPlantData(for: self.photovoltaicPlant)?.url {
                    Link(destination: photovoltaicPlantDataURL) {
                        Text(
                            "See full data"
                        )
                        .font(.headline)
                        .align(.centerHorizontal)
                        .padding(.vertical, 5)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .headerProminence(.increased)
    }
    
}
