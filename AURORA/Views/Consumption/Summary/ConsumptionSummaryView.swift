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
                Picker(
                    "",
                    selection: self.$mode
                ) {
                    ForEach(
                        Mode.allCases,
                        id: \.self
                    ) { mode in
                        Text(mode.localizedString)
                            .tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            if let consumptionSummary = self.consumptionSummaries.first(where: { $0.id == self.selection }) {
                Section {
                    Chart(
                        consumptionSummary: consumptionSummary,
                        mode: self.mode
                    )
                    .padding(.bottom)
                }
                .listRowInsets(.init())
                .listRowBackground(Color(.systemGroupedBackground))
                LabledConsumptionSection(
                    mode: self.mode,
                    year: consumptionSummary.year,
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
                            mode: self.mode,
                            category: category,
                            year: consumptionSummary.year,
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
                    footer: Text(
                        "Your energy labels are calculated based on your tracked consumption. Your carbon emission budget is calculated for the full calendar year, meaning at the end of January you will only have one twelfth of your budget available. As the year goes on your budget is recalculated accordingly on a daily basis"
                    )
                ) {
                }
            }
        }
        .navigationTitle(self.mode.localizedNavigationTitle)
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
