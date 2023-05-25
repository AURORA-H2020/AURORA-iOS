import SwiftUI

// MARK: - OverviewSection

extension ConsumptionScreen {
    
    /// The OverviewSection
    struct OverviewSection {
        
        // MARK: Properties
        
        /// The currently presented sheet.
        @Binding
        private var sheet: ConsumptionScreen.Sheet?
        
        /// The Consumptions.
        @FirestoreEntityQuery
        private var consumptionSummaries: [ConsumptionSummary]
        
        // MARK: Initializer
        
        /// Creates a new instance of `ConsumptionScreen.OverviewSection`
        /// - Parameters:
        ///   - userId: The user identifier.
        ///   - sheet: The currently presented sheet.
        init(
            userId: User.UID,
            sheet: Binding<ConsumptionScreen.Sheet?>
        ) {
            self._sheet = sheet
            self._consumptionSummaries = .init(
                context: userId,
                predicates: [
                    ConsumptionSummary.orderByYearPredicate,
                    .limitTo(1)
                ]
            )
        }
        
    }
    
}

// MARK: - View

extension ConsumptionScreen.OverviewSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(
                            "Your performance"
                        )
                        .fontWeight(.semibold)
                    }
                    Spacer()
                    Image("AURORA-Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                }
                .padding([.top, .horizontal])
                if let consumptionSummary = self.consumptionSummaries.first {
                    HStack {
                        ForEach(ConsumptionSummary.Mode.allCases, id: \.self) { mode in
                            self.labeledConsumptionButton(
                                mode: mode,
                                consumption: consumptionSummary.labeledConsumption(for: mode)
                            ) {
                                self.sheet = .consumptionSummary(mode)
                            }
                        }
                    }
                }
            }
            .listRowInsets(.init())
            .padding(.bottom)
        ) {
            Button {
                self.sheet = .consumptionSummary()
            } label: {
                Label(
                    "View your energy labels",
                    systemImage: "chart.bar.xaxis"
                )
            }
            Button {
                self.sheet = .consumptionForm()
            } label: {
                Label(
                    "Add a consumption",
                    systemImage: "plus.circle.fill"
                )
            }
            Link(
                destination: .init(
                    string: "https://www.aurora-h2020.eu"
                )!
            ) {
                Label(
                    "Learn more",
                    systemImage: "questionmark.circle.fill"
                )
            }
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Labeled Consumption

private extension ConsumptionScreen.OverviewSection {
    
    /// Labeled Consumption Button
    /// - Parameters:
    ///   - mode: The mode.
    ///   - consumption: The labeled consumption.
    ///   - action: The action.
    func labeledConsumptionButton(
        mode: ConsumptionSummary.Mode,
        consumption: ConsumptionSummary.LabeledConsumption,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            VStack {
                if let localizedLabeledDisplayString = consumption.label?.localizedDisplayString {
                    Text(localizedLabeledDisplayString)
                        .font(.footnote)
                        .fontWeight(.semibold)
                } else {
                    Text("No consumption entered yet (?)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                Text(mode.localizedString)
                    .font(.caption2)
                Text(consumption.formatted(using: mode))
                    .font(.caption2)
            }
            .foregroundColor(consumption.foregroundColor)
            .align(.centerHorizontal)
            .frame(minHeight: 55)
        }
        .buttonStyle(.borderedProminent)
        .tint(consumption.labelColor)
    }
    
}
