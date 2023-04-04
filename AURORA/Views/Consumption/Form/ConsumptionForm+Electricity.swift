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
        CurrencyTextField(
            "Costs",
            value: self.$partialElectricity.costs
        )
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
        DatePicker(
            "Start",
            selection: .init(
                get: {
                    self.partialElectricity.startDate?.dateValue() ?? .init()
                },
                set: { newValue in
                    self.partialElectricity.startDate = .init(date: newValue)
                }
            ),
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
            in: (self.partialElectricity.startDate?.dateValue() ?? .init())...,
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
