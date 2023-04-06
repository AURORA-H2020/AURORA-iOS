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
                "You can find this information on your electricity bill."
            )
            .multilineTextAlignment(.leading)
        ) {
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
        Section(
            footer: Text(
                "How many people, including you, are living in your household."
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
                "Select the start and end date of this consumption. You can find this information on your electricity bill."
            )
            .multilineTextAlignment(.leading)
        ) {
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
