import SwiftUI

// MARK: - PhotovoltaicScreen

/// The PhotovoltaicScreen.
struct PhotovoltaicScreen {
    
    /// The Country.
    let country: Country
    
    /// The City.
    let city: City
    
    /// The PVGIS parameters of the city.
    let pvgisParams: City.PVGISParams
    
    /// The amount to invest.
    @State
    private var investmentAmount: Int?
    
    /// The AsyncButtonState.
    @State
    private var asyncButtonState: AsyncButtonState?
    
    /// The calculcated photovoltaic investment result.
    @State
    private var investmentResult: PVGISService.PhotovoltaicInvestmentResult?
    
}

// MARK: - View

extension PhotovoltaicScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                if let investmentResult = self.investmentResult {
                    self.investmentResultForm(investmentResult)
                } else {
                    self.investmentForm
                }
            }
            .animation(
                .default,
                value: self.investmentResult
            )
            .navigationTitle("Your Solar Power")
        }
    }
    
}

// MARK: - Investment Form

private extension PhotovoltaicScreen {
    
    /// The investment form
    var investmentForm: some View {
        Section(
            header: VStack {
                Text(
                    "You can soon reduce your carbon footprint by investing into your local AURORA photovoltaic installation. Until then, you can already test here, by how much your footprint would be reduced, depending on your potential investment."
                )
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                Text(String(" "))
            }
            .listRowInsets(.init()),
            footer: VStack {
                AsyncButton(
                    fillWidth: true,
                    alert: { result in
                        guard case .failure = result else {
                            return nil
                        }
                        return .init(
                            title: Text("Error"),
                            message: Text("An error occurred please try again.")
                        )
                    },
                    action: {
                        guard let investmentAmount = self.investmentAmount else {
                            return
                        }
                        self.investmentResult = try await PVGISService()
                            .calculcatePhotovoltaicInvestment(
                                amount: investmentAmount,
                                using: self.pvgisParams,
                                in: self.country
                            )
                    },
                    label: {
                        Text("Calculcate")
                            .font(.headline)
                    }
                )
                .onPreferenceChange(
                    AsyncButtonState.PreferenceKey.self
                ) { asyncButtonState in
                    self.asyncButtonState = asyncButtonState
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(
                    self.investmentAmount == nil || self.investmentAmount == 0
                )
                .padding(.vertical)
                Text(
                    """
                    Please note that all values displayed here are specific for your city, **\(self.city.name)**, and are merely for information.
                    All calculations are based on current plans for the photovoltaic installations, and may need to be adjusted later.
                    Estimated savings might be different from actual data, once the photovoltaic installations will be operational.
                    You obviously do not make any commitments by using this calculator.
                    
                    This calculator uses the [Photovoltaic Geographical](https://re.jrc.ec.europa.eu/pvg_tools/) Information System (PVGIS) by the European Commission Joint Research Centre.
                    """
                )
                .multilineTextAlignment(.leading)
                .font(.caption)
            }
            .listRowInsets(.init())
            .padding(.top)
        ) {
            HStack {
                NumberTextField(
                    "Investment",
                    value: self.$investmentAmount
                )
                Text(
                    verbatim: self.country.localizedCurrencySymbol
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .disabled(self.asyncButtonState == .busy)
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Investment Result Form

private extension PhotovoltaicScreen {
    
    /// Investment result form.
    /// - Parameter investmentResult: The PhotovoltaicInvestmentResult.
    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func investmentResultForm(
        _ investmentResult: PVGISService.PhotovoltaicInvestmentResult
    ) -> some View {
        Section {
            HStack {
                Text("Your investment")
                Spacer()
                Text(
                    investmentResult
                        .amount
                        .formatted(
                            .currency(
                                code: self.country.currencyCode
                            )
                            .precision(.fractionLength(0))
                        )
                )
            }
            HStack {
                Text("Energy produced")
                Spacer()
                Text(
                    investmentResult
                        .producedEnergy
                        .formatted(
                            .measurement(
                                width: .abbreviated,
                                numberFormatStyle: .number.precision(.fractionLength(0))
                            )
                        )
                )
            }
        }
        Section(
            footer: VStack {
                Text(
                    "This is the amount of CO₂ that would be emitted if you had drawn the produced energy from your local grid instead"
                )
                Image(
                    systemName: "minus.circle"
                )
                .font(.system(size: 30))
            }
        ) {
            self.investmentResultBox(
                title: "CO₂ emitted if **conventional**",
                measurement: investmentResult.normalCarbonEmissions
            )
        }
        .listRowBackground(Color.orange)
        .headerProminence(.increased)
        Section(
            footer: VStack {
                Text(
                    "Did you know? Even the use of photovoltaics emit some CO₂ - albeit significantly less than conventional sources of energy."
                )
                Image(
                    systemName: "equal.circle"
                )
                .font(.system(size: 30))
                .padding(.top, 3)
            }
        ) {
            self.investmentResultBox(
                title: "CO₂ emitted if **photovoltaics**",
                measurement: investmentResult.carbonEmissions
            )
        }
        .listRowBackground(Color.orange)
        .headerProminence(.increased)
        Section(
            footer: Text(
                "You would be reducing CO₂ emission within your local community by this amount. Great job!"
            )
        ) {
            self.investmentResultBox(
                title: "CO₂ reduction",
                measurement: investmentResult.carbonEmissionsReduction
            )
        }
        .listRowBackground(Color.green)
        .headerProminence(.increased)
        Section(
            footer: VStack(spacing: 10) {
                HStack {
                    Button {
                        self.investmentResult = nil
                    } label: {
                        Text("Reset")
                            .font(.subheadline.weight(.semibold))
                    }
                    Link(
                        destination: .init(
                            string: "https://www.aurora-h2020.eu"
                        )!
                    ) {
                        Text("Learn more on our website")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .buttonBorderShape(.capsule)
                Text(
                    """
                    Please note that all values displayed here are specific for your city, **\(self.city.name)**, and are merely for information. All calculations are based on current plans for the photovoltaic installations, and may need to be adjusted later. Estimated savings might be different from actual data, once the photovoltaic installations will be operational. You obviously do not make any commitments by using this calculator.
                    
                    This calculator uses the [Photovoltaic Geographical](https://re.jrc.ec.europa.eu/pvg_tools/) Information System (PVGIS) by the European Commission Joint Research Centre.
                    """
                )
                .font(.caption)
                .multilineTextAlignment(.leading)
            }
            .listRowInsets(.init())
        ) {
        }
    }
    
    /// Investment Result Box
    /// - Parameters:
    ///   - title: The title.
    ///   - measurement: The measurement.
    func investmentResultBox(
        title: LocalizedStringKey,
        measurement: Measurement<UnitMass>
    ) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Divider()
                .overlay(Color.black)
            Spacer()
            Text(
                measurement.formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .asProvided,
                        numberFormatStyle: .number
                            .precision(.fractionLength(1))
                    )
                )
            )
            .font(.title2.weight(.semibold))
            .align(.centerHorizontal)
        }
        .foregroundColor(.black)
        .multilineTextAlignment(.leading)
    }
    
}
