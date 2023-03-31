import SwiftUI

// MARK: - ConsumptionScreen+LatestEntriesSection

extension ConsumptionScreen {
    
    /// The ConsumptionScreen LatestEntriesSection
    struct LatestEntriesSection {
        
        // MARK: Properties
        
        /// The user identifier
        private let userId: User.UID
        
        /// The Consumptions.
        @FirestoreEntityQuery
        private var consumptions: [Consumption]
        
        /// Bool value if ConsumptionForm is presented.
        @Binding
        private var isConsumptionFormPresented: Bool
        
        /// The Firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
        // MARK: Initializer
        
        /// Creates a new instance of `ConsumptionScreen.LatestEntriesSection`
        /// - Parameters:
        ///   - userId: The user identifier.
        ///   - isConsumptionFormPresented: Bool Binding value if ConsumptionForm is presented.
        init(
            userId: User.UID,
            isConsumptionFormPresented: Binding<Bool>
        ) {
            self.userId = userId
            self._consumptions = .init(
                context: userId,
                predicates: [
                    Consumption.orderByCreatedAtPredicate,
                    .limit(to: 3)
                ]
            )
            self._isConsumptionFormPresented = isConsumptionFormPresented
        }
        
    }
    
}

// MARK: - View

extension ConsumptionScreen.LatestEntriesSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: Text("Latest entries"),
            footer: Group {
                if self.consumptions.isEmpty {
                    EmptyPlaceholder(
                        systemImage: "plus.circle.fill",
                        title: "Consumptions",
                        subtitle: "Add your first consumption entry.",
                        primaryAction: .init(
                            title: "Add consumption",
                            action: {
                                self.isConsumptionFormPresented = true
                            }
                        )
                    )
                    .padding(.vertical)
                } else {
                    NavigationLink(
                        destination: ConsumptionList(
                            userId: self.userId
                        )
                    ) {
                        Text("Show all entries")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.accentColor)
                    .align(.centerHorizontal)
                    .padding(.vertical)
                }
            }
        ) {
            ForEach(
                self.consumptions
            ) { consumption in
                NavigationLink(
                    destination: ConsumptionView(
                        consumption: consumption
                    )
                ) {
                    ConsumptionList.Cell(
                        consumption: consumption
                    )
                }
            }
        }
        .headerProminence(.increased)
        .animation(
            .default,
            value: self.consumptions
        )
    }
    
}
