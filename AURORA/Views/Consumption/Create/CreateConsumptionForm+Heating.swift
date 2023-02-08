import SwiftUI

// MARK: - CreateConsumptionForm+Heating

extension CreateConsumptionForm {
    
    /// The CreateConsumptionForm Heating content
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

extension CreateConsumptionForm.Heating: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack {
            NumberTextField(
                "Costs",
                value: self.$partialHeating.costs
            )
            Text(
                verbatim: "€"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
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
            Text(
                verbatim: "kwH"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
    
}
