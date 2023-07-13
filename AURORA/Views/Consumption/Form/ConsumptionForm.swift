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
    
    /// Creates a new instance of `ConsumptionForm`
    /// - Parameter mode: The mode. Default value `.create()`
    init(
        mode: Mode = .create()
    ) {
        switch mode {
        case .create(let category):
            self.consumptionId = nil
            self._category = .init(initialValue: category)
        case .edit(let consumption), .prefill(let consumption):
            self.consumptionId = mode.isEdit ? consumption.id : nil
            self._category = .init(initialValue: consumption.category)
            self._value = .init(initialValue: consumption.value)
            if let electricity = consumption.electricity {
                self._partialElectricity = .init(
                    initialValue: {
                        var partial = electricity.partial
                        if !mode.isEdit {
                            partial.removeValue(for: \.startDate)
                            partial.removeValue(for: \.endDate)
                        }
                        return partial
                    }()
                )
            }
            if let heating = consumption.heating {
                self._partialHeating = .init(
                    initialValue: {
                        var partial = heating.partial
                        if !mode.isEdit {
                            partial.removeValue(for: \.startDate)
                            partial.removeValue(for: \.endDate)
                        }
                        return partial
                    }()
                )
            }
            if let transportation = consumption.transportation {
                self._partialTransportation = .init(
                    initialValue: {
                        var partial = transportation.partial
                        if !mode.isEdit {
                            partial.removeValue(for: \.dateOfTravel)
                        }
                        return partial
                    }()
                )
            }
            if let description = consumption.description {
                self._description = .init(initialValue: description)
            }
        }
    }
    
}

// MARK: - ConsumptionForm+Mode

extension ConsumptionForm {
    
    /// A consumption form mode
    enum Mode: Hashable {
        /// Create
        case create(Consumption.Category? = nil)
        /// Edit
        case edit(Consumption)
        /// Prefill
        case prefill(Consumption)
        
        /// Bool value if mode is set to edit
        var isEdit: Bool {
            if case .edit = self {
                return true
            } else {
                return false
            }
        }
    }
    
}

// MARK: - ConsumptionForm+preferredDatePickerRange

extension ConsumptionForm {
    
    /// The preferred DatePicker range.
    static let preferredDatePickerRange: ClosedRange<Date> = {
        let currentDate = Date()
        let calendar = Calendar.current
        let yearExpansionFactor: Int = 30
        lazy var oneYearInSeconds: TimeInterval = 60 * 60 * 24 * 365
        let minimumDate = calendar.date(
            byAdding: .year,
            value: -yearExpansionFactor,
            to: currentDate
        )
        ??
        currentDate.addingTimeInterval(-(oneYearInSeconds * .init(yearExpansionFactor)))
        let maximumDate = calendar.date(
            byAdding: .year,
            value: yearExpansionFactor,
            to: currentDate
        )
        ??
        currentDate.addingTimeInterval(oneYearInSeconds * .init(yearExpansionFactor))
        return minimumDate...maximumDate
    }()
    
}

// MARK: - Consumption

private extension ConsumptionForm {
    
    /// The Consumption, if available.
    var consumption: Consumption? {
        get throws {
            // Verify category and value are available
            guard let category = self.category,
                  let value = self.value else {
                // Otherwise return nil
                return nil
            }
            // Verify description count is less than 2000 characters
            guard self.description.count <= 2000 else {
                // Otherwise return nil
                return nil
            }
            // Verify fractional decimal digits of the value is equal or less than two
            // and less than 100000
            guard value <= 100000 && max(-Decimal(value).exponent, 0) <= 2 else {
                // Otherwise return nil
                return nil
            }
            // Check if costs is greater 100000
            if let costs = (self.partialElectricity.costs ?? self.partialHeating.costs).flatMap({ $0 }),
               costs > 100000 {
                // Return nil
                return nil
            }
            // Try to initialize consumption
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
                    .accessibilityIdentifier("add"+category.rawValue)
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
