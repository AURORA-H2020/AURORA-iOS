import SwiftUI

// MARK: - ConsumptionView

/// The ConsumptionView
struct ConsumptionView {
    
    /// The Consumption
    let consumption: Consumption
    
    /// The consumption form sheet mode
    @State
    private var consumptionFormSheetMode: ConsumptionFormSheetMode?
    
    /// Bool value if delete confirmation dialog is presented
    @State
    private var isDeleteConfirmationDialogPresented = false
    
    /// The dismiss action
    @Environment(\.dismiss)
    private var dismiss
    
    /// The locale.
    @Environment(\.locale)
    private var locale
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - ConsumptionFormSheetMode

private extension ConsumptionView {
    
    /// A consumption form sheet mode
    enum ConsumptionFormSheetMode: String, Hashable, Identifiable {
        /// Edit
        case edit
        /// Duplicate
        case duplicate
        
        /// The stable identity of the entity associated with this instance.
        var id: RawValue {
            self.rawValue
        }
    }
    
}

// MARK: - View

extension ConsumptionView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                Entry {
                    Text(self.consumption.formatted())
                } label: {
                    Text(self.consumption.category.localizedString)
                }
                if let carbonEmissions = self.consumption.carbonEmissions {
                    Entry {
                        Text(
                            ConsumptionMeasurement(
                                value: carbonEmissions,
                                unit: .kilograms
                            )
                            .converted(to: .init(locale: self.locale))
                            .formatted(isCarbonEmissions: true)
                        )
                    } label: {
                        Text("Carbon emissions")
                    }
                }
            }
            if let electricity = self.consumption.electricity {
                if let costs = electricity.costs {
                    Entry {
                        CurrencyText(costs)
                            .foregroundColor(.secondary)
                    } label: {
                        Text("Costs")
                    }
                }
                Entry {
                    Text(String(electricity.householdSize))
                        .foregroundColor(.secondary)
                } label: {
                    Text("People in household")
                }
                if let electricitySource = electricity.electricitySource {
                    Entry {
                        Text(electricitySource.localizedString)
                            .foregroundColor(.secondary)
                    } label: {
                        Text("Electricity source")
                    }
                }
                if let energyExported = electricity.electricityExported {
                    Entry {
                        Text(
                            ConsumptionMeasurement(
                                value: energyExported,
                                unit: .kilowattHours
                            )
                            .converted(to: .init(locale: self.locale))
                            .formatted()
                        )
                        .foregroundColor(.secondary)
                    } label: {
                        Text("Energy exported")
                    }
                }
                Entry {
                    Text(
                        electricity.startDate.dateValue(),
                        style: .date
                    )
                    .foregroundColor(.secondary)
                } label: {
                    Text("Beginning")
                }
                Entry {
                    Text(
                        electricity.endDate.dateValue(),
                        style: .date
                    )
                    .foregroundColor(.secondary)
                } label: {
                    Text("End")
                }
            } else if let heating = self.consumption.heating {
                if let costs = heating.costs {
                    Entry {
                        CurrencyText(costs)
                            .foregroundColor(.secondary)
                    } label: {
                        Text("Costs")
                    }
                }
                Entry {
                    Text(String(heating.householdSize))
                        .foregroundColor(.secondary)
                } label: {
                    Text("People in household")
                }
                Entry {
                    Text(
                        heating.startDate.dateValue(),
                        style: .date
                    )
                    .foregroundColor(.secondary)
                } label: {
                    Text("Beginning")
                }
                Entry {
                    Text(
                        heating.endDate.dateValue(),
                        style: .date
                    )
                    .foregroundColor(.secondary)
                } label: {
                    Text("End")
                }
                Entry {
                    Text(heating.heatingFuel.localizedString)
                        .foregroundColor(.secondary)
                } label: {
                    Text("Heating fuel")
                }
                if let districtHeatingSource = heating.districtHeatingSource {
                    Entry {
                        Text(districtHeatingSource.localizedString)
                            .foregroundColor(.secondary)
                    } label: {
                        Text("Heating source")
                    }
                }
            } else if let transportation = self.consumption.transportation {
                Entry {
                    Text(
                        transportation.dateOfTravel.dateValue(),
                        format: .dateTime
                    )
                    .foregroundColor(.secondary)
                } label: {
                    Text("Start of travel")
                }
                if let dateOfTravelEnd = transportation.dateOfTravelEnd {
                    Entry {
                        Text(
                            dateOfTravelEnd.dateValue(),
                            format: .dateTime
                        )
                        .foregroundColor(.secondary)
                    } label: {
                        Text("End of travel")
                    }
                }
                Entry {
                    Text(transportation.transportationType.localizedString)
                        .foregroundColor(.secondary)
                } label: {
                    Text("Transportation type")
                }
                if let privateVehicleOccupancy = transportation.privateVehicleOccupancy {
                    Entry {
                        Text(String(privateVehicleOccupancy))
                            .foregroundColor(.secondary)
                    } label: {
                        Text("Occupancy")
                    }
                } else if let publicVehicleOccupancy = transportation.publicVehicleOccupancy {
                    Entry {
                        Text(publicVehicleOccupancy.localizedString)
                            .foregroundColor(.secondary)
                    } label: {
                        Text("Occupancy")
                    }
                }
                if let fuelConsumption = transportation.fuelConsumption {
                    let canDeclarePrivatePowerConsumption = transportation
                        .transportationType
                        .canDeclarePrivatePowerConsumption
                    Entry {
                        Text(
                            ConsumptionMeasurement(
                                value: fuelConsumption,
                                unit: canDeclarePrivatePowerConsumption ? .kilowattHoursPer100Kilometers : .litersPer100Kilometers
                            )
                            .converted(to: .init(locale: self.locale))
                            .formatted()
                        )
                        .foregroundColor(.secondary)
                    } label: {
                        Text(
                            canDeclarePrivatePowerConsumption ? "Power consumption" : "Fuel consumption"
                        )
                    }
                }
            }
            if let description = self.consumption.description {
                Section {
                    Text(
                        verbatim: description
                    )
                    .multilineTextAlignment(.leading)
                }
            }
            if let createdAt = self.consumption.createdAt {
                Section(
                    footer: Group {
                        if self.consumption.generatedByRecurringConsumptionId != nil {
                            Text("This entry was automatically added via recurring consumptions.")
                                .multilineTextAlignment(.leading)
                        }
                    }
                ) {
                    Entry {
                        Text(
                            createdAt.dateValue(),
                            style: .date
                        )
                        .foregroundColor(.secondary)
                    } label: {
                        Text("Created")
                    }
                    if let updatedAt = self.consumption.updatedAt {
                        Entry {
                            Text(
                                updatedAt.dateValue(),
                                style: .date
                            )
                            .foregroundColor(.secondary)
                        } label: {
                            Text("Updated")
                        }
                    }
                }
            }
            Section {
                Button {
                    self.consumptionFormSheetMode = .duplicate
                } label: {
                    Label("Duplicate", systemImage: "doc.on.doc.fill")
                }
            }
        }
        .navigationTitle(self.consumption.category.localizedString)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.consumptionFormSheetMode = .edit
                } label: {
                    Label(
                        "Edit",
                        systemImage: "square.and.pencil"
                    )
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    self.isDeleteConfirmationDialogPresented = true
                } label: {
                    Label(
                        "Delete",
                        systemImage: "trash"
                    )
                    .foregroundColor(.red)
                }
                .confirmationDialog(
                    "Delete Entry",
                    isPresented: self.$isDeleteConfirmationDialogPresented,
                    actions: {
                        Button(role: .destructive) {
                            try? self.firebase
                                .firestore
                                .delete(
                                    self.consumption,
                                    context: .current()
                                )
                            self.dismiss()
                        } label: {
                            Text("Delete")
                        }
                        Button(role: .cancel) {
                        } label: {
                            Text("Cancel")
                        }
                    },
                    message: {
                        Text("Are you sure you want to delete the entry?")
                    }
                )
            }
        }
        .sheet(
            item: self.$consumptionFormSheetMode
        ) { consumptionFormSheetMode in
            SheetNavigationView {
                ConsumptionForm(
                    mode: {
                        switch consumptionFormSheetMode {
                        case .edit:
                            return .edit(self.consumption)
                        case .duplicate:
                            return .prefill(self.consumption)
                        }
                    }()
                )
            }
        }
    }
    
}

// MARK: - Entry

private extension ConsumptionView {
    
    /// A ConsumptionView Entry
    struct Entry<Label: View, Content: View>: View {
        
        // MARK: Properties
        
        /// A ViewBuilder closure providing the content.
        @ViewBuilder
        let content: () -> Content
        
        /// A ViewBuilder closure providing the label.
        @ViewBuilder
        let label: () -> Label
        
        // MARK: View
        
        /// The content and behavior of the view.
        var body: some View {
            HStack {
                self.label()
                Spacer()
                self.content()
            }
        }
        
    }
    
}
