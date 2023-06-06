import SwiftUI

// MARK: - ConsumptionView

/// The ConsumptionView
struct ConsumptionView {
    
    /// The Consumption
    let consumption: Consumption
    
    /// Bool value if consumption form is presented
    @State
    private var isConsumptionFormPresented = false
    
    /// Bool value if delete confirmation dialog is presented
    @State
    private var isDeleteConfirmationDialogPresented = false
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension ConsumptionView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                Entry {
                    Text(self.consumption.formattedValue)
                } label: {
                    Text(self.consumption.category.localizedString)
                }
                if let formattedCarbonEmissions = self.consumption
                    .carbonEmissions?
                    .formatted(.carbonEmissions) {
                    Entry {
                        Text(formattedCarbonEmissions)
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
                        style: .date
                    )
                    .foregroundColor(.secondary)
                } label: {
                    Text("Start of travel")
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
        }
        .navigationTitle(self.consumption.category.localizedString)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isConsumptionFormPresented = true
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
            isPresented: self.$isConsumptionFormPresented
        ) {
            SheetNavigationView {
                ConsumptionForm(
                    consumption: self.consumption
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
