import SwiftUI

// MARK: - ConsumptionOverview+SummarySection

extension ConsumptionOverview {
    
    /// The ConsumptionOverview SummarySection
    struct SummarySection {
        
        /// The optional ConsumptionSummary
        let consumptionSummary: ConsumptionSummary?
        
        /// The color scheme
        @Environment(\.colorScheme)
        private var colorScheme
        
    }
    
}

// MARK: - View

extension ConsumptionOverview.SummarySection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
            Group {
                if let consumptionSummary = self.consumptionSummary {
                    self.content(
                        consumptionSummary: consumptionSummary
                    )
                } else {
                    self.content(
                        consumptionSummary: .placeholder
                    )
                    .redacted(reason: .placeholder)
                    .opacity(0.7)
                }
            }
            .padding(.vertical)
        }
        .listRowBackground(Color(.systemGroupedBackground))
        .listRowInsets(.init())
        .headerProminence(.increased)
    }
    
}

private extension ConsumptionOverview.SummarySection {
    
    // swiftlint:disable:next function_body_length
    func content(
        consumptionSummary: ConsumptionSummary
    ) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                VStack {
                    VStack {
                        Text(consumptionSummary.formattedTotalCarbonEmissions)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.accentColor)
                        Text("CO₂ emissions")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                }
                .background(
                    Color(
                        self.colorScheme == .dark
                            ? .secondarySystemGroupedBackground
                            : .systemBackground
                    )
                )
                .cornerRadius(12)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(
                        consumptionSummary
                            .entries
                            .sorted { $0.value > $1.value }
                            .filter { !$0.value.isNaN }
                    ) { entry in
                        HStack {
                            Image(
                                systemName: "square.fill"
                            )
                            .foregroundColor(entry.category.tintColor)
                            VStack(alignment: .leading) {
                                Text(entry.category.rawValue.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(entry.formattedValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            Spacer()
            PieChart(
                consumptionSummary
                    .entries
                    .compactMap { entry -> PieChart<ConsumptionSummary.Entry>.Slice? in
                        guard !entry.value.isNaN else {
                            return nil
                        }
                        return .init(
                            id: entry,
                            value: entry.value,
                            color: entry.category.tintColor
                        )
                    },
                spacing: .init(
                    width: 4,
                    color: .init(.systemGroupedBackground)
                )
            )
            .frame(height: 160)
        }
    }
    
}

// MARK: - ConsumptionSummary+placeholder

private extension ConsumptionSummary {
    
    /// A placeholder ConsumptionSummary
    static let placeholder = Self(
        totalCarbonEmissions: 0.79,
        entries: [
            .init(
                category: .electricity,
                value: 0.29
            ),
            .init(
                category: .transportation,
                value: 0.27
            ),
            .init(
                category: .heating,
                value: 0.44
            )
        ]
    )
    
}
