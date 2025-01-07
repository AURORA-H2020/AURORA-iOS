import SwiftUI

// MARK: - PhotovoltaicPlantInvestmentForm

/// The PhotovoltaicPlantInvestmentForm
struct PhotovoltaicPlantInvestmentForm {
    
    // MARK: Properties
    
    /// The mode.
    private let mode: Mode
    
    /// The photovoltaic plant.
    @State
    private var photovoltaicPlant: Result<PhotovoltaicPlant?, Error>?
    
    /// The share.
    @State
    private var share: Double?
    
    /// The date.
    @State
    private var date: Date
    
    /// The note.
    @State
    private var note: String
    
    /// Bool value if delete confirmation dialog is presented
    @State
    private var isDeleteConfirmationDialogPresented = false
    
    /// The dismiss action.
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of ``PhotovoltaicPlantInvestmentForm``
    /// - Parameters:
    ///   - mode: The mode.
    ///   - photovoltaicPlant: The photovoltaic plant.
    init(
        mode: Mode
    ) {
        self.mode = mode
        switch mode {
        case .create(let photovoltaicPlant):
            self._photovoltaicPlant = .init(initialValue: .success(photovoltaicPlant))
            self._date = .init(initialValue: .init())
            self._note = .init(initialValue: .init())
        case .edit(let photovoltaicPlantInvestment, let photovoltaicPlant):
            if let photovoltaicPlant {
                self._photovoltaicPlant = .init(initialValue: .success(photovoltaicPlant))
            }
            self._share = .init(initialValue: photovoltaicPlantInvestment.share)
            self._date = .init(initialValue: photovoltaicPlantInvestment.investmentDate.dateValue())
            self._note = .init(initialValue: photovoltaicPlantInvestment.note ?? .init())
        }
    }
    
}

// MARK: - Submit

private extension PhotovoltaicPlantInvestmentForm {
    
    /// Boolean value indicating whether the form can be submitted.
    var canSubmit: Bool {
        self.share != nil
    }
    
    /// A submission error.
    struct SubmissionError: Error {}
    
    /// Submit form.
    func submit() throws {
        // Verify the share and required values are available
        guard let share = self.share,
              let city = try? self.firebase.city?.get(),
              let cityEntityReference = FirestoreEntityReference(city),
              let photovoltaicPlantEntityReference = try? self.photovoltaicPlant?.get().flatMap(FirestoreEntityReference.init) else {
            throw SubmissionError()
        }
        // Add/Update investment
        try self.firebase
            .firestore
            .update(
                PhotovoltaicPlantInvestment(
                    updatedAt: .init(),
                    city: cityEntityReference,
                    pvPlant: photovoltaicPlantEntityReference,
                    share: share,
                    investmentDate: .init(date: self.date),
                    note: self.note.isEmpty ? nil : self.note
                ),
                context: .current()
            )
    }
    
}

// MARK: - View

extension PhotovoltaicPlantInvestmentForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
            } header: {
                Label {
                    Text("Important!")
                } icon: {
                    Image(
                        systemName: "exclamationmark.triangle.fill"
                    )
                    .fontWeight(.regular)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.yellow)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        switch self.mode {
                        case .create:
                            Text("""
                            Entering your investment data is exclussively for recording purposes. This does not formulate an actual investment or binding order in any form.
                            """)
                        case .edit:
                            Text("""
                            If you have made additional investments at a later date, please add a new investment instead. Editing your existing investments may result in inaccurate tracking. 
                            """)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    if case .create = self.mode,
                       let photovoltaicPlant = try? self.photovoltaicPlant?.get(),
                       let infoURL = photovoltaicPlant.infoURL.flatMap(URL.init) {
                        Button(destination: infoURL) {
                            Label(
                                "How to invest?",
                                systemImage: "arrow.up.forward.square"
                            )
                            .font(.footnote)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.accentColor)
                        .align(.centerHorizontal)
                    }
                }
                
            }
            .headerProminence(.increased)
            Section {
                NumberTextField("Shares", value: self.$share)
            } header: {
                Text("Shares")
            } footer: {
                VStack(alignment: .leading) {
                    Text("""
                    How much of the solar panel installation's capacity your investment corresponds to.
                    You should find this information in the documents you received when you made your investment.
                    """)
                    
                    if let photovoltaicPlant = try? self.photovoltaicPlant?.get(),
                       let kwPerShare = photovoltaicPlant.kwPerShare.flatMap({ Measurement<UnitPower>(value: $0, unit: .kilowatts) }),
                       let pricePerShare = photovoltaicPlant.pricePerShare,
                       let country = try? self.firebase.country?.get() {
                        Text(
                            "1 Share = \(kwPerShare.formatted(.measurement(width: .abbreviated, usage: .asProvided))) (\(pricePerShare.formatted(.currency(code: country.currencyCode))))"
                        )
                        .bold()
                    }
                }
                .multilineTextAlignment(.leading)
            }
            .headerProminence(.increased)
            Section {
                DatePicker(
                    "Investment Date",
                    selection: self.$date,
                    in: ...Date(),
                    displayedComponents: .date
                )
            } header: {
                Text("Investment Date")
            } footer: {
                Text("The day you made the investment on.")
            }
            .headerProminence(.increased)
            Section {
                TextField(
                    "Note",
                    text: self.$note,
                    axis: .vertical
                )
            } header: {
                Text("Note")
            } footer: {
                Text("Add a note to your investment for personal reference.")
            }
            .headerProminence(.increased)
            Section {
            } footer: {
                VStack(spacing: 16) {
                    AsyncButton(
                        fillWidth: true,
                        alert: { result in
                            guard case .failure = result else {
                                return nil
                            }
                            return .init(
                                title: Text("Error"),
                                message: Text(
                                    "An error occurred while trying to save your investment. Please try again."
                                )
                            )
                        },
                        action: {
                            try self.submit()
                            self.dismiss()
                        },
                        label: {
                            Text("Save")
                                .font(.headline)
                        }
                    )
                    .disabled(!self.canSubmit)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    NetworkPathReader
                        .unsatisfiedWarning
                        .multilineTextAlignment(.center)
                }
                .align(.centerHorizontal)
            }
        }
        .navigationTitle(
            self.mode.isCreate ? "Add Investment" : "Edit Investment"
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if case .edit(let photovoltaicPlantInvestment, _) = self.mode {
                    Button(role: .destructive) {
                        self.isDeleteConfirmationDialogPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .confirmationDialog(
                        "Delete Investment",
                        isPresented: self.$isDeleteConfirmationDialogPresented,
                        actions: {
                            Button(role: .destructive) {
                                try? self.firebase
                                    .firestore
                                    .delete(
                                        photovoltaicPlantInvestment,
                                        context: .current()
                                    )
                                self.dismiss()
                            } label: {
                                Text("Delete")
                            }
                            Button(role: .cancel) {
                            } label: {
                                Text("Cancel")
                            }
                        },
                        message: {
                            Text("Are you sure you want to delete the investment?")
                        }
                    )
                }
            }
        }
        .onReceive(
            self.firebase
                .firestore
                .publisher(
                    PhotovoltaicPlant.self,
                    id: {
                        switch self.mode {
                        case .create(let photovoltaicPlant):
                            return photovoltaicPlant.id ?? .init()
                        case .edit(let photovoltaicPlantInvestment, _):
                            return photovoltaicPlantInvestment.pvPlant.id
                        }
                    }()
                )
        ) { photovoltaicPlant in
            self.photovoltaicPlant = {
                switch photovoltaicPlant {
                case .success(let photovoltaicPlant):
                    return .success(photovoltaicPlant ?? self.mode.photovoltaicPlant)
                case .failure(let error):
                    if let photovoltaicPlant = self.mode.photovoltaicPlant {
                        return .success(photovoltaicPlant)
                    } else {
                        return .failure(error)
                    }
                }
            }()
        }
    }
    
}
