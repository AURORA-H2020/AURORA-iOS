import SwiftUI

// MARK: - RecurringConsumptionList

/// The RecurringConsumptionList
struct RecurringConsumptionList {
    
    // MARK: Properties
    
    /// Bool value if RecurringConsumptionForm is presented
    @State
    private var isRecurringConsumptionFormPresented = false
    
    /// The recurring consumptions.
    @FirestoreEntityQuery
    private var recurringConsumptions: [RecurringConsumption]
    
    // MARK: Initializer
    
    /// Creates a new instance of `RecurringConsumptionList`
    /// - Parameters:
    ///   - userId: The user identifier.
    init(
        userId: User.UID
    ) {
        self._recurringConsumptions = .init(
            context: userId,
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
                        self.isRecurringConsumptionFormPresented = true
                    }
                )
            } else {
                List {
                    ForEach(self.recurringConsumptions) { recurringConsumption in
                        NavigationLink(
                            destination: RecurringConsumptionForm(
                                recurringConsumption: recurringConsumption
                            )
                        ) {
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
                    self.isRecurringConsumptionFormPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: self.$isRecurringConsumptionFormPresented) {
            SheetNavigationView {
                RecurringConsumptionForm()
            }
        }
    }
    
}
