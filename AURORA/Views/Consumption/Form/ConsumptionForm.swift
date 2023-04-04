import SwiftUI

// MARK: - ConsumptionForm

/// The ConsumptionForm
struct ConsumptionForm {
    
    // MARK: Properties
    
    /// The consumption identifier
    private let consumptionId: Consumption.ID
    
    /// The Consumption Category
    @State
    private var category: Consumption.Category?
    
    /// The Partial Consumption Electricity
    @State
    private var partialElectricity = Partial<Consumption.Electricity>()
    
    /// The Partial Consumption Heating
    @State
    private var partialHeating = Partial<Consumption.Heating>()
    
    /// The Partial Consumption Transportation
    @State
    private var partialTransportation = Partial<Consumption.Transportation>()
    
    /// The Consumption value
    @State
    private var value: Double?
    
    /// The description
    @State
    private var description = String()
    
    /// The DismissAction
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `ConsumptionForm` in creation mode.
    /// - Parameter category: The optional consumption category. Default value `nil`
    init(
        category: Consumption.Category? = nil
    ) {
        self.consumptionId = nil
        self._category = .init(initialValue: category)
    }
    
    /// Creates a new instance of `ConsumptionForm` in edit mode.
    /// - Parameter consumption: The consumption to edit.
    init(
        consumption: Consumption
    ) {
        self.consumptionId = consumption.id
        self._category = .init(initialValue: consumption.category)
        self._value = .init(initialValue: consumption.value)
        if let electricity = consumption.electricity {
            self._partialElectricity = .init(initialValue: electricity.partial)
        }
        if let heating = consumption.heating {
            self._partialHeating = .init(initialValue: heating.partial)
        }
        if let transportation = consumption.transportation {
            self._partialTransportation = .init(initialValue: transportation.partial)
        }
        if let description = consumption.description {
            self._description = .init(initialValue: description)
        }
    }
    
}

// MARK: - Consumption

private extension ConsumptionForm {
    
    /// The Consumption, if available.
    var consumption: Consumption? {
        get throws {
            guard let category = self.category,
                  let value = self.value else {
                return nil
            }
            return .init(
                id: self.consumptionId,
                category: category,
                electricity: category == .electricity
                    ? try .init(partial: self.partialElectricity)
                    : nil,
                heating: category == .heating
                    ? try .init(partial: self.partialHeating)
                    : nil,
                transportation: category == .transportation
                    ? try .init(partial: self.partialTransportation)
                    : nil,
                value: value,
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

private extension ConsumptionForm {
    
    /// Submit form
    func submit() throws {
        // Verify a consumption is available
        guard let consumption = try self.consumption else {
            // Otherwise return out of function
            return
        }
        // Initialize an UINotificationFeedbackGenerator
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        do {
            // Check if an identifier is available
            if consumption.id == nil {
                // Add consumption
                try self.firebase
                    .firestore
                    .add(
                        consumption,
                        context: .current()
                    )
            } else {
                // Update consumption
                try self.firebase
                    .firestore
                    .update(
                        consumption,
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

// MARK: - Category did change

private extension ConsumptionForm {
    
    /// Category did change
    /// - Parameter category: The new Consumption Category
    func categoryDidChange(
        _ category: Consumption.Category?
    ) {
        self.partialElectricity.removeAll()
        self.partialHeating.removeAll()
        self.partialTransportation.removeAll()
        self.value = nil
        switch category {
        case .electricity:
            let startDate = Date()
            self.partialElectricity.householdSize = 1
            self.partialElectricity.startDate = .init(date: startDate)
            self.partialElectricity.endDate = .init(date: startDate.addingTimeInterval(172800))
        case .heating:
            let startDate = Date()
            self.partialHeating.householdSize = 1
            self.partialHeating.startDate = .init(date: startDate)
            self.partialHeating.endDate = .init(date: startDate.addingTimeInterval(172800))
        case .transportation:
            self.partialTransportation.dateOfTravel = .init()
        case nil:
            break
        }
    }
    
}

// MARK: - View

extension ConsumptionForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            if let category = self.category {
                self.content(for: category)
            } else {
                self.initialCategoryPicker
            }
        }
        .navigationTitle(self.consumptionId == nil ? "Add Consumption" : "Edit Consumption")
        .onChange(
            of: self.category,
            perform: self.categoryDidChange
        )
    }
    
}

// MARK: - Initial Category Picker

private extension ConsumptionForm {
    
    /// Initial category picker
    var initialCategoryPicker: some View {
        Section(
            header: VStack {
                ForEach(
                    Consumption.Category.allCases,
                    id: \.self
                ) { category in
                    Button {
                        self.category = category
                    } label: {
                        HStack {
                            category.icon
                            Text(category.localizedString)
                        }
                        .font(.headline)
                        .align(.centerHorizontal)
                    }
                    .buttonStyle(.bordered)
                    .tint(category.tintColor)
                    .controlSize(.large)
                }
            }
            .padding(.top, 30)
        ) {
        }
        .headerProminence(.increased)
        .listRowInsets(.init())
    }
    
}

// MARK: - Content

private extension ConsumptionForm {
    
    /// The content for a given category
    /// - Parameter category: A Consumption Category
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(
        for category: Consumption.Category
    ) -> some View {
        if self.consumptionId == nil {
            Section(
                header: Menu {
                    ForEach(
                        Consumption
                            .Category
                            .allCases
                            .filter { $0 != category },
                        id: \.self
                    ) { category in
                        Button {
                            self.category = category
                        } label: {
                            Label {
                                Text(category.localizedString)
                            } icon: {
                                category.icon
                            }
                        }
                    }
                } label: {
                    HStack {
                        category.icon
                        Text(category.localizedString)
                            .fontWeight(.semibold)
                        Image(
                            systemName: "chevron.up.chevron.down"
                        )
                        .imageScale(.small)
                    }
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(category.tintColor)
                .controlSize(.regular)
                .align(.centerHorizontal)
                .padding(.top, 15)
            ) {
            }
            .headerProminence(.increased)
        }
        switch category {
        case .electricity:
            Electricity(
                partialElectricity: self.$partialElectricity,
                value: self.$value
            )
        case .heating:
            Heating(
                partialHeating: self.$partialHeating,
                value: self.$value
            )
        case .transportation:
            Transportation(
                partialTransportation: self.$partialTransportation,
                value: self.$value
            )
        }
        Section(
            header: Text("Description"),
            footer: Text("Add an optional description to your entry.")
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
                            "An error occurred while trying to save your consumption. Please try again."
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
            .disabled((try? self.consumption) == nil)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .align(.centerHorizontal)
        ) {
        }
    }
    
}