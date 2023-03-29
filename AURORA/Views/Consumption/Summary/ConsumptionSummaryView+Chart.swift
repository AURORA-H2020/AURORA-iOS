import Charts
import SwiftUI

// MARK: - ConsumptionSummaryView+Chart

extension ConsumptionSummaryView {
    
    /// The ConsumptionSummaryView Chart
    struct Chart {
        
        /// The ConsumptionSummary
        let consumptionSummary: ConsumptionSummary
        
        /// The ConsumptionSummaryView Mode
        let mode: Mode
        
    }
    
}

// MARK: - View

extension ConsumptionSummaryView.Chart: View {
    
    /// The content and behavior of the view.
    var body: some View {
        if #available(iOS 16.0, *) {
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
                                "Carbon Emission",
                                self.mode == .carbonEmission ? category.carbonEmission.total : category.energyExpended.total
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
            .chartYAxisLabel {
                switch self.mode {
                case .carbonEmission:
                    Text(CarbonEmissionsFormatStyle.symbol)
                case .energyExpended:
                    Text(UnitEnergy.kilowattHours.symbol)
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
    
}
