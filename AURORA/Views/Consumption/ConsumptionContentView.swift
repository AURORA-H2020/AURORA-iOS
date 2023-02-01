import FirebaseAnalyticsSwift
import SwiftUI

// MARK: - ConsumptionContentView

/// The ConsumptionContentView
struct ConsumptionContentView {
    
    // MARK: Properties
    
    /// The User.
    private let user: User
    
    /// Bool value if AddConsumptionForm is presented
    @State
    private var isAddConsumptionFormPresented = false
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionContentView`
    /// - Parameter user: The User.
    init(
        user: User
    ) {
        self.user = user
    }
    
}

// MARK: - View

extension ConsumptionContentView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                ConsumptionSummarySection(
                    consumptionSummary: self.user.consumptionSummary
                )
                if let userId = self.user.id {
                    ConsumptionsSection(
                        userId: userId,
                        isAddConsumptionFormPresented: self.$isAddConsumptionFormPresented
                    )
                }
            }
            .navigationTitle("Dashboard")
        }
        .navigationViewStyle(.stack)
        .analyticsScreen(
            name: "Dashboard",
            class: "ConsumptionContentView"
        )
        .sheet(
            isPresented: self.$isAddConsumptionFormPresented
        ) {
            SheetNavigationView {
                AddConsumptionForm()
            }
        }
    }
    
}
