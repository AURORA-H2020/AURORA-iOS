import FirebaseAnalytics
import SwiftUI

// MARK: - ConsumptionScreen

/// The ConsumptionScreen
struct ConsumptionScreen {
    
    // MARK: Properties
    
    /// The User.
    private let user: User
    
    /// The RecurringConsumptionsReminderService
    private let recurringConsumptionsReminderService: RecurringConsumptionsReminderService = .shared
    
    /// Bool if recurring consumptions reminder alert is presented
    @State
    private var isRecurringConsumptionsReminderAlertPresented = false
    
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
        /// RecurringConsumptionList
        case recurringConsumptionList
        
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
            case .recurringConsumptionList:
                return "RecurringConsumptionList"
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
            case .recurringConsumptionList:
                if let user = FirestoreEntityReference(self.user) {
                    SheetNavigationView {
                        RecurringConsumptionList(
                            user: user
                        )
                    }
                }
            }
        }
        .alert(
            "Update recurring consumptions?",
            isPresented: self.$isRecurringConsumptionsReminderAlertPresented,
            actions: {
                Button("Yes") {
                    self.sheet = .recurringConsumptionList
                }
                Button("No") {}
                Button(
                    "Don't ask me again",
                    role: .cancel
                ) {
                    self.recurringConsumptionsReminderService.isEnabled = false
                }
            },
            message: {
                Text("Has your regular energy behaviour changed?")
            }
        )
        .onAppear {
            if !ProcessInfo.processInfo.isRunningUITests
                && self.recurringConsumptionsReminderService.shouldShowReminder {
                self.isRecurringConsumptionsReminderAlertPresented = true
            }
        }
    }
    
}
