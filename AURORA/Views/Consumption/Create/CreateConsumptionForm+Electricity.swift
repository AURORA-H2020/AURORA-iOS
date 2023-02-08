import SwiftUI

// MARK: - CreateConsumptionForm+Electricity

extension CreateConsumptionForm {
    
    /// The CreateConsumptionForm Electricity content
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

extension CreateConsumptionForm.Electricity: View {
    
    /// The content and behavior of the view.
    var body: some View {
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
                "Costs",
                value: self.$partialElectricity.costs
            )
            Text(
                verbatim: "€"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
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