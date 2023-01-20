import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - AddConsumptionForm

/// The AddConsumptionForm
struct AddConsumptionForm {
    
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
                context: self.firebase
                    .authentication
                    .userId
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
            Picker(
                "Category",
                selection: self.$category
            ) {
                Text(
                    verbatim: "Please choose"
                )
                .tag(Optional<Consumption.Category>.none)
                ForEach(
                    Consumption.Category.allCases,
                    id: \.self
                ) { category in
                    Text(
                        verbatim: category.rawValue.capitalized
                    )
                    .tag(category as Consumption.Category?)
                }
            }
            self.category.flatMap(self.content)
        }
        .navigationTitle("Add Consumption")
        .onChange(
            of: self.category
        ) { _ in
            self.partialElectricity.removeAll()
            self.partialHeating.removeAll()
            self.partialTransportation.removeAll()
            self.value = nil
        }
    }
    
}

private extension AddConsumptionForm {
    
    @ViewBuilder
    func content(
        for category: Consumption.Category
    ) -> some View {
        switch category {
        case .electricity:
            self.electricityContent
        case .heating:
            self.heatingContent
        case .transportation:
            self.transportationContent
        }
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
    
    var electricityContent: some View {
        Section(
            header: Text(verbatim: "Electricity")
        ) {
        }
        .headerProminence(.increased)
    }
    
}

private extension AddConsumptionForm {
    
    var heatingContent: some View {
        Section(
            header: Text(verbatim: "Heating")
        ) {
        }
        .headerProminence(.increased)
    }
    
}

private extension AddConsumptionForm {
    
    var transportationContent: some View {
        Section(
            header: Text(verbatim: "Transportation")
        ) {
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
            .onAppear {
                guard self.partialTransportation.dateOfTravel == nil else {
                    return
                }
                self.partialTransportation.dateOfTravel = .init()
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
                number: self.$value
            )
        }
        .headerProminence(.increased)
    }
    
}
