import SwiftUI

// MARK: - ConsumptionSummaryView

/// The ConsumptionSummaryView
struct ConsumptionSummaryView {
    
    // MARK: Properties
    
    /// The model
    @State
    private var mode: Mode = .carbonEmission
    
    /// The selected consumption summary identifier.
    @State
    private var selection: ConsumptionSummary.ID = nil
    
    /// The Consumptions.
    @FirestoreEntityQuery
    private var consumptionSummaries: [ConsumptionSummary]
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionSummaryView`
    /// - Parameter userId: The user identifier.
    init(
        userId: User.UID
    ) {
        self._consumptionSummaries = .init(
            context: userId,
            predicates: [
                ConsumptionSummary.orderByYearPredicate
            ]
        )
    }
    
}

// MARK: - Mode

private extension ConsumptionSummaryView {
    
    /// A ConsumptionSummaryView mode.
    enum Mode: String, Hashable, CaseIterable {
        /// Carbon emissions.
        case carbonEmission
        /// Energy expenditure.
        case energyExpended
    }
    
}

// MARK: - Mode+localizedString

private extension ConsumptionSummaryView.Mode {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .carbonEmission:
            return .init(localized: "Carbon emissions")
        case .energyExpended:
            return .init(localized: "Energy expenditure")
        }
    }
    
}

// MARK: - View

extension ConsumptionSummaryView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                Picker(
                    "Year",
                    selection: self.$selection
                ) {
                    ForEach(self.consumptionSummaries) { consumptionSummary in
                        Text(String(consumptionSummary.year))
                            .tag(consumptionSummary.id)
                    }
                }
                .pickerStyle(.menu)
                HStack {
                    Text("Type")
                    Spacer()
                    Picker(
                        "",
                        selection: self.$mode.animation()
                    ) {
                        ForEach(
                            Mode.allCases,
                            id: \.self
                        ) { mode in
                            Text(mode.localizedString)
                                .tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            if let consumptionSummary = self.consumptionSummaries.first(where: { $0.id == self.selection }) {
                LabledConsumptionSection(
                    title: "Overall",
                    labledConsumption: {
                        switch self.mode {
                        case .carbonEmission:
                            return consumptionSummary.carbonEmission
                        case .energyExpended:
                            return consumptionSummary.energyExpended
                        }
                    }()
                )
                ForEach(
                    Consumption.Category.allCases,
                    id: \.self
                ) { category in
                    if let consumptionSummaryCategory = consumptionSummary.category(category) {
                        LabledConsumptionSection(
                            title: .init(stringLiteral: category.localizedString),
                            labledConsumption: {
                                switch self.mode {
                                case .carbonEmission:
                                    return consumptionSummaryCategory.carbonEmission
                                case .energyExpended:
                                    return consumptionSummaryCategory.energyExpended
                                }
                            }()
                        )
                    }
                }
                Section(
                    // swiftlint:disable:next line_length
                    footer: Text("Your energy labels are calculated based on your tracked consumption. Your carbon emission budget is calculated for the full calendar year, meaning at the end of January you will only have one twelfth of your budget available. As the year goes on your budget is recalculated accordingly on a daily basis")
                ) {
                }
            }
        }
        .navigationTitle("Energy Labels")
        .animation(.default, value: self.selection)
        .onChange(
            of: self.consumptionSummaries
        ) { consumptionSummaries in
            guard self.selection == nil else {
                return
            }
            self.selection = consumptionSummaries.first?.id
        }
    }
    
}

// MARK: - LabledConsumptionSection

private extension ConsumptionSummaryView {
    
    /// A labled consumption section
    struct LabledConsumptionSection: View {
        
        // MARK: Properties
        
        /// The title.
        let title: LocalizedStringKey
        
        /// The labled consumption.
        let labledConsumption: ConsumptionSummary.LabeledConsumption
        
        /// The content and behavior of the view.
        var body: some View {
            Section(
                header: HStack {
                    Text(self.title)
                    Spacer()
                    if self.labledConsumption.label != nil,
                       let carbonEmissions = self.labledConsumption.total.formatted(.carbonEmissions) {
                        Text("\(carbonEmissions) CO₂")
                            .font(.headline)
                    }
                }
            ) {
                EnergyLabel(
                    label: self.labledConsumption.label
                )
            }
            .listRowBackground(Color(.systemGroupedBackground))
            .headerProminence(.increased)
        }
        
    }

}
