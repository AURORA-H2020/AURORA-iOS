import SwiftUI

// MARK: - EditUserForm

/// The EditUserForm
struct EditUserForm {
    
    // MARK: Properties
    
    /// The User
    private let user: User
    
    /// The edited User
    private var editedUser: User {
        var user = self.user
        user.firstName = self.firstName
        user.lastName = self.lastName
        user.yearOfBirth = self.yearOfBirth
        user.gender = self.gender
        user.homeEnergyLabel = self.homeEnergyLabel
        user.householdProfile = self.householdProfile
        return user
    }
    
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
    
    /// The home energy label.
    @State
    private var homeEnergyLabel: User.HomeEnergyLabel?
    
    /// The household profile.
    @State
    private var householdProfile: User.HouseholdProfile?
    
    /// The Country
    @State
    private var country: Country?
    
    /// The City
    @State
    private var city: City?
    
    /// The DismissAction
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instnace of `EditUserForm`
    /// - Parameter user: The User.
    init(
        user: User
    ) {
        self.user = user
        self._firstName = .init(initialValue: user.firstName)
        self._lastName = .init(initialValue: user.lastName)
        self._yearOfBirth = .init(initialValue: user.yearOfBirth)
        self._gender = .init(initialValue: user.gender)
        self._homeEnergyLabel = .init(initialValue: user.homeEnergyLabel)
        self._householdProfile = .init(initialValue: user.householdProfile)
    }
    
}

// MARK: - View

extension EditUserForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
                footer: self.submitButton
                    .align(.centerHorizontal)
                    .padding(.vertical)
                    .listRowInsets(.init())
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
                if let country = self.country {
                    HStack {
                        Text("Country")
                        Spacer()
                        Text(country.localizedString())
                            .multilineTextAlignment(.trailing)
                    }
                    .foregroundColor(.secondary)
                }
                if let city = self.city {
                    HStack {
                        Text("City")
                        Spacer()
                        Text(city.name)
                            .multilineTextAlignment(.trailing)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Edit profile")
        .task {
            self.country = try? await self.firebase
                .firestore
                .get(
                    Country.self,
                    id: self.user.country.id
                )
        }
        .task {
            guard let city = self.user.city else {
                return
            }
            self.city = try? await self.firebase
                .firestore
                .get(
                    City.self,
                    context: self.user.country,
                    id: city.id
                )
        }
    }
    
}

// MARK: - Submit Button

private extension EditUserForm {
    
    /// The submit button
    var submitButton: some View {
        AsyncButton(
            fillWidth: true,
            alert: { result in
                guard case .failure = result else {
                    return nil
                }
                return .init(
                    title: Text("Error"),
                    message: Text(
                        "Your profile changes couldn't be saved. Please check your inputs and try again."
                    )
                )
            },
            action: {
                try self.firebase
                    .firestore
                    .update(self.editedUser)
                self.dismiss()
            },
            label: {
                Text("Save")
                    .font(.headline)
            }
        )
        .disabled(
            self.firstName.isEmpty
                || self.lastName.isEmpty
                || self.editedUser == self.user
        )
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    
}
