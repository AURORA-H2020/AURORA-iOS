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
                    header: Text("How does it work?"),
                    footer: Text(
                        "Your energy labels are calculated based on your tracked consumption and specific to your location. This means, as you enter data throughout the year, more of your carbon emission and energy budgets will be made available. For example: If you have only entered data for all days of January and December, 2/12 of the total budget will be used to calculate your label. The only exception is transportation, which yields the full budget after a certain number of annual entries. Your overall budget is based on the sum of your electricity, heating and transportation budgets."
                    )
                    .multilineTextAlignment(.leading)
                ) {
                }
                .headerProminence(.increased)
                .listRowInsets(.init())
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
