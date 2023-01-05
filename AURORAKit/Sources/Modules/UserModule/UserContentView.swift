import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - UserContentView

/// The UserContentView
public struct UserContentView {
    
    // MARK: Properties
    
    /// The Mode
    private let mode: Mode
    
    /// The first name.
    @State
    private var firstName = String()
    
    /// The last name.
    @State
    private var lastName = String()
    
    /// The year of birth.
    @State
    private var yearOfBirth = Calendar.current.component(.year, from: Date()) - 18
    
    /// The gender.
    @State
    private var gender: User.Gender = .other
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `UserContentView`
    public init(
        mode: Mode
    ) {
        self.mode = mode
    }
    
}

// MARK: - Mode

public extension UserContentView {
    
    /// A UserContentView Mode
    enum Mode: String, Codable, Hashable, CaseIterable {
        /// Create
        case create
        /// Edit
        case edit
    }
    
}

// MARK: - Submit

private extension UserContentView {
    
    /// Bool value if can submit
    var canSubmit: Bool {
        !self.firstName.isEmpty && !self.lastName.isEmpty
    }
    
    /// Submit
    func submit() {
        try? self.firebase.update(
            user: .init(
                firstName: self.firstName,
                lastName: self.lastName,
                yearOfBirth: self.yearOfBirth,
                gender: self.gender
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
            .navigationTitle({ () -> String in
                switch self.mode {
                case .create:
                    return "Create your Profile"
                case .edit:
                    return "Profile"
                }
            }())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        try? self.firebase.logout()
                    } label: {
                        Text("Logout")
                    }

                }
            }
        }
    }
    
}
