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
        
        /// The currently presented sheet.
        @Binding
        private var sheet: ConsumptionScreen.Sheet?
        
        /// The Firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
        // MARK: Initializer
        
        /// Creates a new instance of `ConsumptionScreen.LatestEntriesSection`
        /// - Parameters:
        ///   - userId: The user identifier.
        ///   - sheet: The currently presented sheet.
        init(
            userId: User.UID,
            sheet: Binding<ConsumptionScreen.Sheet?>
        ) {
            self.userId = userId
            self._consumptions = .init(
                context: userId,
                predicates: [
                    Consumption.orderByCreatedAtPredicate,
                    .limit(to: 3)
                ]
            )
            self._sheet = sheet
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
                                self.sheet = .consumptionForm
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
