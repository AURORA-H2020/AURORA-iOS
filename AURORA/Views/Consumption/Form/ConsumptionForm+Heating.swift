import SwiftUI

// MARK: - ConsumptionForm+Heating

extension ConsumptionForm {
    
    /// The ConsumptionForm Heating content
    struct Heating {
        
        /// The partial consumption heating.
        @Binding
        var partialHeating: Partial<Consumption.Heating>
        
        /// The consumptions value.
        @Binding
        var value: Double?
        
        /// The locale.
        @Environment(\.locale)
        private var locale
        
    }
    
}

// MARK: - View

extension ConsumptionForm.Heating: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section(
            footer: Text(
                "Select your type of heating. You can find this information on your heating bill."
            )
            .multilineTextAlignment(.leading)
        ) {
            Picker(
                "Heating fuel",
                selection: self.$partialHeating.heatingFuel
            ) {
                Text("Please choose")
                    .tag(nil as Consumption.Heating.HeatingFuel?)
                ForEach(
                    Consumption.Heating.HeatingFuel.allCases,
                    id: \.self
                ) { heatingFuel in
                    Text(heatingFuel.localizedString)
                        .tag(heatingFuel as Consumption.Heating.HeatingFuel?)
                }
            }
            if self.partialHeating.heatingFuel == .district {
                Picker(
                    "District heating source",
                    selection: self.$partialHeating.districtHeatingSource
                ) {
                    Text("Please choose")
                        .tag(nil as Consumption.Heating.DistrictHeatingSource??)
                    ForEach(
                        {
                            var districtHeatingSources = Consumption.Heating.DistrictHeatingSource.allCases
                            // Hide coal if not currently set
                            if self.partialHeating.districtHeatingSource != .coal {
                                districtHeatingSources = districtHeatingSources.filter { $0 != .coal }
                            }
                            // Hide biomass if not currently set
                            if self.partialHeating.districtHeatingSource != .biomass {
                                districtHeatingSources = districtHeatingSources.filter { $0 != .biomass }
                            }
                            return districtHeatingSources
                        }(),
                        id: \.self
                    ) { districtHeatingSource in
                        Text(districtHeatingSource.localizedString)
                            .tag(districtHeatingSource as Consumption.Heating.DistrictHeatingSource??)
                    }
                }
            }
        }
        .onChange(
            of: self.partialHeating.heatingFuel
        ) { heatingFuel in
            guard heatingFuel != .district else {
                return
            }
            self.partialHeating.removeValue(for: \.districtHeatingSource)
        }
        Section(
            footer: Text(
                "You can find this information on your heating bill."
            )
            .multilineTextAlignment(.leading)
        ) {
            MeasurementTextField(
                "Consumption",
                value: self.$value
            ) {
                Text(
                    ConsumptionMeasurement.Unit(
                        measurementSystem: .init(locale: self.locale),
                        category: .heating,
                        heatingFuel: self.partialHeating.heatingFuel
                    )
                    .symbol
                )
            }
        }
        Section(
            footer: Text(
                "How many people, including you, live in your household."
            )
            .multilineTextAlignment(.leading)
        ) {
            Stepper(
                "People in household: \(self.partialHeating.householdSize ?? 1)",
                value: .init(
                    get: {
                        self.partialHeating.householdSize ?? 1
                    },
                    set: { householdSize in
                        self.partialHeating.householdSize = householdSize
                    }
                ),
                in: 1...100
            )
        }
        Section(
            footer: Text(
                "Select the beginning and end of this consumption. You can find this information on your heating bill."
            )
            .multilineTextAlignment(.leading)
        ) {
            DatePicker(
                "Beginning",
                selection: .init(
                    get: {
                        self.partialHeating.startDate?.dateValue() ?? .init()
                    },
                    set: { newValue in
                        self.partialHeating.startDate = .init(date: newValue)
                    }
                ),
                in: ConsumptionForm.preferredDatePickerRange.lowerBound...(self.partialHeating.endDate?.dateValue() ?? ConsumptionForm.preferredDatePickerRange.upperBound),
                displayedComponents: [.date]
            )
            DatePicker(
                "End",
                selection: .init(
                    get: {
                        self.partialHeating.endDate?.dateValue() ?? .init()
                    },
                    set: { newValue in
                        self.partialHeating.endDate = .init(date: newValue)
                    }
                ),
                in: (self.partialHeating.startDate?.dateValue() ?? ConsumptionForm.preferredDatePickerRange.lowerBound)...ConsumptionForm.preferredDatePickerRange.upperBound,
                displayedComponents: [.date]
            )
        }
        CurrencyTextField(
            "Costs",
            value: .init(
                get: {
                    self.partialHeating.costs?.flatMap { $0 }
                },
                set: { newValue in
                    self.partialHeating.costs = newValue
                }
            )
        )
    }
    
}
