import FirebaseAnalyticsSwift
import SwiftUI

// MARK: - ConsumptionOverview

/// The ConsumptionOverview
struct ConsumptionOverview {
    
    // MARK: Properties
    
    /// The User.
    private let user: User
    
    /// Bool value if CreateConsumptionForm is presented.
    @State
    private var isCreateConsumptionFormPresented: Bool = false
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionOverview`
    /// - Parameter user: The User.
    init(
        user: User
    ) {
        self.user = user
    }
    
}

// MARK: - View

extension ConsumptionOverview: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                SummarySection(
                    consumptionSummary: self.user.consumptionSummary
                )
                if let userId = self.user.id {
                    LatestEntriesSection(
                        userId: .init(userId),
                        isCreateConsumptionFormPresented: self.$isCreateConsumptionFormPresented
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
            isPresented: self.$isCreateConsumptionFormPresented
        ) {
            SheetNavigationView {
                CreateConsumptionForm()
            }
        }
    }
    
}
