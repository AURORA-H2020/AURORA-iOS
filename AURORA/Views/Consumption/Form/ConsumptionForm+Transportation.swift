import SwiftUI

// MARK: - ConsumptionForm+Transportation

extension ConsumptionForm {
    
    /// The ConsumptionForm Transportation content
    struct Transportation {
        
        /// The partial consumption transportation.
        @Binding
        var partialTransportation: Partial<Consumption.Transportation>
        
        /// The consumptions value.
        @Binding
        var value: Double?
        
    }
    
}

// MARK: - View

extension ConsumptionForm.Transportation: View {
    
    /// The content and behavior of the view.
    var body: some View {
        DatePicker(
            "Start of travel",
            selection: .init(
                get: {
                    self.partialTransportation.dateOfTravel?.dateValue() ?? .init()
                },
                set: { newValue in
                    self.partialTransportation.dateOfTravel = .init(date: newValue)
                }
            ),
            in: ConsumptionForm.preferredDatePickerRange
        )
        if self.partialTransportation.dateOfTravelEnd?.flatMap({ $0 }) == nil {
            HStack {
                Text("End of travel")
                Spacer()
                Button {
                    self.partialTransportation.dateOfTravelEnd = .init(
                        date: (self.partialTransportation.dateOfTravel?.dateValue() ?? Date()).addingTimeInterval(3600)
                    )
                } label: {
                    Text("Set")
                }
            }
        } else {
            HStack {
                DatePicker(
                    "End of travel",
                    selection: .init(
                        get: {
                            self.partialTransportation.dateOfTravelEnd.flatMap { $0 }?.dateValue() ?? .init()
                        },
                        set: { newValue in
                            self.partialTransportation.dateOfTravelEnd = .init(date: newValue)
                        }
                    ),
                    in: (self.partialTransportation.dateOfTravel?.dateValue() ?? Date())...ConsumptionForm.preferredDatePickerRange.upperBound
                )
                Button {
                    self.partialTransportation.dateOfTravelEnd = nil
                } label: {
                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .imageScale(.medium)
                    .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.borderless)
        }
        Picker(
            "Type",
            selection: self.$partialTransportation.transportationType
        ) {
            Text("Please choose")
                .tag(nil as Consumption.Transportation.TransportationType?)
            ForEach(
                Consumption
                    .Transportation
                    .TransportationType
                    .Group
                    .allCases,
                id: \.self
            ) { transportationTypeGroup in
                Section(
                    header: Text(transportationTypeGroup.localizedString)
                ) {
                    ForEach(
                        transportationTypeGroup.elements,
                        id: \.self
                    ) { transportationType in
                        Text(transportationType.localizedString)
                            .tag(transportationType as Consumption.Transportation.TransportationType?)
                    }
                }
            }
        }
        .onChange(
            of: self.partialTransportation.transportationType
        ) { transportationType in
            if transportationType?.isPublicVehicle == false {
                self.partialTransportation.publicVehicleOccupancy = nil
            }
            self.partialTransportation.privateVehicleOccupancy = transportationType?
                .privateVehicleOccupancyRange != nil ? 1 : nil
        }
        if self.partialTransportation.transportationType?.isPublicVehicle == true {
            Picker(
                "Occupancy",
                selection: self.$partialTransportation.publicVehicleOccupancy
            ) {
                Text("Please choose")
                    .tag(nil as Consumption.Transportation.PublicVehicleOccupancy??)
                ForEach(
                    Consumption.Transportation.PublicVehicleOccupancy.allCases,
                    id: \.self
                ) { occupancy in
                    Text(occupancy.localizedString)
                        .tag(occupancy as Consumption.Transportation.PublicVehicleOccupancy??)
                }
            }
        } else if let privateVehicleOccupancyRange = self.partialTransportation
            .transportationType?
            .privateVehicleOccupancyRange {
            Stepper(
                "Occupancy: \(self.partialTransportation.privateVehicleOccupancy?.flatMap { $0 } ?? 1)",
                value: .init(
                    get: {
                        self.partialTransportation.privateVehicleOccupancy?.flatMap { $0 } ?? 1
                    },
                    set: { privateVehicleOccupancy in
                        self.partialTransportation.privateVehicleOccupancy = privateVehicleOccupancy
                    }
                ),
                in: privateVehicleOccupancyRange
            )
        }
        HStack {
            NumberTextField(
                "Distance",
                value: self.$value
            )
            Text(
                verbatim: "km"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
    
}
