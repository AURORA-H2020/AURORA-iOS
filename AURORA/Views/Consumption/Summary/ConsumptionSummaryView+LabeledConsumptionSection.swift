import SwiftUI

// MARK: - ConsumptionSummaryView+LabeledConsumptionSection

extension ConsumptionSummaryView {
    
    /// A labeled consumption section
    struct LabeledConsumptionSection {
        
        /// The ConsumptionSummary Mode
        let mode: ConsumptionSummary.Mode
        
        /// The title.
        var category: Consumption.Category?
        
        /// The year.
        let year: Int
        
        /// The labeled consumption.
        let labeledConsumption: ConsumptionSummary.LabeledConsumption
        
    }

}

// MARK: - View

extension ConsumptionSummaryView.LabeledConsumptionSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: HStack {
                if let category = self.category {
                    Text(category.localizedString)
                    Spacer()
                    Text("\(self.labeledConsumption.formatted(using: self.mode)) in \(String(self.year))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                } else {
                    Text("Overall")
                    Spacer()
                    Text(String(self.year))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        ) {
            HStack {
                if let category = self.category {
                    category.icon
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Divider()
                        .overlay(Color.white)
                    Spacer()
                    Text(self.labeledConsumption.localizedLabelDisplayString)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                } else {
                    Spacer()
                    VStack {
                        Text(String(self.year))
                            .font(.title3)
                        if let labelDisplayString = self.labeledConsumption.label?.localizedDisplayString {
                            Text(labelDisplayString)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    Spacer()
                    Divider()
                        .overlay(Color.white)
                    Spacer()
                    Text("\(self.labeledConsumption.formatted(using: self.mode))\nproduced")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .multilineTextAlignment(.center)
            .foregroundColor(self.labeledConsumption.foregroundColor)
            .padding()
            .background(self.labeledConsumption.labelColor)
            .cornerRadius(8)
            .padding(.vertical)
        }
        .listRowBackground(Color(.systemGroupedBackground))
        .listRowInsets(.init())
        .headerProminence(.increased)
    }
    
}
