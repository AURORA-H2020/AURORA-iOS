import SwiftUI

// MARK: - PhotovoltaicPlantView+InvestmentSection

extension PhotovoltaicPlantView {
    
    /// The InvestmentSection
    struct InvestmentSection {
        
        /// The photovoltaic plant.
        let photovoltaicPlant: PhotovoltaicPlant
        
        /// The user entity reference.
        let userEntityReference: FirestoreEntityReference<User>
        
        /// The latest photovoltaic plant investment.
        let latestPhotovoltaicPlantInvestment: PhotovoltaicPlantInvestment?
        
        /// The presented photovoltaic plant investment form mode.
        @Binding
        var presentedPhotovoltaicPlantInvestmentFormMode: PhotovoltaicPlantInvestmentForm.Mode?
        
        /// The Firebase instance
        @EnvironmentObject
        private var firebase: Firebase
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.InvestmentSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
            if let latestPhotovoltaicPlantInvestment = self.latestPhotovoltaicPlantInvestment {
                if let investmentPrice = latestPhotovoltaicPlantInvestment.investmentPrice,
                   let country = try? self.firebase.country?.get() {
                    LabeledContent {
                        Text(
                            investmentPrice,
                            format: .currency(code: country.currencyCode)
                        )
                    } label: {
                        Label(
                            "Investment",
                            systemImage: "wallet.bifold"
                        )
                    }
                }
                if let investmentCapacity = latestPhotovoltaicPlantInvestment.investmentCapacity {
                    LabeledContent {
                        Text(
                            Measurement<UnitPower>(
                                value: investmentCapacity,
                                unit: .kilowatts
                            ),
                            format: .measurement(width: .abbreviated)
                        )
                    } label: {
                        Label(
                            "Capacity",
                            systemImage: "leaf"
                        )
                    }
                }
                LabeledContent {
                    Text(
                        latestPhotovoltaicPlantInvestment.share,
                        format: .number
                    )
                } label: {
                    Label(
                        "Share",
                        systemImage: "square.grid.2x2"
                    )
                }
                LabeledContent {
                    Text(
                        latestPhotovoltaicPlantInvestment
                            .investmentDate
                            .dateValue()
                            .formatted(date: .numeric, time: .omitted)
                    )
                } label: {
                    Label(
                        "Investment Date",
                        systemImage: "calendar"
                    )
                }
            }
        } header: {
            HStack {
                Label {
                    if self.latestPhotovoltaicPlantInvestment == nil {
                        Text("Record your Investment")
                    } else {
                        Text("Your Latest Investment")
                    }
                } icon: {
                    Image(
                        systemName: "document.badge.plus"
                    )
                    .foregroundStyle(Color.accentColor)
                }
                Spacer()
                if let latestPhotovoltaicPlantInvestment = self.latestPhotovoltaicPlantInvestment {
                    Button {
                        self.presentedPhotovoltaicPlantInvestmentFormMode = .edit(latestPhotovoltaicPlantInvestment, self.photovoltaicPlant)
                    } label: {
                        Image(
                            systemName: "pencil.circle.fill"
                        )
                        .imageScale(.large)
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                    }
                    .tint(.accentColor)
                }
            }
        } footer: {
            if self.latestPhotovoltaicPlantInvestment != nil {
                NavigationLink(
                    destination: PhotovoltaicPlantInvestmentList(
                        photovoltaicPlant: self.photovoltaicPlant,
                        userEntityReference: self.userEntityReference
                    )
                ) {
                    Text(
                        "All Investments"
                    )
                    .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.accentColor)
                .padding(.top, 12)
                .align(.centerHorizontal)
            } else {
                Button {
                    self.presentedPhotovoltaicPlantInvestmentFormMode = .create(self.photovoltaicPlant)
                } label: {
                    Text(
                        "Add Investment"
                    )
                    .font(.headline)
                    .align(.centerHorizontal)
                    .padding(.vertical, 5)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
            }
        }
        .headerProminence(.increased)
    }
    
}
