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
            .listRowInsets(.init())
            .listRowBackground(Color(.systemGroupedBackground))
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
            }
            if let consumptionSummary = self.consumptionSummaries.first(where: { $0.id == self.selection }) {
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

// MARK: - LabledConsumptionSection

private extension ConsumptionSummaryView {
    
    /// A labled consumption section
    struct LabledConsumptionSection: View {
        
        // MARK: Properties
        
        /// The Mode
        let mode: Mode
        
        /// The title.
        var category: Consumption.Category?
        
        /// The year.
        let year: Int
        
        /// The labled consumption.
        let labledConsumption: ConsumptionSummary.LabeledConsumption
        
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
                        }
                    } else {
                        Text("Overall")
                        Spacer()
                        Text(String(self.year))
                            .font(.subheadline)
                            .fontWeight(.semibold)
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
                .padding(.top, 5)
            }
            .listRowBackground(Color(.systemGroupedBackground))
            .listRowInsets(.init())
            .headerProminence(.increased)
        }
        
    }

}
