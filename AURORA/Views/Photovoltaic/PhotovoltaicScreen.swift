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
    private var investmentAmount: Double?
    
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
                Section(
                    header: HStack {
                        Text("\(self.city.name) Investment")
                        Spacer()
                        if self.investmentResult != nil {
                            Button {
                                self.investmentResult = nil
                            } label: {
                                Text("Reset")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .buttonStyle(.bordered)
                            .tint(.accentColor)
                            .buttonBorderShape(.capsule)
                        }
                    },
                    footer: Group {
                        if self.investmentResult == nil {
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
                        } else {
                            // swiftlint:disable line_length
                            Text(
                                """
                                Please note that these numbers are purely informational and only provide estimates based on current discussions with our photovoltaic partners.
                                Calculated savings may be different from actual data, once the photovoltaic installations go live.
                                """
                            )
                            // swiftlint:enable line_length
                        }
                    }
                ) {
                    if let investmentResult = self.investmentResult {
                        HStack {
                            Text("Investment")
                            Spacer()
                            Text(investmentResult.amount.formatted(.currency(code: self.country.currencyCode)))
                        }
                        HStack {
                            Text("Produced Energy")
                            Spacer()
                            Text(investmentResult.producedEnergy.formatted())
                        }
                        HStack {
                            Text("Carbon emissions produced by PV")
                            Spacer()
                            Text(investmentResult.carbonEmissions.formatted())
                        }
                        HStack {
                            Text("Normal carbon emissions")
                            Spacer()
                            Text(investmentResult.normalCarbonEmissions.formatted())
                        }
                        HStack {
                            Text("Carbon emissions reduction")
                            Spacer()
                            Text(investmentResult.carbonEmissionsReduction.formatted())
                        }
                    } else {
                        HStack {
                            NumberTextField(
                                "Investment",
                                value: self.$investmentAmount
                            )
                            if let localizedCurrency = self.country.localizedCurrencySymbol {
                                Text(
                                    verbatim: localizedCurrency
                                )
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                        }
                        .disabled(self.asyncButtonState == .busy)
                    }
                }
                .headerProminence(.increased)
            }
            .animation(
                .default,
                value: self.investmentResult
            )
            .navigationTitle("Photovoltaics")
        }
    }
    
}
