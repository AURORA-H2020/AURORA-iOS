import SwiftUI

// MARK: - RecurringConsumptionForm

/// The RecurringConsumptionForm
struct RecurringConsumptionForm {
    
    // MARK: Properties
    
    /// The mode
    private let mode: Mode
    
    /// Bool value if is enabled
    @State
    private var isEnabled: Bool
    
    /// The consumption category
    @State
    private var category: Consumption.Category
    
    /// The partial frequency
    @State
    private var partialFrequency: Partial<RecurringConsumption.Frequency>
    
    /// The partial transportation
    @State
    private var partialTransportation: Partial<RecurringConsumption.Transportation>
    
    /// The description
    @State
    private var description: String
    
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
    /// - Parameter mode: The recurring consumption form mode. Default value `.create`
    init(
        mode: Mode = .create
    ) {
        self.mode = mode
        self._isEnabled = .init(
            initialValue: mode.editableRecurringConsumption?.isEnabled ?? true
        )
        self._category = .init(
            initialValue: mode.editableRecurringConsumption?.category ?? .transportation
        )
        self._partialFrequency = .init(
            initialValue: mode.editableRecurringConsumption?.frequency.partial ?? [\.unit: RecurringConsumption.Frequency.Unit.daily]
        )
        self._partialTransportation = .init(
            initialValue: mode.editableRecurringConsumption?.transportation?.partial ?? .default()
        )
        self._description = .init(
            initialValue: mode.editableRecurringConsumption?.description ?? .init()
        )
    }
    
}

// MARK: - Mode

extension RecurringConsumptionForm {
    
    /// A recurring consumption form mode
    enum Mode: Hashable, Identifiable {
        /// Create
        case create
        /// Edit
        case edit(RecurringConsumption)
        
        /// The stable identity of the entity associated with this instance.
        var id: String {
            switch self {
            case .create:
                return "create"
            case .edit(let recurringConsumption):
                return [
                    "edit",
                    recurringConsumption.id
                ]
                .compactMap { $0 }
                .joined(separator: "-")
            }
        }
        
        /// Bool if mode is create.
        var isCreate: Bool {
            if case .create = self {
                return true
            } else {
                return false
            }
        }
        
        /// The editable recurring consumption, available if mode is edit.
        var editableRecurringConsumption: RecurringConsumption? {
            switch self {
            case .create:
                return nil
            case .edit(let recurringConsumption):
                return recurringConsumption
            }
        }
    }
    
}

// MARK: - RecurringConsumption

private extension RecurringConsumptionForm {
    
    /// The recurring consumption, if available.
    var recurringConsumption: RecurringConsumption? {
        get throws {
            .init(
                id: self.mode.editableRecurringConsumption?.id,
                createdAt: self.mode.editableRecurringConsumption?.createdAt,
                isEnabled: self.isEnabled,
                category: self.category,
                frequency: try .init(partial: self.partialFrequency),
                transportation: category == .transportation
                    ? try .init(partial: self.partialTransportation)
                    : nil,
                description: {
                    let description = self.description
                        .trimmingCharacters(in: .whitespaces)
                    return description.isEmpty ? nil : description
                }()
            )
        }
    }
    
}

// MARK: - Submit

private extension RecurringConsumptionForm {
    
    /// Bool value if form can be submitted
    var canSubmit: Bool {
        // Verify recurring consumption is available
        guard let recurringConsumption = try? self.recurringConsumption else {
            // Otherwise submit is not possible
            return false
        }
        switch self.mode {
        case .create:
            // Return true as submitting is available
            return true
        case .edit(let editableRecurringConsumption):
            // Submit is possible if the recurring consumption
            // is not equal to the editable recurring consumption
            return recurringConsumption != editableRecurringConsumption
        }
    }
    
    /// Submit form
    func submit() throws {
        // Verify an edited recurring consumption is available
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
            self.enabledStateSection
            self.categorySection
            self.frequencySection
            self.categoryContentSection
            self.descriptionSection
            self.submitSection
        }
        .navigationTitle(self.mode.isCreate ? "Add" : "Edit")
        .toolbar {
            self.toolbarContent
        }
        .interactiveDismissDisabled(self.canSubmit)
    }
    
}

// MARK: - Toolbar Content

private extension RecurringConsumptionForm {
    
    /// The toolbar content
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if let recurringConsumption = self.mode.editableRecurringConsumption {
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
        ToolbarItem(placement: .navigationBarLeading) {
            if self.canSubmit {
                AsyncButton(
                    confirmationDialog: { action in
                        .init(
                            title: Text("Unsaved changes"),
                            message: Text("Are you sure you want to discard your unsaved changes?"),
                            buttons: [
                                .default(
                                    Text("Save changes"),
                                    action: action
                                ),
                                .destructive(
                                    Text("Discard changes")
                                ) {
                                    self.dismiss()
                                },
                                .cancel()
                            ]
                        )
                    },
                    alert: { result in
                        guard case .failure = result else {
                            return nil
                        }
                        return .init(
                            title: Text("Error"),
                            message: Text(
                                "An error occurred while trying to save your recurring consumption."
                            ),
                            primaryButton: .default(
                                Text("Retry")
                            ),
                            secondaryButton: .default(
                                Text("Quit")
                            ) {
                                self.dismiss()
                            }
                        )
                    },
                    action: {
                        try self.submit()
                    },
                    label: {
                        Image(
                            systemName: "xmark.circle.fill"
                        )
                        .foregroundColor(.secondary)
                    }
                )
            } else {
                Button {
                    self.dismiss()
                } label: {
                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
}

// MARK: - Enabled State Section

private extension RecurringConsumptionForm {
    
    /// The enabled state section
    @ViewBuilder
    var enabledStateSection: some View {
        if !self.mode.isCreate {
            Section {
                Toggle(isOn: self.$isEnabled) {
                    Text(self.isEnabled ? "Enabled" : "Disabled")
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

// MARK: - Description Section

private extension RecurringConsumptionForm {
    
    /// The description section
    var descriptionSection: some View {
        Section(
            header: Text("Description"),
            footer: Text("You may add a description to your entry to help you find it later.")
        ) {
            if #available(iOS 16.0, *) {
                TextField(
                    "Description",
                    text: self.$description,
                    axis: .vertical
                )
            } else {
                TextField(
                    "Description",
                    text: self.$description
                )
            }
        }
        .headerProminence(.increased)
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
            .disabled(!self.canSubmit)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .align(.centerHorizontal)
        ) {
        }
    }
    
}
