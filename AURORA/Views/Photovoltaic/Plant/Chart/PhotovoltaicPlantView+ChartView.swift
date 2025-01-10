import Charts
import SwiftUI

// MARK: - PhotovoltaicPlantView+ChartView

extension PhotovoltaicPlantView {
    
    /// The ChartView
    struct ChartView {
        
        // MARK: Properties
        
        /// The past 30 days chart data.
        private let past30DaysChartData: [ChartData]
        
        /// The photovoltaic plant.
        private let photovoltaicPlant: PhotovoltaicPlant
        
        /// The photovoltaic plant investments.
        private let photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
        
        /// The since investment chart data.
        @State
        private var sinceInvestmentChartData = [ChartData]()
        
        /// The display mode
        @State
        private var displayMode: DisplayMode = .past30Days
        
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
        
        /// The firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
        // MARK: Properties
        
        /// Creates a new instance of ``PhotovoltaicPlantView.ChartView``
        /// - Parameters:
        ///   - chartData: The past 30 days chart data.
        ///   - photovoltaicPlant: The photovoltaic plant.
        ///   - photovoltaicPlantInvestments: The photovoltaic plant investments.
        init(
            chartData: [ChartData],
            photovoltaicPlant: PhotovoltaicPlant,
            photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
        ) {
            self.past30DaysChartData = chartData
            self.photovoltaicPlant = photovoltaicPlant
            self.photovoltaicPlantInvestments = photovoltaicPlantInvestments
        }
        
    }
    
}

// MARK: - ChartData

private extension PhotovoltaicPlantView.ChartView {
    
    /// The computed chart data based on `displayMode`.
    var chartData: [PhotovoltaicPlantView.ChartData] {
        switch self.displayMode {
        case .past30Days:
            return self.past30DaysChartData
        case .sinceInvestmentStart:
            return self.sinceInvestmentChartData
        }
    }
    
}

// MARK: - DisplayMode

private extension PhotovoltaicPlantView.ChartView {
    
    /// A display mode.
    enum DisplayMode: String, Hashable, Identifiable, CaseIterable {
        /// Past 30 days.
        case past30Days
        /// Since investment start
        case sinceInvestmentStart
        
        /// The stable identity of the entity associated with this instance.
        var id: RawValue {
            self.rawValue
        }
        
        /// A localized string.
        var localizedString: String {
            switch self {
            case .past30Days:
                return .init(localized: "In the past 30 days")
            case .sinceInvestmentStart:
                return .init(localized: "Since Investment")
            }
        }
        
        /// The system image name.
        var systemImageName: String {
            switch self {
            case .past30Days:
                return "chart.bar.xaxis"
            case .sinceInvestmentStart:
                return "chart.xyaxis.line"
            }
        }
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
                        let xValue = PlottableValue.value("Date", chartDataEntry.date, unit: .day)
                        let yValue = PlottableValue.value(chartData.source.localizedString, chartDataEntry.producedEnergy.value)
                        switch self.displayMode {
                        case .past30Days:
                            BarMark(
                                x: xValue,
                                y: yValue
                            )
                            .foregroundStyle(
                                self.selectedChartDataEntryID
                                    .flatMap { $0 == chartDataEntry.id ? Color.accentColor : Color.accentColor.opacity(0.5) }
                                    ?? Color.accentColor
                            )
                        case .sinceInvestmentStart:
                            LineMark(
                                x: xValue,
                                y: yValue
                            )
                            .symbol {
                                Circle()
                                    .fill(
                                        self.selectedChartDataEntryID
                                            .flatMap { $0 == chartDataEntry.id ? Color.accentColor : Color.clear }
                                            ?? Color.accentColor
                                    )
                                    .frame(width: 8)
                            }
                            .foregroundStyle(Color.accentColor)
                        }
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
                Menu {
                    ForEach(DisplayMode.allCases) { displayMode in
                        Button {
                            self.displayMode = displayMode
                            self.selectionFeedbackGenerator.selectionChanged()
                        } label: {
                            LabeledContent {
                                Label {
                                    Text(displayMode.localizedString)
                                } icon: {
                                    Image(systemName: displayMode.systemImageName)
                                }
                            } label: {
                                if self.displayMode == displayMode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(self.displayMode == displayMode)
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
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
        .animation(.smooth, value: self.displayMode)
        .animation(.smooth, value: self.chartDataSource)
        .animation(.smooth, value: self.sinceInvestmentChartData)
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
        .task(id: self.displayMode) {
            guard self.displayMode == .sinceInvestmentStart,
                  self.sinceInvestmentChartData.isEmpty,
                  let photovoltaiPlantEntityReference = FirestoreEntityReference(self.photovoltaicPlant),
                  let firstInvestmentDate = self.photovoltaicPlantInvestments.map({ $0.investmentDate.dateValue() }).min(),
                  let photovoltaicPlantDataEntries = try? await self.firebase
                      .firestore
                      .get(
                          PhotovoltaicPlantDataEntry.self,
                          context: photovoltaiPlantEntityReference,
                          where: { query in
                              query.whereField("date", isGreaterThanOrEqualTo: firstInvestmentDate)
                          }
                      ) else {
                return
            }
            self.sinceInvestmentChartData = .init(
                photovoltaicPlant: self.photovoltaicPlant,
                photovoltaicPlantDataEntries: photovoltaicPlantDataEntries,
                photovoltaicPlantInvestments: self.photovoltaicPlantInvestments
            )
        }
    }
    
}
