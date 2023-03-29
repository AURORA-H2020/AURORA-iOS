import SwiftUI

// MARK: - ConsumptionSummaryView+LabledConsumptionSection

extension ConsumptionSummaryView {
    
    /// A labled consumption section
    struct LabledConsumptionSection {
        
        /// The Mode
        let mode: Mode
        
        /// The title.
        var category: Consumption.Category?
        
        /// The year.
        let year: Int
        
        /// The labled consumption.
        let labledConsumption: ConsumptionSummary.LabeledConsumption
        
    }

}

// MARK: - View

extension ConsumptionSummaryView.LabledConsumptionSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: HStack {
                if let category = self.category {
                    Text(category.localizedString)
                    Spacer()
                    if let formattedConsumption = self.mode.format(consumption: self.labledConsumption) {
                        Text("\(formattedConsumption) in \(String(self.year))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
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
                    Group {
                        if let labelDisplayString = self.labledConsumption.label?.localizedDisplayString {
                            Text(labelDisplayString)
                        } else {
                            Text("No consumptions entered (?)")
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    Spacer()
                } else {
                    Spacer()
                    VStack {
                        Text(String(self.year))
                            .font(.title3)
                        if let labelDisplayString = self.labledConsumption.label?.localizedDisplayString {
                            Text(labelDisplayString)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    if let formattedConsumption = self.mode.format(consumption: self.labledConsumption) {
                        Spacer()
                        Divider()
                            .overlay(Color.white)
                        Spacer()
                        Text("\(formattedConsumption)\nproduced")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .multilineTextAlignment(.center)
            .foregroundColor(
                self.labledConsumption.label == .c || self.labledConsumption.label == .d
                    ? .black
                    : .white
            )
            .padding()
            .background(self.labledConsumption.label?.color.flatMap(Color.init) ?? Color.gray)
            .cornerRadius(8)
            .padding(.vertical)
        }
        .listRowBackground(Color(.systemGroupedBackground))
        .listRowInsets(.init())
        .headerProminence(.increased)
    }
    
}
