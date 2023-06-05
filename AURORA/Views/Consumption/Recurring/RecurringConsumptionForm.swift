import SwiftUI

// MARK: - RecurringConsumptionForm

/// The RecurringConsumptionForm
struct RecurringConsumptionForm {
    
    // MARK: Properties
    
    /// The recurring consumption identifier
    private let recurringConsumptionId: RecurringConsumption.ID
    
    /// The consumption category
    @State
    private var category: Consumption.Category = .transportation
    
    /// The partial frequency
    @State
    private var partialFrequency = Partial<RecurringConsumption.Frequency>()
    
    /// The partial transportation
    @State
    private var partialTransportation = Partial<RecurringConsumption.Transportation>()
    
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
        }
        if let frequency = recurringConsumption?.frequency {
            self._partialFrequency = .init(initialValue: frequency.partial)
        }
        if let transporation = recurringConsumption?.transportation {
            self._partialTransportation = .init(initialValue: transporation.partial)
        }
    }
    
}

// MARK: - RecurringConsumption

private extension RecurringConsumptionForm {
    
    /// The recurring consumption, if available.
    var recurringConsumption: RecurringConsumption? {
        get throws {
            return .init(
                id: self.recurringConsumptionId,
                category: self.category,
                frequency: try .init(partial: self.partialFrequency),
                transportation: category == .transportation
                    ? try .init(partial: self.partialTransportation)
                    : nil
            )
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
            Section(
                header: Text("Category")
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
                            .tag(Optional(category))
                    }
                }
                .onChange(
                    of: self.category
                ) { _ in
                    self.partialTransportation.removeAll()
                }
            }
            .headerProminence(.increased)
            Section(
                header: Text("Fequency")
            ) {
                Picker(
                    "Frequency",
                    selection: self.$partialFrequency.unit
                ) {
                    ForEach(
                        RecurringConsumption.Frequency.Unit.allCases,
                        id: \.self
                    ) { unit in
                        Text(unit.localizedString)
                            .tag(Optional(unit))
                    }
                }
                .onChange(
                    of: self.partialFrequency.unit
                ) { _ in
                    self.partialFrequency.removeValue(for: \.value)
                }
                switch self.partialFrequency.unit {
                case nil, .daily:
                    EmptyView()
                case .weekly:
                    Picker(
                        "Weekday",
                        selection: self.$partialFrequency.value
                    ) {
                        ForEach(
                            RecurringConsumption
                                .Frequency
                                .Unit
                                .Weekday
                                .allCases,
                            id: \.self
                        ) { weekday in
                            Text(String(weekday.localizedString))
                                .tag(Optional(Optional(weekday.rawValue)))
                        }
                    }
                case .monthly:
                    Picker(
                        "Day",
                        selection: self.$partialFrequency.value
                    ) {
                        ForEach(1...30, id: \.self) { day in
                            Text(String(day))
                                .tag(Optional(Optional(day)))
                        }
                    }
                }
            }
            .headerProminence(.increased)
            Section(
                header: Text(self.category.localizedString)
            ) {
                switch self.category {
                case .electricity, .heating:
                    EmptyView()
                case .transportation:
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
                                        .tag(Optional(transportationType))
                                }
                            }
                        }
                    }
                    DatePicker(
                        "Time of travel",
                        selection: self.$partialTransportation.timeOfTravel,
                        displayedComponents: .hourAndMinute
                    )
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
            .headerProminence(.increased)
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
