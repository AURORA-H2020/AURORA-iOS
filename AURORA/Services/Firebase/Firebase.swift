import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseFunctions
import Foundation

// MARK: - Firebase

/// A Firebase object
final class Firebase: ObservableObject {
    
    // MARK: Static-Properties
    
    /// The default Firebase instance
    static let `default` = Firebase()
    
    // MARK: Properties
    
    /// The User.
    @Published
    var user: Result<User?, Error>?
    
    /// The Country.
    @Published
    var country: Result<Country?, Error>?
    
    /// The City.
    @Published
    var city: Result<City?, Error>?
    
    /// The Firebase Auth instance.
    private(set) lazy var firebaseAuth = FirebaseAuth.Auth.auth()
    
    /// The Firebase Firestore instance.
    private(set) lazy var firebaseFirestore = FirebaseFirestore.Firestore.firestore()
    
    /// The Firebase Crashlytics instance.
    private(set) lazy var firebaseCrashlytics = FirebaseCrashlytics.Crashlytics.crashlytics()
    
    /// The Firebase Functions instance.
    /// Operating in the region `europe-west3`
    private(set) lazy var firebaseFunctions = FirebaseFunctions.Functions.functions(region: "europe-west3")
    
    /// The FirebaseAuthenticationProviders
    private(set) lazy var firebaseAuthenticationProviders: [FirebaseAuthenticationProvider] = [
        AppleFirebaseAuthenticationProvider(),
        GoogleFirebaseAuthenticationProvider()
    ]
    
    /// The auth state did change subscription
    private var authStateDidChangeSubscription: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
    /// The user document snapshot subscription
    private var userDocumentSnapshotSubscription: FirebaseFirestore.ListenerRegistration?
    
    /// The country document snapshot subscription
    private var countryDocumentSnapshotSubscription: FirebaseFirestore.ListenerRegistration?
    
    /// The city document snapshot subscription
    private var cityDocumentSnapshotSubscription: FirebaseFirestore.ListenerRegistration?
    
    // MARK: Initializer
    
    /// Creates a new instance of `Firebase`
    private init() {
        // Add auth state did change listener
        self.authStateDidChangeSubscription = self.firebaseAuth
            .addStateDidChangeListener { [weak self] _, user in
                // Send object will change event
                self?.objectWillChange.send()
                // Setup using user
                self?.setup(using: user)
            }
    }
    
    /// Deinit
    deinit {
        // Remove auth state did change subscription
        self.authStateDidChangeSubscription.flatMap(self.firebaseAuth.removeStateDidChangeListener)
        // Remove user document snapshot subscription
        self.userDocumentSnapshotSubscription?.remove()
    }
    
}

// MARK: - API

extension Firebase {
    
    /// The Firebase Authentication
    var authentication: Authentication {
        .init(
            firebase: self
        )
    }
    
    /// The Firebase Firestore
    var firestore: Firestore {
        .init(
            firebase: self
        )
    }
    
    /// The Firebase Crashlytics
    var crashlytics: Crashlytics {
        .init(
            crashlytics: self.firebaseCrashlytics
        )
    }
    
    /// The Firebase Functions
    var functions: Functions {
        .init(
            firebase: self
        )
    }
    
    /// Handle opened URL
    /// - Parameter url: The opened URL.
    @discardableResult
    func handle(
        opened url: URL
    ) -> Bool {
        // For each FirebaseAuthenticationProvider
        for firebaseAuthenticationProvider in self.firebaseAuthenticationProviders {
            // Check if provider can handle opened url
            // swiftlint:disable:next for_where
            if firebaseAuthenticationProvider.handle(openedURL: url) {
                // Return success
                return true
            }
        }
        // Return false as url couldn't be handled
        return false
    }
    
}

// MARK: - Internal API

extension Firebase {
    
    /// Setup Firebase using the user account
    /// - Parameter user: The user account, if available.
    func setup(
        using userAccount: User.Account?
    ) {
        // Clear current user document subscription
        self.userDocumentSnapshotSubscription?.remove()
        self.userDocumentSnapshotSubscription = nil
        // Clear current country document subscription
        self.countryDocumentSnapshotSubscription?.remove()
        self.countryDocumentSnapshotSubscription = nil
        // Clear current city document subscription
        self.cityDocumentSnapshotSubscription?.remove()
        self.cityDocumentSnapshotSubscription = nil
        // Verify a user account is available
        guard let userAccount = userAccount else {
            // Clear user
            self.user = nil
            // Clear country
            self.country = nil
            // Clear city
            self.city = nil
            // Return out of function
            return
        }
        // Subscribe to user document snapshots
        self.userDocumentSnapshotSubscription = User
            .collectionReference(in: self.firebaseFirestore)
            .document(userAccount.uid)
            .addSnapshotListener(
                ofType: User.self,
                crashlytics: self.crashlytics
            ) { [weak self] user in
                // Update user
                self?.user = user
                // Setup using user result
                self?.setup(using: user)
            }
    }
    
    /// Setup using User
    /// - Parameter user: The User Result
    private func setup(
        using user: Result<User?, Error>?
    ) {
        // Clear current country document subscription
        self.countryDocumentSnapshotSubscription?.remove()
        self.countryDocumentSnapshotSubscription = nil
        // Clear current city document subscription
        self.cityDocumentSnapshotSubscription?.remove()
        self.cityDocumentSnapshotSubscription = nil
        // Switch on user
        switch user {
        case .success(let user):
            // Check if a user is available
            if let user = user {
                // Add snapshot listener to country
                self.cityDocumentSnapshotSubscription = Country
                    .collectionReference()
                    .document(user.country.id)
                    .addSnapshotListener(
                        ofType: Country.self,
                        crashlytics: self.crashlytics
                    ) { [weak self] country in
                        // Update country
                        self?.country = country
                    }
            } else {
                // Otherwise update country to nil
                self.country = nil
            }
            // Check if a user with a city reference is available
            if let user = user,
               let cityReference = user.city {
                // Add snapshot listener to city
                self.cityDocumentSnapshotSubscription = City
                    .collectionReference(context: user.country.id)
                    .document(cityReference.id)
                    .addSnapshotListener(
                        ofType: City.self,
                        crashlytics: self.crashlytics
                    ) { [weak self] city in
                        // Update city
                        self?.city = city
                    }
            } else {
                // Otherwise update city to nil
                self.city = nil
            }
        case .failure(let error):
            // Update to failure
            self.country = .failure(error)
            self.city = .failure(error)
        case nil:
            // Update to nil
            self.country = nil
            self.city = nil
        }
    }
    
}

// MARK: - FirebaseFirestore+DocumentReference+addSnapshotListener()

private extension FirebaseFirestore.DocumentReference {
    
    /// Attaches a listener for DocumentSnapshot events of a given `FirestoreEntity`.
    /// - Parameters:
    ///   - entityType: The FirestoreEntity type.
    ///   - crashlytics: The optional Crashlytics to report any errors to.
    ///   - listener: A listener closure.
    func addSnapshotListener<Entity: FirestoreEntity>(
        ofType entityType: Entity.Type,
        crashlytics: Firebase.Crashlytics,
        listener: @escaping (Result<Entity?, Error>?) -> Void
    ) -> FirebaseFirestore.ListenerRegistration {
        self.addSnapshotListener { snapshot, error in
            // Check if document does not exists
            if snapshot?.exists == false {
                // Invoke listener with success using nil
                listener(.success(nil))
            }
            // Check if a snapshot is available
            else if let snapshot = snapshot {
                // Invoke listener by trying to decode data as entity type
                listener(
                    .init {
                        // Record any decoding error
                        try crashlytics.recordError {
                            // Decode data as User
                            try snapshot.data(as: Entity.self)
                        }
                    }
                )
            }
            // Check if an error is available
            else if let error = error {
                // Invoke listener with failure and error
                listener(.failure(error))
                // Record error
                crashlytics.record(
                    error: error,
                    userInfo: [
                        "Hint": "SnapshotListener Error",
                        "DocumentPath": snapshot?.reference.path ?? .init()
                    ]
                )
            } else {
                // Invoke listener with nil
                listener(nil)
            }
        }
    }
    
}
