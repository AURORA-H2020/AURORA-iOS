import FirebaseAnalyticsSwift
import SwiftUI

// MARK: - ConsumptionScreen

/// The ConsumptionScreen
struct ConsumptionScreen {
    
    // MARK: Properties
    
    /// The User.
    private let user: User
    
    /// Bool value if ConsumptionSummaryView is presented.
    @State
    private var isConsumptionSummaryViewPresented: Bool = false
    
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

extension ConsumptionScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                if let userId = self.user.id {
                    SummarySection(
                        userId: .init(userId),
                        isConsumptionSummaryViewPresented: self.$isConsumptionSummaryViewPresented
                    )
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
            .adaptivePresentationDetents([.medium, .large])
        }
        .sheet(
            isPresented: self.$isConsumptionSummaryViewPresented
        ) {
            if let userId = self.user.id {
                SheetNavigationView {
                    ConsumptionSummaryView(
                        userId: .init(userId)
                    )
                }
            }
        }
    }
    
}