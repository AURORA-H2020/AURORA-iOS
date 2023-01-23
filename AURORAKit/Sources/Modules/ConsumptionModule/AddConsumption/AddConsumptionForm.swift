import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - AddConsumptionForm

/// The AddConsumptionForm
struct AddConsumptionForm {
    
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

private extension AddConsumptionForm {
    
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
                    value: value
                )
            case .heating:
                return .init(
                    category: category,
                    heating: try .init(
                        costs: self.partialHeating(\.costs),
                        startDate: self.partialHeating(\.startDate),
                        endDate: self.partialHeating(\.endDate)
                    ),
                    value: value
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
                    value: value
                )
            }
        } catch {
            return nil
        }
    }
    
}

// MARK: - Submit

private extension AddConsumptionForm {
    
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

extension AddConsumptionForm: View {
    
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

private extension AddConsumptionForm {
    
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
                            Text(
                                verbatim: category.localizedString
                            )
                        }
                        .font(.headline)
                        .align(.centerHorizontal)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .controlSize(.large)
                }
            }
        ) {
        }
        .headerProminence(.increased)
    }
    
}

private extension AddConsumptionForm {
    
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func content(
        for category: Consumption.Category
    ) -> some View {
        Section(
            header: HStack {
                Text(
                    verbatim: category.localizedString
                )
                Spacer()
                Menu {
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
                            Text(
                                verbatim: category.localizedString
                            )
                        }

                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(
                            verbatim: "Change"
                        )
                        Image(
                            systemName: "chevron.up.chevron.down"
                        )
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .buttonBorderShape(.capsule)
            }
            .padding(.vertical, 8)
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
                isAutoProgressViewEnabled: false,
                alert: { result in
                    guard case .failure = result else {
                        return nil
                    }
                    return .init(
                        title: .init(
                            verbatim: "Error"
                        ),
                        message: .init(
                            verbatim: "An error occurred while trying to save your consumption. Please try again."
                        )
                    )
                },
                action: {
                    try self.submit()
                },
                label: {
                    Text(
                        verbatim: "Save"
                    )
                    .font(.headline)
                    .align(.centerHorizontal)
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

private extension AddConsumptionForm {
    
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
        NumberTextField(
            "Costs",
            number: self.$partialElectricity.costs,
            unitSymbol: "€"
        )
        NumberTextField(
            "Consumption",
            number: self.$value,
            unitSymbol: "kWh"
        )
    }
    
}

private extension AddConsumptionForm {
    
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
        NumberTextField(
            "Costs",
            number: self.$partialHeating.costs,
            unitSymbol: "€"
        )
        NumberTextField(
            "Consumption",
            number: self.$value,
            unitSymbol: "kWh"
        )
    }
    
}

private extension AddConsumptionForm {
    
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
            Text(
                verbatim: "Please choose"
            )
            .tag(nil as Consumption.Transportation.TransportationType??)
            ForEach(
                Consumption.Transportation.TransportationType.allCases,
                id: \.self
            ) { transportationType in
                Text(
                    verbatim: transportationType.rawValue.capitalized
                )
                .tag(transportationType as Consumption.Transportation.TransportationType??)
            }
        }
        Picker(
            "Occupancy",
            selection: self.$partialTransportation.publicVehicleOccupancy
        ) {
            Text(
                verbatim: "Please choose"
            )
            .tag(nil as Consumption.Transportation.PublicVehicleOccupancy??)
            ForEach(
                Consumption.Transportation.PublicVehicleOccupancy.allCases,
                id: \.self
            ) { occupancy in
                Text(
                    verbatim: occupancy.rawValue.capitalized
                )
                .tag(occupancy as Consumption.Transportation.PublicVehicleOccupancy??)
            }
        }
        NumberTextField(
            "Distance",
            number: self.$value,
            unitSymbol: "km"
        )
    }
    
}

private extension Consumption.Category {
    
    var localizedString: String {
        switch self {
        case .electricity:
            return "Electricity"
        case .heating:
            return "Heating"
        case .transportation:
            return "Transportation"
        }
    }
    
}

private extension Consumption.Category {
    
    var icon: Image {
        .init(
            systemName: {
                switch self {
                case .electricity:
                    return "bolt"
                case .heating:
                    return "heater.vertical"
                case .transportation:
                    return "car"
                }
            }()
        )
    }
    
}
