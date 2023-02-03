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
        guard let category = self.category,
              let value = self.value else {
            return nil
        }
        do {
            switch category {
            case .electricity:
                return .init(
                    category: category,
                    electricity: try .init(
                        costs: self.partialElectricity(\.costs),
                        startDate: self.partialElectricity(\.startDate),
                        endDate: self.partialElectricity(\.endDate)
                    ),
                    value: value,
                    carbonEmissions: nil
                )
            case .heating:
                return .init(
                    category: category,
                    heating: try .init(
                        costs: self.partialHeating(\.costs),
                        startDate: self.partialHeating(\.startDate),
                        endDate: self.partialHeating(\.endDate)
                    ),
                    value: value,
                    carbonEmissions: nil
                )
            case .transportation:
                return .init(
                    category: category,
                    transportation: .init(
                        dateOfTravel: try self.partialTransportation(\.dateOfTravel),
                        transportationType: self.partialTransportation
                            .transportationType?
                            .flatMap { $0 },
                        privateVehicleOccupancy: self.partialTransportation
                            .privateVehicleOccupancy?
                            .flatMap { $0 },
                        publicVehicleOccupancy: self.partialTransportation
                            .publicVehicleOccupancy?
                            .flatMap { $0 }
                    ),
                    value: value,
                    carbonEmissions: nil
                )
            }
        } catch {
            return nil
        }
    }
    
}

// MARK: - Submit

private extension CreateConsumptionForm {
    
    /// Submit form
    func submit() throws {
        // Verify a consumption is available
        guard let consumption = self.consumption else {
            // Otherwise return out of function
            return
        }
        // Add consumption
        try self.firebase
            .firestore
            .add(
                consumption,
                context: .current()
            )
        // Dismiss
        self.dismiss()
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
            of: self.category
        ) { category in
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
        .animation(
            .default,
            value: self.category
        )
    }
    
}

private extension CreateConsumptionForm {
    
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
        ) {
        }
        .headerProminence(.increased)
    }
    
}

private extension CreateConsumptionForm {
    
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
                self.electricityContent
            case .heating:
                self.heatingContent
            case .transportation:
                self.transportationContent
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
            .disabled(self.consumption == nil)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .align(.centerHorizontal)
        ) {
        }
    }
    
}

private extension CreateConsumptionForm {
    
    @ViewBuilder
    var electricityContent: some View {
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
            Text("€")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        HStack {
            NumberTextField(
                "Consumption",
                value: self.$value
            )
            Text("kwH")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
}

private extension CreateConsumptionForm {
    
    @ViewBuilder
    var heatingContent: some View {
        DatePicker(
            "Start",
            selection: .init(
                get: {
                    self.partialHeating.startDate?.dateValue() ?? .init()
                },
                set: { newValue in
                    self.partialHeating.startDate = .init(date: newValue)
                }
            ),
            displayedComponents: [.date]
        )
        DatePicker(
            "End",
            selection: .init(
                get: {
                    self.partialHeating.endDate?.dateValue() ?? .init()
                },
                set: { newValue in
                    self.partialHeating.endDate = .init(date: newValue)
                }
            ),
            in: (self.partialHeating.startDate?.dateValue() ?? .init())...,
            displayedComponents: [.date]
        )
        HStack {
            NumberTextField(
                "Costs",
                value: self.$partialHeating.costs
            )
            Text("€")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        HStack {
            NumberTextField(
                "Consumption",
                value: self.$value
            )
            Text("kwH")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
}

private extension CreateConsumptionForm {
    
    @ViewBuilder
    var transportationContent: some View {
        DatePicker(
            "Date of travel",
            selection: .init(
                get: {
                    self.partialTransportation.dateOfTravel?.dateValue() ?? .init()
                },
                set: { newValue in
                    self.partialTransportation.dateOfTravel = .init(date: newValue)
                }
            )
        )
        Picker(
            "Type",
            selection: self.$partialTransportation.transportationType
        ) {
            Text("Please choose")
                .tag(nil as Consumption.Transportation.TransportationType??)
            ForEach(
                Consumption.Transportation.TransportationType.allCases,
                id: \.self
            ) { transportationType in
                Text(transportationType.rawValue.capitalized)
                    .tag(transportationType as Consumption.Transportation.TransportationType??)
            }
        }
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
                Text(occupancy.rawValue.capitalized)
                    .tag(occupancy as Consumption.Transportation.PublicVehicleOccupancy??)
            }
        }
        HStack {
            NumberTextField(
                "Distance",
                value: self.$value
            )
            Text("km")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
}
