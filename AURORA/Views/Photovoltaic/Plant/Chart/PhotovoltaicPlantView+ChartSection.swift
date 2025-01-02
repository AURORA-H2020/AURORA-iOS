import Charts
import SwiftUI

// MARK: - PhotovoltaicPlantView+ChartSection

extension PhotovoltaicPlantView {
    
    /// The ChartSection
    struct ChartSection {
        
        // MARK: Properties
        
        /// The chart data.
        private let chartData: [ChartData]
        
        /// The photovoltaic plant.
        private let photovoltaicPlant: PhotovoltaicPlant
        
        /// The photovoltaic plant investments.
        private let photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
        
        /// Boolean if help is presented.
        @Binding
        private var isHelpPresented: Bool
        
        /// The presented photovoltaic plant investment form mode.
        @Binding
        private var presentedPhotovoltaicPlantInvestmentFormMode: PhotovoltaicPlantInvestmentForm.Mode?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``PhotovoltaicPlantView.ChartSection``
        /// - Parameters:
        ///   - photovoltaicPlant: The photovoltaic plant.
        ///   - photovoltaicPlantDataEntries: The photovoltaic plant data entries.
        ///   - photovoltaicPlantInvestments: The photovoltaic plant investments.
        ///   - isHelpPresented: Boolean if help is presented.
        ///   - presentedPhotovoltaicPlantInvestmentFormMode: The presented photovoltaic plant investment form mode.
        init(
            photovoltaicPlant: PhotovoltaicPlant,
            photovoltaicPlantDataEntries: [PhotovoltaicPlantDataEntry],
            photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment],
            isHelpPresented: Binding<Bool>,
            presentedPhotovoltaicPlantInvestmentFormMode: Binding<PhotovoltaicPlantInvestmentForm.Mode?>
        ) {
            self.chartData = ChartData
                .Source
                .allCases
                .map { source in
                    .init(
                        source: source,
                        photovoltaicPlant: photovoltaicPlant,
                        photovoltaicPlantDataEntries: photovoltaicPlantDataEntries,
                        photovoltaicPlantInvestments: photovoltaicPlantInvestments
                    )
                }
            self.photovoltaicPlant = photovoltaicPlant
            self.photovoltaicPlantInvestments = photovoltaicPlantInvestments
            self._isHelpPresented = isHelpPresented
            self._presentedPhotovoltaicPlantInvestmentFormMode = presentedPhotovoltaicPlantInvestmentFormMode
        }
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.ChartSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
            NavigationLink(
                destination: PhotovoltaicPlantView
                    .ChartView(
                        chartData: self.chartData,
                        photovoltaicPlant: self.photovoltaicPlant,
                        photovoltaicPlantInvestments: self.photovoltaicPlantInvestments
                    )
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(self.chartData) { chartData in
                            VStack(alignment: .leading) {
                                Text(
                                    chartData.source.localizedString
                                )
                                .font(.caption)
                                .foregroundStyle(.primary)
                                if chartData.source == .personal && self.photovoltaicPlantInvestments.isEmpty {
                                    Button {
                                        self.presentedPhotovoltaicPlantInvestmentFormMode = .create(self.photovoltaicPlant)
                                    } label: {
                                        Text("Add investment")
                                            .font(.caption2)
                                    }
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.capsule)
                                    .controlSize(.small)
                                    .tint(.accentColor)
                                } else {
                                    Text(
                                        chartData.totalProducedEnergy,
                                        format: .measurement(
                                            width: .abbreviated,
                                            usage: .asProvided,
                                            numberFormatStyle: .number.precision(.fractionLength(0...1))
                                        )
                                    )
                                    .font(.system(.title, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.accentColor)
                                    .contentTransition(.numericText())
                                }
                            }
                        }
                    }
                    Spacer()
                    if let totalSourceChartData = self.chartData.first(where: { $0.source == .total }) {
                        Chart {
                            ForEach(totalSourceChartData.entries) { chartDataEntry in
                                BarMark(
                                    x: .value("Date", chartDataEntry.date, unit: .day),
                                    y: .value("Production", chartDataEntry.producedEnergy.value)
                                )
                            }
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis(.hidden)
                        .chartLegend(.hidden)
                        .opacity(0.35)
                        .scaleEffect(1.1)
                        .offset(x: 20, y: 10)
                    }
                }
                .padding(.vertical, 6)
            }
        } header: {
            HStack {
                VStack(alignment: .leading) {
                    Label {
                        Text("Production")
                    } icon: {
                        Image(
                            systemName: "chart.bar.xaxis"
                        )
                        .foregroundStyle(Color.accentColor)
                    }
                    Text("In the past 30 days")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                Spacer()
                Button {
                    self.isHelpPresented = true
                } label: {
                    Image(
                        systemName: "questionmark.circle.fill"
                    )
                    .imageScale(.large)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    
                }
                .tint(.accentColor)
            }
        }
        .headerProminence(.increased)
    }
    
}
