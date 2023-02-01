import SwiftUI

// MARK: - ConsumptionsSection

/// The ConsumptionsSection
struct ConsumptionsSection {
    
    // MARK: Properties
    
    /// The user identifier
    private let userId: String
    
    /// The Consumptions.
    @FirestoreEntityQuery
    private var consumptions: [Consumption]
    
    /// Bool value if AddConsumptionForm is presented.
    @Binding
    private var isAddConsumptionFormPresented: Bool
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionsSection`
    /// - Parameters:
    ///   - userId: The user identifier.
    ///   - isAddConsumptionFormPresented: Bool Binding value if AddConsumptionForm is presented.
    init(
        userId: String,
        isAddConsumptionFormPresented: Binding<Bool>
    ) {
        self.userId = userId
        self._consumptions = .init(
            context: .init(userId),
            predicates: [
                Consumption.orderByCreatedAtPredicate,
                .limit(to: 3)
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
                Text("Latest entries")
                Spacer()
                if !self.consumptions.isEmpty {
                    Button {
                        self.isAddConsumptionFormPresented = true
                    } label: {
                        Label(
                            "Add entry",
                            systemImage: "plus"
                        )
                        .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.accentColor)
                }
            },
            footer: Group {
                if self.consumptions.isEmpty {
                    EmptyPlaceholder(
                        systemImage: "plus.circle.fill",
                        title: "Consumptions",
                        subtitle: "Add your first consumption entry.",
                        primaryAction: .init(
                            title: "Add consumption",
                            action: {
                                self.isAddConsumptionFormPresented = true
                            }
                        )
                    )
                    .padding(.vertical)
                }
            }
        ) {
            ForEach(self.consumptions) { consumption in
                Cell(
                    consumption: consumption
                )
            }
            .onDelete { offsets in
                self.firebase
                    .firestore
                    .delete(
                        offsets.compactMap { self.consumptions[safe: $0] },
                        context: .init(self.userId)
                    )
            }
        }
        .headerProminence(.increased)
        .animation(
            .default,
            value: self.consumptions
        )
    }
    
}
