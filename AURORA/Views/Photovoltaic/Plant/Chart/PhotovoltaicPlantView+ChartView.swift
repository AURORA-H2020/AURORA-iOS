import Charts
import SwiftUI

// MARK: - PhotovoltaicPlantView+ChartView

extension PhotovoltaicPlantView {
    
    /// The ChartView
    struct ChartView {
        
        /// The chart data.
        let chartData: [ChartData]
        
        /// The photovoltaic plant.
        let photovoltaicPlant: PhotovoltaicPlant
        
        /// The photovoltaic plant investments.
        let photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
        
        /// The chart data source.
        @State
        private var chartDataSource: ChartData.Source = .personal
        
        /// The selected chart data entry identifier.
        @State
        private var selectedChartDataEntryID: ChartData.Entry.ID?
        
        /// Boolean if help is presented.
        @State
        private var isHelpPresented: Bool = false
        
        /// The selection feedback generator.
        @State
        private var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.ChartView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        let chartData = self.chartData.first { $0.source == self.chartDataSource }
        VStack {
            VStack(spacing: 12) {
                Picker(
                    String(),
                    selection: self.$chartDataSource
                ) {
                    ForEach(self.chartData.map(\.source), id: \.self) { source in
                        Text(source.localizedString)
                            .tag(source)
                    }
                }
                .pickerStyle(.segmented)
                if let chartData = chartData, let firstChartDataEntry = chartData.entries.first {
                    HStack {
                        Text("Since \(firstChartDataEntry.date.formatted(date: .long, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        Spacer()
                        Text(
                            chartData.totalProducedEnergy,
                            format: .measurement(
                                width: .abbreviated,
                                usage: .asProvided,
                                numberFormatStyle: .number.precision(.fractionLength(0...1))
                            )
                        )
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: self.chartDataSource)
                    }
                    .padding(.horizontal, 6)
                }
            }
            .padding()
            if let chartData = chartData {
                Chart {
                    ForEach(chartData.entries) { chartDataEntry in
                        BarMark(
                            x: .value("Date", chartDataEntry.date, unit: .day),
                            y: .value(chartData.source.localizedString, chartDataEntry.producedEnergy.value)
                        )
                        .foregroundStyle(
                            self.selectedChartDataEntryID
                                .flatMap { $0 == chartDataEntry.id ? Color.accentColor : Color.accentColor.opacity(0.5) }
                                ?? Color.accentColor
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(
                        position: .leading
                    ) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text(
                                Measurement<UnitPower>(
                                    value: value.as(Double.self) ?? 0,
                                    unit: .kilowatts
                                )
                                .formatted(
                                    .measurement(
                                        width: .abbreviated,
                                        usage: .asProvided
                                    )
                                )
                            )
                        }
                    }
                }
                .chartOverlay { chart in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0
                                )
                                .onChanged { value in
                                    let date = chart.value(
                                        atX: value.location.x - geometry[chart.plotAreaFrame].origin.x,
                                        as: Date.self
                                    )
                                    .flatMap(Calendar.current.startOfDay)
                                    guard self.selectedChartDataEntryID != date,
                                          chartData.entries.contains(where: { $0.date == date }) else {
                                        return
                                    }
                                    self.selectedChartDataEntryID = date
                                    self.selectionFeedbackGenerator.selectionChanged()
                                }
                                .onEnded { _ in
                                    self.selectedChartDataEntryID = nil
                                }
                            )
                    }
                }
                .overlay {
                    if let selectedChartDataEntryID = self.selectedChartDataEntryID,
                       let selectedEntry = chartData.entries.first(where: { $0.id == selectedChartDataEntryID }) {
                        VStack(alignment: .trailing) {
                            Text(
                                selectedEntry.date.formatted(date: .long, time: .omitted)
                            )
                            .font(.caption)
                            .foregroundStyle(.gray)
                            Text(
                                selectedEntry.producedEnergy.formatted(
                                    .measurement(
                                        width: .abbreviated,
                                        usage: .asProvided,
                                        numberFormatStyle: .number.precision(.fractionLength(0...1))
                                    )
                                )
                            )
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                            .contentTransition(.numericText())
                            .animation(.smooth, value: self.selectedChartDataEntryID)
                        }
                        .padding()
                        .align(.topTrailing)
                    }
                }
            }
        }
        .navigationTitle("Production")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.isHelpPresented = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .onAppear {
            self.selectionFeedbackGenerator.prepare()
        }
        .sheet(
            isPresented: self.$isHelpPresented
        ) {
            SheetNavigationView {
                PhotovoltaicPlantView.HelpView(
                    photovoltaicPlant: self.photovoltaicPlant
                )
            }
            .presentationDetents([.medium, .large])
        }
    }
    
}
