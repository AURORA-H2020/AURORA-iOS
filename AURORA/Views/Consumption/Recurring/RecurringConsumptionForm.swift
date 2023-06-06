import SwiftUI

// MARK: - RecurringConsumptionForm

/// The RecurringConsumptionForm
struct RecurringConsumptionForm {
    
    // MARK: Properties
    
    /// The recurring consumption identifier
    private let recurringConsumptionId: RecurringConsumption.ID
    
    /// The consumption category
    @State
    private var category: Consumption.Category
    
    /// The partial frequency
    @State
    private var partialFrequency: Partial<RecurringConsumption.Frequency>
    
    /// The partial transportation
    @State
    private var partialTransportation: Partial<RecurringConsumption.Transportation>
    
    /// Bool value if delete confirmation dialog is presented
    @State
    private var isDeleteConfirmationDialogPresented = false
    
    /// The DismissAction
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `RecurringConsumptionForm`
    /// - Parameter recurringConsumption: The optional recurring consumption to edit. Default value `nil`
    init(
        recurringConsumption: RecurringConsumption? = nil
    ) {
        self.recurringConsumptionId = recurringConsumption?.id
        if let category = recurringConsumption?.category {
            self._category = .init(initialValue: category)
        } else {
            self._category = .init(initialValue: .transportation)
        }
        if let frequency = recurringConsumption?.frequency {
            self._partialFrequency = .init(initialValue: frequency.partial)
        } else {
            self._partialFrequency = .init(initialValue: [\.unit: RecurringConsumption.Frequency.Unit.daily])
        }
        if let transporation = recurringConsumption?.transportation {
            self._partialTransportation = .init(initialValue: transporation.partial)
        } else {
            self._partialTransportation = .init(initialValue: .default())
        }
    }
    
}

// MARK: - RecurringConsumption

private extension RecurringConsumptionForm {
    
    /// The recurring consumption, if available.
    var recurringConsumption: RecurringConsumption? {
        get throws {
            do {
                return .init(
                    id: self.recurringConsumptionId,
                    category: self.category,
                    frequency: try .init(partial: self.partialFrequency),
                    transportation: category == .transportation
                        ? try .init(partial: self.partialTransportation)
                        : nil
                )
            } catch {
                print("HERE", error)
                throw error
            }
        }
    }
    
}

// MARK: - Submit

private extension RecurringConsumptionForm {
    
    /// Submit form
    func submit() throws {
        // Verify a recurring consumption is available
        guard let recurringConsumption = try self.recurringConsumption else {
            // Otherwise return out of function
            return
        }
        // Initialize an UINotificationFeedbackGenerator
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        do {
            // Check if an identifier is available
            if recurringConsumption.id == nil {
                // Add recurring consumption
                try self.firebase
                    .firestore
                    .add(
                        recurringConsumption,
                        context: .current()
                    )
            } else {
                // Update recurring consumption
                try self.firebase
                    .firestore
                    .update(
                        recurringConsumption,
                        context: .current()
                    )
            }
        } catch {
            // Invoke error feedback
            notificationFeedbackGenerator
                .notificationOccurred(.error)
            // Rethrow error
            throw error
        }
        // Invoke success feedback
        notificationFeedbackGenerator
            .notificationOccurred(.success)
        // Dismiss
        self.dismiss()
    }
    
}

// MARK: - View

extension RecurringConsumptionForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            self.categorySection
            self.frequencySection
            self.categoryContentSection
            self.submitSection
        }
        .navigationTitle(self.recurringConsumptionId == nil ? "Add" : "Edit")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.recurringConsumptionId != nil,
                   let recurringConsumption = try? self.recurringConsumption {
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
                                        recurringConsumption,
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
        }
    }
    
}

// MARK: - Category Section

private extension RecurringConsumptionForm {
    
    /// The consumption category section
    var categorySection: some View {
        Section(
            header: Text("Category"),
            footer: Group {
                if RecurringConsumption.supportedCategories.count == 1,
                   let supportedCategory = RecurringConsumption.supportedCategories.first {
                    Text(
                        "Only \(supportedCategory.localizedString) is supported as a recurring consumption."
                    )
                    .multilineTextAlignment(.leading)
                }
            }
        ) {
            Picker(
                "Category",
                selection: self.$category
            ) {
                ForEach(
                    Consumption
                        .Category
                        .allCases
                        .filter(RecurringConsumption.supportedCategories.contains),
                    id: \.self
                ) { category in
                    Text(category.localizedString)
                        .tag(category as Consumption.Category?)
                }
            }
            .disabled(RecurringConsumption.supportedCategories.count == 1)
        }
        .headerProminence(.increased)
        .onChange(
            of: self.category
        ) { _ in
            self.partialTransportation = .default()
        }
    }
    
}

// MARK: - Frequency Section

private extension RecurringConsumptionForm {
    
    /// The frequency section
    var frequencySection: some View {
        Section(
            header: Text("Fequency")
        ) {
            Picker(
                "Frequency",
                selection: self.$partialFrequency.unit
            ) {
                ForEach(
                    RecurringConsumption
                        .Frequency
                        .Unit
                        .allCases,
                    id: \.self
                ) { unit in
                    Text(unit.localizedString)
                        .tag(unit as RecurringConsumption.Frequency.Unit?)
                }
            }
            switch self.partialFrequency.unit {
            case nil, .daily:
                EmptyView()
            case .weekly:
                MultiPicker(
                    "Weekdays",
                    RecurringConsumption.Frequency.Weekday.allCases,
                    selection: .init(
                        get: {
                            self.partialFrequency.weekdays.flatMap { $0 } ?? .init()
                        },
                        set: { weekdays in
                            self.partialFrequency.weekdays = weekdays
                        }
                    ),
                    textRepresentation: \.localizedString
                )
            case .monthly:
                Picker(
                    "Day",
                    selection: self.$partialFrequency.dayOfMonth
                ) {
                    ForEach(
                        RecurringConsumption
                            .Frequency
                            .DayOfMonth
                            .allCases,
                        id: \.self
                    ) { dayOfMonth in
                        Text(String(dayOfMonth.value))
                            .tag(dayOfMonth as RecurringConsumption.Frequency.DayOfMonth??)
                    }
                }
            }
        }
        .headerProminence(.increased)
        .onChange(
            of: self.partialFrequency.unit
        ) { unit in
            self.partialFrequency.removeValue(for: \.weekdays)
            self.partialFrequency.removeValue(for: \.dayOfMonth)
            if unit == .monthly {
                self.partialFrequency.dayOfMonth = .first
            }
        }
    }
    
}

// MARK: - Category Content Section

private extension RecurringConsumptionForm {
    
    /// The category content section
    var categoryContentSection: some View {
        Section(
            header: Text(self.category.localizedString)
        ) {
            switch self.category {
            case .electricity, .heating:
                EmptyView()
            case .transportation:
                self.transportationFields
            }
        }
        .headerProminence(.increased)
    }
    
    /// The transportation fields
    @ViewBuilder
    var transportationFields: some View {
        DatePicker(
            "Start of travel",
            selection: self.$partialTransportation.timeOfTravel,
            displayedComponents: .hourAndMinute
        )
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
            self.partialTransportation.privateVehicleOccupancy = transportationType?
                .privateVehicleOccupancyRange != nil ? 1 : nil
        }
        if self.partialTransportation.transportationType?.isPublicVehicle == true {
            Picker(
                "Typical occupancy",
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
                "Typical occupancy: \(self.partialTransportation.privateVehicleOccupancy?.flatMap { $0 } ?? 1)",
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
                value: self.$partialTransportation.distance
            )
            Text(
                verbatim: "km"
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
    
}

// MARK: - Submit Section

private extension RecurringConsumptionForm {
    
    /// The submit section
    var submitSection: some View {
        Section(
            footer: AsyncButton(
                fillWidth: true,
                alert: { result in
                    guard case .failure = result else {
                        return nil
                    }
                    return .init(
                        title: Text("Error"),
                        message: Text(
                            "An error occurred while trying to save your recurring consumption. Please try again."
                        )
                    )
                },
                action: {
                    try self.submit()
                },
                label: {
                    Text("Save")
                        .font(.headline)
                }
            )
            .disabled((try? self.recurringConsumption) == nil)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .align(.centerHorizontal)
        ) {
        }
    }
    
}
