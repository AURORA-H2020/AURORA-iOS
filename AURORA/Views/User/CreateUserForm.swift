import SwiftUI

// MARK: - CreateUserForm

/// The CreateUserForm
struct CreateUserForm {
    
    // MARK: Properties
    
    /// The first name.
    @State
    private var firstName: String
    
    /// The last name.
    @State
    private var lastName: String
    
    /// The year of birth.
    @State
    private var yearOfBirth: Int?
    
    /// The gender.
    @State
    private var gender: User.Gender?
    
    /// The country reference.
    @State
    private var country: FirestoreEntityReference<Country>?
    
    /// The city reference.
    @State
    private var city: FirestoreEntityReference<City>?
    
    /// The home energy label.
    @State
    private var homeEnergyLabel: User.HomeEnergyLabel?
    
    /// The household profile.
    @State
    private var householdProfile: User.HouseholdProfile?
    
    /// Bool value if marketing consent is allowed
    @State
    private var isMarketingConsentAllowed = false
    
    /// The Cities
    @State
    private var cities: [City]?
    
    /// The Counties
    @FirestoreEntityQuery()
    private var countries: [Country]
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `CreateUserForm`
    init() {
        let firebaseUserDisplayNameComponents = try? Firebase
            .default
            .authentication
            .state
            .userAccount
            .displayName?
            .components(separatedBy: " ")
        self._firstName = .init(
            initialValue: firebaseUserDisplayNameComponents?.first ?? .init()
        )
        self._lastName = .init(
            initialValue: firebaseUserDisplayNameComponents?.last ?? .init()
        )
    }
    
}

// MARK: - Submit

private extension CreateUserForm {
    
    /// Bool value if can submit
    var canSubmit: Bool {
        !self.firstName.isEmpty
            && !self.lastName.isEmpty
            && self.country != nil
    }
    
    /// Submit
    func submit() throws {
        guard let country = self.country else {
            return
        }
        try self.firebase.firestore.add(
            User(
                firstName: self.firstName,
                lastName: self.lastName,
                yearOfBirth: self.yearOfBirth,
                gender: self.gender,
                country: country,
                city: self.city,
                homeEnergyLabel: self.homeEnergyLabel,
                householdProfile: self.householdProfile,
                isMarketingConsentAllowed: self.isMarketingConsentAllowed,
                acceptedLegalDocumentVersion: self.firebase.remoteConfig.latestLegalDocumentsVersion
            )
        )
    }
    
}

// MARK: - View

extension CreateUserForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                Section(
                    header: EmptyPlaceholder(
                        systemImage: "person.crop.circle",
                        systemImageColor: .accentColor,
                        title: "Create your profile",
                        subtitle: "Enter your information to create your personal AURORA profile."
                    )
                ) {
                    TextField(
                        "First name",
                        text: self.$firstName
                    )
                    .textContentType(.givenName)
                    TextField(
                        "Last name",
                        text: self.$lastName
                    )
                    .textContentType(.familyName)
                    Picker(
                        "Year of birth",
                        selection: self.$yearOfBirth
                    ) {
                        Text("Prefer not to say")
                            .tag(nil as Int?)
                        let currentYear = Calendar.current.component(.year, from: Date())
                        let range = (currentYear - 90)...currentYear
                        ForEach(range.reversed(), id: \.self) { year in
                            Text(String(year))
                                .tag(year as Int?)
                        }
                    }
                    Picker(
                        "Gender",
                        selection: self.$gender
                    ) {
                        Text("Prefer not to say")
                            .tag(nil as User.Gender?)
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.localizedString)
                                .tag(gender as User.Gender?)
                        }
                    }
                }
                .headerProminence(.increased)
                Section(
                    footer: Text(
                        """
                        This information helps us to more accurately calculate your carbon footprint. Please note that you can't change your country later.
                        Crowdfunding of local photovoltaic installations is currently only planned for select cities of AURORA project partners.
                        """
                    )
                ) {
                    Picker(
                        "Country",
                        selection: self.$country
                    ) {
                        Text("Please choose")
                            .tag(nil as FirestoreEntityReference<Country>?)
                        ForEach(self.countries.sorted()) { country in
                            if let reference = FirestoreEntityReference(country) {
                                Text(country.localizedString())
                                    .tag(reference as FirestoreEntityReference<Country>?)
                            }
                        }
                    }
                    if let cities = self.cities, !cities.isEmpty {
                        Picker(
                            "City",
                            selection: self.$city
                        ) {
                            Text("Please choose")
                                .tag(nil as FirestoreEntityReference<City>?)
                            ForEach(cities.sorted()) { city in
                                if let reference = FirestoreEntityReference(city) {
                                    Text(city.name)
                                        .tag(reference as FirestoreEntityReference<City>?)
                                }
                            }
                            Text("Other City")
                                .tag(nil as FirestoreEntityReference<City>?)
                        }
                    }
                }
                .headerProminence(.increased)
                .onChange(of: self.country) { country in
                    self.cities = nil
                    self.city = nil
                    guard let country = country else {
                        return
                    }
                    Task {
                        self.cities = try? await self.firebase.firestore.get(City.self, context: country)
                    }
                }
                Section {
                    Picker(
                        "Home energy label",
                        selection: self.$homeEnergyLabel
                    ) {
                        Text("Prefer not to say")
                            .tag(nil as User.HomeEnergyLabel?)
                        ForEach(User.HomeEnergyLabel.allCases, id: \.self) { energyLabel in
                            Text(energyLabel.localizedString)
                                .tag(energyLabel as User.HomeEnergyLabel?)
                        }
                    }
                    Picker(
                        "Household profile",
                        selection: self.$householdProfile
                    ) {
                        Text("Prefer not to say")
                            .tag(nil as User.HouseholdProfile?)
                        ForEach(User.HouseholdProfile.allCases, id: \.self) { householdProfile in
                            Text(householdProfile.localizedString)
                                .tag(householdProfile as User.HouseholdProfile?)
                        }
                    }
                }
                Section {
                    Toggle(isOn: self.$isMarketingConsentAllowed) {
                        Text(
                            "I would like to receive updates about the app and AURORA project by email."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    }
                    .tint(.accentColor)
                }
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
                                    "An error occurred while trying to create your profile. Please check your inputs and try again."
                                )
                            )
                        },
                        action: {
                            try self.submit()
                        },
                        label: {
                            Text("Submit")
                                .font(.headline)
                        }
                    )
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!self.canSubmit)
                    .padding(.bottom)
                ) {
                }
                .listRowInsets(.init())
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            try? self.firebase.authentication.logout()
                        } label: {
                            Label(
                                "Logout",
                                systemImage: "arrow.up.forward.square"
                            )
                        }
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await self.firebase.authentication.deleteAccount()
                                } catch {
                                    try? self.firebase.authentication.logout()
                                }
                            }
                        } label: {
                            Label(
                                "Delete my account",
                                systemImage: "trash"
                            )
                        }
                    } label: {
                        Image(
                            systemName: "ellipsis.circle"
                        )
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: self.countries) { countries in
            guard self.country == nil,
                  let deviceRegionIdentifier = Locale.current.regionCode,
                  let matchingCountry = countries.first(where: { $0.countryCode == deviceRegionIdentifier }) else {
                return
            }
            self.country = .init(matchingCountry)
        }
    }
    
}
