import FirebaseKit
import SwiftUI

// MARK: - ConsumptionsSection+Cell

extension ConsumptionsSection {
    
    /// The ConsumptionsSection Cell
    struct Cell {
        
        /// The Consumption
        let consumption: Consumption
        
    }
    
}

// MARK: - View

extension ConsumptionsSection.Cell: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(
                    verbatim: self.consumption.category.rawValue.capitalized
                )
                .foregroundColor(.primary)
                if let createdAt = self.consumption.createdAt?.dateValue() {
                    Text(
                        verbatim: createdAt.formatted(date: .numeric, time: .shortened)
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
            VStack(alignment: .trailing) {
                Text(
                    verbatim: self.consumption.formattedValue
                )
                .foregroundColor(.secondary)
                if let carbonEmissions = self.consumption.carbonEmissions {
                    Text(
                        verbatim: "≈ \(carbonEmissions.formatted()) t"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .multilineTextAlignment(.trailing)
        }
    }
    
}
