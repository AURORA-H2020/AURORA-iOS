import FirebaseKit
import SwiftUI

// MARK: - ConsumptionsSection

/// The ConsumptionsSection
struct ConsumptionsSection {
    
    // MARK: Properties
    
    /// The Consumptions.
    @FirestoreQuery
    private var consumptions: [Consumption]
    
    /// Bool value if AddConsumptionForm is presented.
    @Binding
    private var isAddConsumptionFormPresented: Bool
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionsSection`
    /// - Parameters:
    ///   - userId: The user identifier.
    ///   - isAddConsumptionFormPresented: Bool Binding value if AddConsumptionForm is presented.
    public init(
        userId: String,
        isAddConsumptionFormPresented: Binding<Bool>
    ) {
        self._consumptions = .init(
            collectionPath: Consumption
                .collectionReference(userId)
                .path,
            predicates: [
                .order(by: "createdAt")
            ]
        )
        self._isAddConsumptionFormPresented = isAddConsumptionFormPresented
    }
    
}

// MARK: - View

extension ConsumptionsSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: HStack {
                Text(
                    verbatim: "Latest entries"
                )
                Spacer()
                Button {
                    self.isAddConsumptionFormPresented = true
                } label: {
                    Label(
                        "Add entry",
                        systemImage: "plus"
                    )
                    .font(.headline)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.accentColor)
            }
        ) {
            ForEach(self.consumptions) { consumption in
                Cell(
                    consumption: consumption
                )
            }
        }
        .headerProminence(.increased)
    }
    
}
