import SwiftUI

// MARK: - PhotovoltaicPlantView+ChartSection

extension PhotovoltaicPlantView {
    
    /// The ChartSection
    struct ChartSection {
        
        /// The mode.
        @Binding
        var mode: PhotovoltaicPlantView.Mode
        
        /// The photovoltaic plant data.
        let photovoltaicPlantData: [PhotovoltaicPlantDataEntry]
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.ChartSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
            VStack(spacing: 18) {
                Picker(String(), selection: self.$mode) {
                    ForEach(
                        PhotovoltaicPlantView.Mode.allCases
                    ) { mode in
                        Text(mode.localizedString)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .listRowBackground(Color(.systemGroupedBackground))
        .listRowInsets(.init())
    }
    
}
