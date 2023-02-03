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
    private var yearOfBirth: Int
    
    /// The gender.
    @State
    private var gender: User.Gender
    
    /// The site reference.
    @State
    private var site: FirestoreEntityReference<Site>?
    
    /// The Sites
    @FirestoreEntityQuery()
    private var sites: [Site]
    
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
        self._yearOfBirth = .init(
            initialValue: Calendar.current.component(.year, from: Date()) - 18
        )
        self._gender = .init(
            initialValue: .other
        )
    }
    
}

// MARK: - Submit

private extension CreateUserForm {
    
    /// Bool value if can submit
    var canSubmit: Bool {
        !self.firstName.isEmpty
            && !self.lastName.isEmpty
            && self.site != nil
    }
    
    /// Submit
    func submit() throws {
        guard let site = self.site else {
            return
        }
        try self.firebase.firestore.add(
            User(
                firstName: self.firstName,
                lastName: self.lastName,
                yearOfBirth: self.yearOfBirth,
                gender: self.gender,
                site: site,
                consumptionSummary: nil
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
                        let currentYear = Calendar.current.component(.year, from: Date())
                        let range = (currentYear - 90)...currentYear
                        ForEach(range.reversed(), id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                        }
                    }
                    Picker(
                        "Gender",
                        selection: self.$gender
                    ) {
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.localizedString)
                                .tag(gender)
                        }
                    }
                    Picker(
                        "Site",
                        selection: self.$site
                    ) {
                        Text("Please choose")
                            .tag(nil as FirestoreEntityReference<Site>?)
                        ForEach(self.sites) { site in
                            if let reference = FirestoreEntityReference(site) {
                                Text(site.localizedString())
                                    .tag(reference as FirestoreEntityReference<Site>?)
                            }
                        }
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
                                    // swiftlint:disable:next line_length
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
                ) {
                }
                .listRowInsets(.init())
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        try? self.firebase.authentication.logout()
                    } label: {
                        Text("Logout")
                    }

                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
}
