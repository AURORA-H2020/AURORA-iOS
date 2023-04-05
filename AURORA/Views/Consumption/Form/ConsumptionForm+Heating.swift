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
        
    }
    
}

// MARK: - View

extension ConsumptionForm.Heating: View {
    
    /// The content and behavior of the view.
    var body: some View {
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
                    Consumption.Heating.DistrictHeatingSource.allCases,
                    id: \.self
                ) { districtHeatingSource in
                    Text(districtHeatingSource.localizedString)
                        .tag(districtHeatingSource as Consumption.Heating.DistrictHeatingSource??)
                }
            }
        }
        DatePicker(
            "Start",
            selection: .init(
                get: {
                    self.partialHeating.startDate?.dateValue() ?? .init()
                },
                set: { newValue in
                    self.partialHeating.startDate = .init(date: newValue)
                }
            ),
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
            in: (self.partialHeating.startDate?.dateValue() ?? .init())...,
            displayedComponents: [.date]
        )

        HStack {
            NumberTextField(
                "Consumption",
                value: self.$value
            )
            Text(KilowattHoursFormatStyle.symbol)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
}
