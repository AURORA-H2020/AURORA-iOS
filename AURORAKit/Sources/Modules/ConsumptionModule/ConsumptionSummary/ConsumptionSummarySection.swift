import FirebaseKit
import ModuleKit
import PieChartKit
import SwiftUI

// MARK: - ConsumptionSummarySection

/// The ConsumptionSummarySection
struct ConsumptionSummarySection {
    
    /// The optional ConsumptionSummary
    let consumptionSummary: User.ConsumptionSummary?
    
    /// The color scheme
    @Environment(\.colorScheme)
    private var colorScheme
    
}

// MARK: - View

extension ConsumptionSummarySection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: Text(
                verbatim: "Your carbon footprint"
            )
        ) {
            if let consumptionSummary = self.consumptionSummary {
                self.content(
                    consumptionSummary: consumptionSummary
                )
                .padding(.vertical)
            } else {
                Text(
                    verbatim: "Your carbon footprint is currently not available."
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .align(.centerHorizontal)
                .padding(.vertical)
            }
        }
        .listRowBackground(Color(.systemGroupedBackground))
        .listRowInsets(.init())
        .headerProminence(.increased)
    }
    
}

private extension ConsumptionSummarySection {
    
    // swiftlint:disable:next function_body_length
    func content(
        consumptionSummary: User.ConsumptionSummary
    ) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                VStack {
                    VStack {
                        Text(
                            verbatim: "\(consumptionSummary.totalCarbonEmissions) tons"
                        )
                        .font(.title3.weight(.bold))
                        .foregroundColor(.accentColor)
                        Text(
                            verbatim: "CO₂ emissions"
                        )
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
                    ForEach(consumptionSummary.entries) { entry in
                        Label {
                            Text(verbatim: entry.category)
                                .font(.headline)
                                .foregroundColor(.primary)
                                + Text(verbatim: " ")
                                + Text(verbatim: "(\(Int(entry.value * 100))%)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(
                                systemName: "square.fill"
                            )
                            .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            Spacer()
            PieChart(
                consumptionSummary
                    .entries
                    .map { entry in
                        .init(
                            id: entry,
                            value: entry.value,
                            color: .accentColor
                        )
                    },
                spacing: 4
            )
            .frame(height: 160)
        }
    }
    
}
