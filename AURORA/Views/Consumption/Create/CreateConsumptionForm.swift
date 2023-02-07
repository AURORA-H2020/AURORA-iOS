import SwiftUI

// MARK: - CreateConsumptionForm

/// The CreateConsumptionForm
struct CreateConsumptionForm {
    
    /// The Consumption Category
    @State
    var category: Consumption.Category?
    
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
    
    /// The DismissAction
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - Consumption

private extension CreateConsumptionForm {
    
    /// The Consumption, if available.
    var consumption: Consumption? {
        get throws {
            guard let category = self.category,
                  let value = self.value else {
                return nil
            }
            return .init(
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
                carbonEmissions: nil
            )
        }
    }
    
}

// MARK: - Submit

private extension CreateConsumptionForm {
    
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
            // Add consumption
            try self.firebase
                .firestore
                .add(
                    consumption,
                    context: .current()
                )
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

private extension CreateConsumptionForm {
    
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
            self.partialElectricity.startDate = .init(date: startDate)
            self.partialElectricity.endDate = .init(date: startDate.addingTimeInterval(172800))
        case .heating:
            let startDate = Date()
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

extension CreateConsumptionForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            if let category = self.category {
                self.content(for: category)
            } else {
                self.initialCategoryPicker
            }
        }
        .navigationTitle("Add Consumption")
        .onChange(
            of: self.category,
            perform: self.categoryDidChange
        )
        .animation(
            .default,
            value: self.category
        )
    }
    
}

// MARK: - Initial Category Picker

private extension CreateConsumptionForm {
    
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

private extension CreateConsumptionForm {
    
    /// The content for a given category
    /// - Parameter category: A Consumption Category
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(
        for category: Consumption.Category
    ) -> some View {
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
            .padding(.vertical, 15)
        ) {
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
