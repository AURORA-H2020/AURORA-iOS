import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - UserContentView

/// The UserContentView
public struct UserContentView {
    
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
    private var site: Reference<Site>?
    
    /// The Sites
    @FirebaseKit.FirestoreQuery(
        collectionPath: Site.collectionName
    )
    private var sites: [Site]
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `UserContentView`
    public init(
        user: User? = nil
    ) {
        if let user = user {
            self._firstName = .init(initialValue: user.firstName)
            self._lastName = .init(initialValue: user.lastName)
            self._yearOfBirth = .init(initialValue: user.yearOfBirth)
            self._gender = .init(initialValue: user.gender)
            self._site = .init(initialValue: user.site)
        } else {
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
    
}

// MARK: - Submit

private extension UserContentView {
    
    /// Bool value if can submit
    var canSubmit: Bool {
        !self.firstName.isEmpty && !self.lastName.isEmpty && self.site != nil
    }
    
    /// Submit
    func submit() {
        guard let site = self.site else {
            return
        }
        try? self.firebase.firestore.update(
            User(
                firstName: self.firstName,
                lastName: self.lastName,
                yearOfBirth: self.yearOfBirth,
                gender: self.gender,
                site: site
            )
        )
    }
    
}

// MARK: - View

extension UserContentView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        NavigationView {
            List {
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
                        Text(
                            verbatim: .init(year)
                        )
                        .tag(year)
                    }
                }
                Picker(
                    "Gender",
                    selection: self.$gender
                ) {
                    ForEach(User.Gender.allCases, id: \.self) { gender in
                        Text(
                            verbatim: {
                                switch gender {
                                case .male:
                                    return "Male"
                                case .female:
                                    return "Female"
                                case .nonBinary:
                                    return "Non Binary"
                                case .other:
                                    return "Other"
                                }
                            }()
                        )
                        .tag(gender)
                    }
                }
                Picker(
                    "Sites",
                    selection: self.$site
                ) {
                    ForEach(self.sites) { site in
                        if let reference = Reference(site) {
                            Text(
                                verbatim: [
                                    site.city,
                                    site.localizedCountryName()
                                ]
                                .compactMap { $0 }
                                .joined(separator: ", ")
                            )
                            .tag(reference as Reference<Site>?)
                        }
                    }
                }
                Section(
                    footer: Button {
                        self.submit()
                    } label: {
                        Text(
                            verbatim: "Submit"
                        )
                        .font(.headline)
                        .align(.centerHorizontal)
                    }
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
    }
    
}
