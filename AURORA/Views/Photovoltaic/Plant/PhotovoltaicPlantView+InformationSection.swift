import Contacts
import SwiftUI

// MARK: - PhotovoltaicPlantView+InformationSection

extension PhotovoltaicPlantView {
    
    /// The InformationSection
    struct InformationSection {
        
        /// The postal address formatter.
        private static let postalAddressFormatter = CNPostalAddressFormatter()
        
        /// The PhotovoltaicPlant
        let photovoltaicPlant: PhotovoltaicPlant
        
        /// The Firebase instance
        @EnvironmentObject
        private var firebase: Firebase
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantView.InformationSection: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Section {
            Group {
                if let capacityMeasurement = self.photovoltaicPlant.capacityMeasurement {
                    Label(
                        capacityMeasurement.formatted(),
                        systemImage: "battery.100.bolt"
                    )
                }
                if case let city = try? self.firebase.city?.get(),
                   case let country = try? self.firebase.country?.get(),
                   city != nil || country != nil {
                    Label(
                        Self.postalAddressFormatter.string(
                            from: {
                                let postalAddress = CNMutablePostalAddress()
                                if let city = city {
                                    postalAddress.city = city.name
                                }
                                if let country = country {
                                    postalAddress.country = country.localizedString()
                                }
                                return postalAddress
                            }()
                        ),
                        systemImage: "mappin.and.ellipse"
                    )
                }
                if let manufacturer = self.photovoltaicPlant.manufacturer {
                    Label(
                        manufacturer,
                        systemImage: "building.2"
                    )
                }
                if let technology = self.photovoltaicPlant.technology {
                    Label(
                        technology,
                        systemImage: "memorychip"
                    )
                }
                if let installationDate = self.photovoltaicPlant.installationDate {
                    Label {
                        Text(
                            installationDate.dateValue(),
                            style: .date
                        )
                    } icon: {
                        Image(systemName: "calendar")
                    }

                }
            }
            .font(.subheadline)
        } header: {
            Label {
                Text("Solar Panel Information")
            } icon: {
                Image(
                    systemName: "sun.max"
                )
                .foregroundStyle(.yellow)
            }
        } footer: {
            if let infoURL = self.photovoltaicPlant.infoURL.flatMap(URL.init) {
                Button(destination: infoURL) {
                    Label(
                        "How to invest?",
                        systemImage: "arrow.up.forward.square"
                    )
                    .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.accentColor)
                .padding(.top, 12)
                .align(.centerHorizontal)
            }
        }
        .headerProminence(.increased)
    }
    
}
