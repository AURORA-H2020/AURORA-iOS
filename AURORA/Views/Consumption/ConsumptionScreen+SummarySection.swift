import Charts
import SwiftUI

// MARK: - ConsumptionScreen+SummarySection

extension ConsumptionScreen {
    
    /// The ConsumptionScreen SummarySection
    struct SummarySection {
        
        // MARK: Properties
        
        /// The user identifier
        private let userId: User.UID
        
        /// Bool value if ConsumptionSummaryView is presented.
        @Binding
        private var isConsumptionSummaryViewPresented: Bool
        
        /// The Consumptions.
        @FirestoreEntityQuery
        private var consumptionSummaries: [ConsumptionSummary]
        
        // MARK: Initializer
        
        /// Creates a new instance of `ConsumptionScreen.SummarySection`
        /// - Parameters:
        ///   - userId: The user identifier.
        ///   - isConsumptionSummaryViewPresented: Bool value if ConsumptionSummaryView is presented.
        init(
            userId: User.UID,
            isConsumptionSummaryViewPresented: Binding<Bool>
        ) {
            self.userId = userId
            self._isConsumptionSummaryViewPresented = isConsumptionSummaryViewPresented
            self._consumptionSummaries = .init(
                context: userId,
                predicates: [
                    ConsumptionSummary.orderByYearPredicate,
                    .limit(to: 1)
                ]
            )
        }
        
    }
    
}

// MARK: - View

extension ConsumptionScreen.SummarySection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        if let consumptionSummary = self.consumptionSummaries.first {
            Section {
                VStack(spacing: 20) {
                    HStack {
                        ForEach(Consumption.Category.allCases, id: \.self) { category in
                            let consumptionSummaryCategory = consumptionSummary.category(category)
                            Button {
                                self.isConsumptionSummaryViewPresented = true
                            } label: {
                                HStack {
                                    category.icon
                                    Divider()
                                    if let label = consumptionSummaryCategory?.carbonEmission.label {
                                        Text(verbatim: label.value)
                                    } else {
                                        Text(verbatim: "?")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(consumptionSummaryCategory?.carbonEmission.label?.color.flatMap(Color.init) ?? .gray)
                        }
                    }
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(consumptionSummary.months) { month in
                                let monthDate: Date = month.date() ?? Date()
                                ForEach(month.categories) { category in
                                    BarMark(
                                        x: .value(
                                            "Month",
                                            monthDate,
                                            unit: .month
                                        ),
                                        y: .value(
                                            "Carbon Emission",
                                            category.carbonEmission.total
                                        )
                                    )
                                    .foregroundStyle(
                                        by: .value(
                                            "Category",
                                            category.category.localizedString
                                        )
                                    )
                                    .symbol(
                                        by: .value(
                                            "Category",
                                            category.category.localizedString
                                        )
                                    )
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month))
                        }
                        // swiftlint:disable line_length
                        .chartForegroundStyleScale(
                            [
                                Consumption.Category.electricity.localizedString: Consumption.Category.electricity.tintColor,
                                Consumption.Category.heating.localizedString: Consumption.Category.heating.tintColor,
                                Consumption.Category.transportation.localizedString: Consumption.Category.transportation.tintColor
                            ]
                        )
                        // swiftlint:enable line_length
                        .chartSymbolScale(
                            [
                                Consumption.Category.electricity.localizedString: Circle(),
                                Consumption.Category.heating.localizedString: Circle(),
                                Consumption.Category.transportation.localizedString: Circle()
                            ]
                        )
                        .frame(minHeight: 150)
                    }
                }
            }
            .listRowBackground(Color(.systemGroupedBackground))
            .listRowInsets(.init())
            .headerProminence(.increased)
        }
    }
    
}
