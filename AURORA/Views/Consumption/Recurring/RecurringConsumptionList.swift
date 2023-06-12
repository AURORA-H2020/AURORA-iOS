import SwiftUI

// MARK: - RecurringConsumptionList

/// The RecurringConsumptionList
struct RecurringConsumptionList {
    
    // MARK: Properties
    
    /// The presented recurring consumption form mode.
    @State
    private var presentedRecurringConsumptionFormMode: RecurringConsumptionForm.Mode?
    
    /// The recurring consumptions.
    @FirestoreEntityQuery
    private var recurringConsumptions: [RecurringConsumption]
    
    // MARK: Initializer
    
    /// Creates a new instance of `RecurringConsumptionList`
    /// - Parameters:
    ///   - user: The user reference.
    init(
        user: FirestoreEntityReference<User>
    ) {
        self._recurringConsumptions = .init(
            context: user,
            predicates: [
                RecurringConsumption.orderByCreatedAtPredicate
            ]
        )
    }
    
}

// MARK: - View

extension RecurringConsumptionList: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Group {
            if self.recurringConsumptions.isEmpty {
                EmptyPlaceholder(
                    systemImage: "arrow.clockwise.circle.fill",
                    systemImageColor: .secondary.opacity(0.5),
                    title: "Recurring consumptions",
                    subtitle: "Here you can add regularly repeating consumptions, such as your commute.\nRecurring consumptions automatically add consumptions for you based on a custom interval.",
                    primaryAction: .init(
                        title: "Add"
                    ) {
                        self.presentedRecurringConsumptionFormMode = .create
                    }
                )
            } else {
                List {
                    ForEach(self.recurringConsumptions) { recurringConsumption in
                        Button {
                            self.presentedRecurringConsumptionFormMode = .edit(recurringConsumption)
                        } label: {
                            Cell(
                                recurringConsumption: recurringConsumption
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Recurring consumptions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.presentedRecurringConsumptionFormMode = .create
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            item: self.$presentedRecurringConsumptionFormMode
        ) { mode in
            NavigationView {
                RecurringConsumptionForm(mode: mode)
            }
        }
    }
    
}
