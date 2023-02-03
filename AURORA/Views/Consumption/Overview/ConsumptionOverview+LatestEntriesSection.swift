import SwiftUI

// MARK: - ConsumptionOverview+LatestEntriesSection

extension ConsumptionOverview {
    
    /// The ConsumptionOverview LatestEntriesSection
    struct LatestEntriesSection {
        
        // MARK: Properties
        
        /// The user identifier
        private let userId: User.UID
        
        /// The Consumptions.
        @FirestoreEntityQuery
        private var consumptions: [Consumption]
        
        /// Bool value if CreateConsumptionForm is presented.
        @Binding
        private var isCreateConsumptionFormPresented: Bool
        
        /// The Firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
        // MARK: Initializer
        
        /// Creates a new instance of `ConsumptionOverview.LatestEntriesSection`
        /// - Parameters:
        ///   - userId: The user identifier.
        ///   - isCreateConsumptionFormPresented: Bool Binding value if CreateConsumptionForm is presented.
        init(
            userId: User.UID,
            isCreateConsumptionFormPresented: Binding<Bool>
        ) {
            self.userId = userId
            self._consumptions = .init(
                context: userId,
                predicates: [
                    Consumption.orderByCreatedAtPredicate,
                    .limit(to: 3)
                ]
            )
            self._isCreateConsumptionFormPresented = isCreateConsumptionFormPresented
        }
        
    }
    
}

// MARK: - View

extension ConsumptionOverview.LatestEntriesSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            header: HStack {
                Text("Latest entries")
                Spacer()
                if !self.consumptions.isEmpty {
                    Button {
                        self.isCreateConsumptionFormPresented = true
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
                                self.isCreateConsumptionFormPresented = true
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
                self.consumptions,
                content: ConsumptionList.Cell.init
            )
        }
        .headerProminence(.increased)
        .animation(
            .default,
            value: self.consumptions
        )
    }
    
}