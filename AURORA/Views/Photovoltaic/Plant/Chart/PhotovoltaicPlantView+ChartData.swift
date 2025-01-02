import Foundation

// MARK: - PhotovoltaicPlantView+ChartData

extension PhotovoltaicPlantView {
    
    /// The chart data.
    struct ChartData: Hashable, Identifiable {
        
        // MARK: Properties
        
        /// The identifier.
        var id: Source {
            self.source
        }
        
        /// The chart source.
        let source: Source
        
        /// The entries.
        let entries: [Entry]
        
        /// The total produced energy.
        let totalProducedEnergy: Measurement<UnitPower>
        
        /// Boolean if is empty.
        var isEmpty: Bool {
            self.entries.isEmpty || self.totalProducedEnergy.value == 0
        }
        
        // MARK: Initializer
        
        /// Creates a new instance of ``PhotovoltaicPlantView.ChartData``
        /// - Parameters:
        ///   - source: The source.
        ///   - entries: The entries.
        init(
            source: Source,
            entries: [Entry]
        ) {
            self.source = source
            self.entries = entries
            self.totalProducedEnergy = .init(
                value: entries.map(\.producedEnergy.value).reduce(0, +),
                unit: .kilowatts
            )
        }
        
    }
    
}

// MARK: - Convenience Initializer

extension PhotovoltaicPlantView.ChartData {
    
    /// Creates a new instance of ``PhotovoltaicPlantView.ChartData``
    /// - Parameters:
    ///   - source: The source.
    ///   - photovoltaicPlant: The photovoltaic plant.
    ///   - photovoltaicPlantDataEntries: The photovoltaic plant data entries.
    ///   - photovoltaicPlantInvestments: The photovoltaic plant investments.
    init(
        source: Source,
        photovoltaicPlant: PhotovoltaicPlant,
        photovoltaicPlantDataEntries: [PhotovoltaicPlantDataEntry],
        photovoltaicPlantInvestments: [PhotovoltaicPlantInvestment]
    ) {
        self.init(
            source: source,
            entries: photovoltaicPlantDataEntries
                .map { photovoltaicPlantDataEntry in
                    .init(
                        date: Calendar.current.startOfDay(for: photovoltaicPlantDataEntry.date.dateValue()),
                        producedEnergy: .init(
                            value: {
                                switch source {
                                case .personal:
                                    let totalInvestmentCapacity = photovoltaicPlantInvestments
                                        .filter { $0.investmentDate.dateValue() <= photovoltaicPlantDataEntry.date.dateValue() }
                                        .reduce(0) { $0 + ($1.investmentCapacity ?? 0) }
                                    let photovoltaicPlantCapacity = photovoltaicPlant.capacity == 0 ? 1 : photovoltaicPlant.capacity ?? 1
                                    return (totalInvestmentCapacity / photovoltaicPlantCapacity) * photovoltaicPlantDataEntry.producedEnergy
                                case .total:
                                    return photovoltaicPlantDataEntry.producedEnergy
                                }
                            }(),
                            unit: .kilowatts
                        )
                    )
                }
        )
    }
    
}

// MARK: - PhotovoltaicPlantView+ChartData+Source

extension PhotovoltaicPlantView.ChartData {
    
    /// A source.
    enum Source: String, Codable, Hashable, Sendable, CaseIterable {
        /// Personal.
        case personal
        /// Total.
        case total
        
        /// A localized string.
        var localizedString: String {
            switch self {
            case .personal:
                return .init(localized: "Your Production")
            case .total:
                return .init(localized: "Total Production")
            }
        }
    }
    
}

// MARK: - PhotovoltaicPlantView+ChartData+Entry

extension PhotovoltaicPlantView.ChartData {
    
    /// An entry.
    struct Entry: Hashable, Identifiable {
        
        /// The identifier.
        var id: Date {
            self.date
        }
        
        /// The date.
        let date: Date
        
        /// The produced energy.
        let producedEnergy: Measurement<UnitPower>
        
    }
    
}
