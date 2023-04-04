import SwiftUI

// MARK: - ConsumptionSummaryView

/// The ConsumptionSummaryView
struct ConsumptionSummaryView {
    
    // MARK: Properties
    
    /// The mode.
    @State
    private var mode: ConsumptionSummary.Mode
    
    /// The selected consumption summary identifier.
    @State
    private var selection: ConsumptionSummary.ID = nil
    
    /// The Consumptions.
    @FirestoreEntityQuery
    private var consumptionSummaries: [ConsumptionSummary]
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionSummaryView`
    /// - Parameters:
    ///   - userId: The user identifier.
    ///   - mode: The mode. Default value `.carbonEmission`
    init(
        userId: User.UID,
        mode: ConsumptionSummary.Mode = .carbonEmission
    ) {
        self._mode = .init(initialValue: mode)
        self._consumptionSummaries = .init(
            context: userId,
            predicates: [
                ConsumptionSummary.orderByYearPredicate
            ]
        )
    }
    
}

// MARK: - Localized Navigation Title

extension ConsumptionSummaryView {
    
    /// A localized navigation title.
    var localizedNavigationTitle: String {
        switch self.mode {
        case .carbonEmission:
            return .init(localized: "Your Carbon Emissions Labels")
        case .energyExpended:
            return .init(localized: "Your Energy Labels")
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
                Picker(
                    "",
                    selection: self.$mode
                ) {
                    ForEach(
                        ConsumptionSummary.Mode.allCases,
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
                LabeledConsumptionSection(
                    mode: self.mode,
                    year: consumptionSummary.year,
                    labeledConsumption: consumptionSummary.labeledConsumption(for: self.mode)
                )
                ForEach(
                    Consumption.Category.allCases,
                    id: \.self
                ) { category in
                    if let consumptionSummaryCategory = consumptionSummary.category(category) {
                        LabeledConsumptionSection(
                            mode: self.mode,
                            category: category,
                            year: consumptionSummary.year,
                            labeledConsumption: consumptionSummaryCategory.labeledConsumption(for: self.mode)
                        )
                    }
                }
                Section(
                    footer: Text(
                        "Your energy labels are calculated based on your tracked consumption. Your carbon emission budget is calculated for the full calendar year, meaning at the end of January you will only have one twelfth of your budget available. As the year goes on your budget is recalculated accordingly on a daily basis"
                    )
                ) {
                }
            } else {
                Section {
                    EmptyPlaceholder(
                        systemImage: "chart.bar.xaxis",
                        title: .init(self.localizedNavigationTitle),
                        subtitle: "Your energy lables are currently not available."
                    )
                }
                .listRowBackground(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle(self.localizedNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
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
