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
                if let user = FirestoreEntityReference(self.user) {
                    OverviewSection(
                        user: user,
                        sheet: self.$sheet
                    )
                    LatestEntriesSection(
                        user: user,
                        sheet: self.$sheet
                    )
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .analyticsScreen(
            name: "Dashboard",
            class: "ConsumptionOverview"
        )
        .sheet(
            item: self.$sheet
        ) { sheet in
            switch sheet {
            case .consumptionSummary(let mode):
                if let user = FirestoreEntityReference(self.user) {
                    SheetNavigationView {
                        ConsumptionSummaryView(
                            user: user,
                            mode: mode
                        )
                    }
                }
            case .consumptionForm(let consumption):
                SheetNavigationView {
                    ConsumptionForm(
                        mode: consumption.flatMap(ConsumptionForm.Mode.edit) ?? .create()
                    )
                }
            }
        }
    }
    
}
