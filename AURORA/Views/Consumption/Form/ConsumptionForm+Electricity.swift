import SwiftUI

// MARK: - ConsumptionForm+Electricity

extension ConsumptionForm {
    
    /// The ConsumptionForm Electricity content
    struct Electricity {
        
        /// The partial consumption electricity.
        @Binding
        var partialElectricity: Partial<Consumption.Electricity>
        
        /// The consumptions value.
        @Binding
        var value: Double?
        
    }
    
}

// MARK: - View

extension ConsumptionForm.Electricity: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            footer: Text(
                "Select the appropriate electricity source."
            )
            .multilineTextAlignment(.leading)
        ) {
            Picker(
                "Electricity source",
                selection: self.$partialElectricity.electricitySource
            ) {
                Text("Please choose")
                    .tag(nil as Consumption.Electricity.ElectricitySource??)
                ForEach(
                    Consumption.Electricity.ElectricitySource.allCases,
                    id: \.self
                ) { electricitySource in
                    Text(electricitySource.localizedString)
                        .tag(electricitySource as Consumption.Electricity.ElectricitySource??)
                }
            }
        }
        Section(
            footer: Text(
                self.partialElectricity.electricitySource == .homePhotovoltaics 
                    ? "You can usually find this information on an app or website provided by your PV installation contractor."
                    : "You can find this information on your electricity bill."
            )
            .multilineTextAlignment(.leading)
        ) {
            HStack {
                NumberTextField(
                    self.partialElectricity.electricitySource == .homePhotovoltaics 
                        ? "Energy produced"
                        : "Consumption",
                    value: self.$value
                )
                Text(KilowattHoursFormatStyle.symbol)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if self.partialElectricity.electricitySource == .homePhotovoltaics {
                HStack {
                    NumberTextField(
                        "Energy exported (optional)",
                        value: .init(
                            get: {
                                self.partialElectricity.electricityExported?.flatMap { $0 }
                            },
                            set: { newValue in
                                self.partialElectricity.electricityExported = newValue
                            }
                        )
                    )
                    Text(KilowattHoursFormatStyle.symbol)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onChange(
            of: self.partialElectricity.electricitySource
        ) { electricitySource in
            guard electricitySource != .homePhotovoltaics else {
                return
            }
            self.partialElectricity.removeValue(for: \.electricityExported)
        }
        Section(
            footer: Text(
                "How many people, including you, live in your household."
            )
            .multilineTextAlignment(.leading)
        ) {
            Stepper(
                "People in household: \(self.partialElectricity.householdSize ?? 1)",
                value: .init(
                    get: {
                        self.partialElectricity.householdSize ?? 1
                    },
                    set: { householdSize in
                        self.partialElectricity.householdSize = householdSize
                    }
                ),
                in: 1...100
            )
        }
        Section(
            footer: Text(
                "Select the beginning and end of this consumption. You can find this information on your electricity bill."
            )
            .multilineTextAlignment(.leading)
        ) {
            DatePicker(
                "Beginning",
                selection: .init(
                    get: {
                        self.partialElectricity.startDate?.dateValue() ?? .init()
                    },
                    set: { newValue in
                        self.partialElectricity.startDate = .init(date: newValue)
                    }
                ),
                in: ConsumptionForm.preferredDatePickerRange.lowerBound...(self.partialElectricity.endDate?.dateValue() ?? ConsumptionForm.preferredDatePickerRange.upperBound),
                displayedComponents: [.date]
            )
            DatePicker(
                "End",
                selection: .init(
                    get: {
                        self.partialElectricity.endDate?.dateValue() ?? .init()
                    },
                    set: { newValue in
                        self.partialElectricity.endDate = .init(date: newValue)
                    }
                ),
                in: (self.partialElectricity.startDate?.dateValue() ?? ConsumptionForm.preferredDatePickerRange.lowerBound)...ConsumptionForm.preferredDatePickerRange.upperBound,
                displayedComponents: [.date]
            )
        }
        CurrencyTextField(
            "Costs",
            value: .init(
                get: {
                    self.partialElectricity.costs?.flatMap { $0 }
                },
                set: { newValue in
                    self.partialElectricity.costs = newValue
                }
            )
        )
    }
    
}
