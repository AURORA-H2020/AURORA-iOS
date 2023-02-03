import SwiftUI

// MARK: - ConsumptionList

/// The ConsumptionList
struct ConsumptionList {
    
    // MARK: Properties
    
    /// Bool value if CreateConsumptionForm is presented.
    @State
    private var isCreateConsumptionFormPresented: Bool = false
    
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

// MARK: - View

extension ConsumptionList: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            ForEach(
                self.consumptions,
                content: Cell.init
            )
        }
        .navigationTitle("Entries")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isCreateConsumptionFormPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            isPresented: self.$isCreateConsumptionFormPresented
        ) {
            SheetNavigationView {
                CreateConsumptionForm()
            }
        }
    }
    
}
