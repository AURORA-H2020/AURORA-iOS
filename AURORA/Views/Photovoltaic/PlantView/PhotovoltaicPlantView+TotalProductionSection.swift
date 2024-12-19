import SwiftUI

// MARK: - TotalProductionSection

extension PhotovoltaicPlantView {
    
    /// The TotalProductionSection
    struct TotalProductionSection {
        
        /// The photovoltaic plant data.
        let photovoltaicPlantData: [PhotovoltaicPlantDataEntry]
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.TotalProductionSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text(
                    Measurement<UnitPower>(
                        value: self.photovoltaicPlantData.map(\.producedEnergy).reduce(0, +),
                        unit: .kilowatts
                    )
                    .formatted()
                )
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
                if let firstEntry = self.photovoltaicPlantData.first {
                    Text(
                        "Since \(firstEntry.date.dateValue().formatted(date: .numeric, time: .omitted))"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 10)
        } header: {
            Label {
                Text("Production")
            } icon: {
                Image(
                    systemName: "chart.bar.xaxis"
                )
                .foregroundStyle(Color.accentColor)
            }
        }
        .headerProminence(.increased)
    }
    
}
