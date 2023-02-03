import SwiftUI

// MARK: - ConsumptionList

/// The ConsumptionList
struct ConsumptionList {
    
    // MARK: Properties
    
    /// Bool value if AddConsumptionForm is presented
    @State
    private var isAddConsumptionFormPresented = false
    
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
                content: ConsumptionCell.init
            )
        }
        .navigationTitle("Entries")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isAddConsumptionFormPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            isPresented: self.$isAddConsumptionFormPresented
        ) {
            SheetNavigationView {
                AddConsumptionForm()
            }
        }
    }
    
}
