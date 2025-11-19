import Charts
import SwiftUI

// MARK: - ConsumptionSummaryView+Chart

extension ConsumptionSummaryView {
    
    /// The ConsumptionSummaryView Chart
    struct Chart {
        
        /// The ConsumptionSummary
        let consumptionSummary: ConsumptionSummary
        
        /// The ConsumptionSummary Mode
        let mode: ConsumptionSummary.Mode
        
        /// The locale.
        @Environment(\.locale)
        private var locale
        
    }
    
}

// MARK: - View

extension ConsumptionSummaryView.Chart: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Charts.Chart {
            ForEach(self.consumptionSummary.months) { month in
                let monthDate: Date = month.date() ?? Date()
                ForEach(month.categories) { category in
                    BarMark(
                        x: .value(
                            "Month",
                            monthDate,
                            unit: .month
                        ),
                        y: .value(
                            self.mode.localizedString,
                            category.labeledConsumption(for: self.mode).total
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
        .frame(minHeight: 220)
        .chartYAxisLabel {
            switch self.mode {
            case .carbonEmission:
                Text(
                    verbatim: [
                        ConsumptionMeasurement.Unit.kilograms.converted(to: .init(locale: self.locale)).symbol,
                        ConsumptionMeasurement.Unit.carbonEmissionsSymbol
                    ]
                    .joined(separator: " ")
                )
            case .energyExpended:
                Text(ConsumptionMeasurement.Unit.kilowattHours.symbol)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month))
        }
        .chartForegroundStyleScale(
            [
                Consumption.Category.electricity.localizedString: Consumption.Category.electricity.tintColor,
                Consumption.Category.heating.localizedString: Consumption.Category.heating.tintColor,
                Consumption.Category.transportation.localizedString: Consumption.Category.transportation.tintColor
            ]
        )
        .chartSymbolScale(
            [
                Consumption.Category.electricity.localizedString: Circle(),
                Consumption.Category.heating.localizedString: Circle(),
                Consumption.Category.transportation.localizedString: Circle()
            ]
        )
    }
    
}
