import FirebaseAnalyticsSwift
import SwiftUI

// MARK: - ConsumptionScreen

/// The ConsumptionScreen
struct ConsumptionScreen {
    
    // MARK: Properties
    
    /// The User.
    private let user: User
    
    /// The currently presented sheet.
    @State
    private var sheet: Sheet?
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionOverview`
    /// - Parameter user: The User.
    init(
        user: User
    ) {
        self.user = user
    }
    
}

// MARK: - Sheet

extension ConsumptionScreen {
    
    /// A consumption screen sheet.
    enum Sheet: Hashable, Identifiable {
        /// ConsumptionSummary
        case consumptionSummary(ConsumptionSummary.Mode = .carbonEmission)
        /// ConsumptionForm
        case consumptionForm(Consumption? = nil)
        
        /// The stable identity of the entity associated with this instance.
        var id: String {
            switch self {
            case .consumptionSummary(let mode):
                return mode.rawValue
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

extension ConsumptionScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                if let userId = self.user.id {
                    OverviewSection(
                        userId: .init(userId),
                        sheet: self.$sheet
                    )
                    LatestEntriesSection(
                        userId: .init(userId),
                        sheet: self.$sheet
                    )
                }
            }
            .navigationTitle("Your carbon footprint")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .analyticsScreen(
            name: "Your carbon footprint",
            class: "ConsumptionOverview"
        )
        .sheet(
            item: self.$sheet
        ) { sheet in
            switch sheet {
            case .consumptionSummary(let mode):
                if let userId = self.user.id {
                    SheetNavigationView {
                        ConsumptionSummaryView(
                            userId: .init(userId),
                            mode: mode
                        )
                    }
                }
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
