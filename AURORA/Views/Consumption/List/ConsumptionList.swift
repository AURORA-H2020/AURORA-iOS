import SwiftUI

// MARK: - ConsumptionList

/// The ConsumptionList
struct ConsumptionList {
    
    // MARK: Properties
    
    /// The search text.
    @State
    private var searchText = String()
    
    /// The currently presented Sheet.
    @State
    private var sheet: Sheet?
    
    /// The Consumptions.
    @FirestoreEntityQuery
    private var consumptions: [Consumption]
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionList`
    /// - Parameter userId: The user identifier
    init(
        userId: User.UID
    ) {
        self._consumptions = .init(
            context: userId,
            predicates: [
                Consumption.orderByCreatedAtPredicate
            ]
        )
    }
    
}

// MARK: - Sheet

private extension ConsumptionList {
    
    /// A Sheet
    enum Sheet: Hashable, Identifiable {
        /// ConsumptionForm
        case consumptionForm(Consumption? = nil)
        
        /// The stable identity of the entity associated with this instance.
        var id: String {
            switch self {
            case .consumptionForm(let consumption):
                return [
                    "ConsumptionForm",
                    consumption?.id
                ]
                .compactMap { $0 }
                .joined(separator: "-")
            }
        }
    }
    
}

// MARK: - View

extension ConsumptionList: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            ForEach(
                self.consumptions.filter(by: self.searchText)
            ) { consumption in
                NavigationLink(
                    destination: ConsumptionView(
                        consumption: consumption
                    )
                ) {
                    Cell(
                        consumption: consumption,
                        editAction: {
                            self.sheet = .consumptionForm(consumption)
                        }
                    )
                }
            }
        }
        .navigationTitle("Entries")
        .searchable(
            text: self.$searchText,
            placement: .navigationBarDrawer(
                displayMode: .always
            )
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.sheet = .consumptionForm()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            item: self.$sheet
        ) { sheet in
            switch sheet {
            case .consumptionForm(let consumption):
                if let consumption = consumption {
                    SheetNavigationView {
                        ConsumptionForm(
                            consumption: consumption
                        )
                    }
                } else {
                    SheetNavigationView {
                        ConsumptionForm()
                    }
                    .adaptivePresentationDetents([.medium, .large])
                }
            }
        }
    }
    
}

// MARK: - [Consumption]+filter(by:)

private extension Array where Element == Consumption {
    
    /// Filters the current instance of consumptions based on the given `searchText`.
    /// - Parameters:
    ///   - searchText: The text to filter by.
    func filter(
        by searchText: String
    ) -> Self {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchText.isEmpty else {
            return self
        }
        return self.filter { consumption in
            consumption.category.rawValue.localizedCaseInsensitiveContains(searchText)
                || consumption.description?.localizedCaseInsensitiveContains(searchText) == true
                || String(consumption.value).localizedCaseInsensitiveContains(searchText)
                || consumption.electricity?.startDate.dateValue().formatted().localizedCaseInsensitiveContains(searchText) == true
                || consumption.electricity?.endDate.dateValue().formatted().localizedCaseInsensitiveContains(searchText) == true
                || consumption.heating?.startDate.dateValue().formatted().localizedCaseInsensitiveContains(searchText) == true
                || consumption.heating?.endDate.dateValue().formatted().localizedCaseInsensitiveContains(searchText) == true
                || consumption.transportation?.dateOfTravel.dateValue().formatted().localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
}
