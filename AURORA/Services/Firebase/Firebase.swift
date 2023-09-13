import Combine
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseFunctions
import FirebaseRemoteConfig
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
    
    /// The Firebase RemoteConfig instance.
    private(set) lazy var firebaseRemoteConfig = FirebaseRemoteConfig.RemoteConfig.remoteConfig()
    
    /// The auth state did change subscription
    private var authStateDidChangeSubscription: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
    /// The remote config update subscription
    private var remoteConfigUpdateSubscription: FirebaseRemoteConfig.ConfigUpdateListenerRegistration?
    
    /// The user document snapshot cancellable
    private var userDocumentSnapshotCancellable: AnyCancellable?
    
    /// The country document snapshot cancellable
    private var countryDocumentSnapshotCancellable: AnyCancellable?
    
    /// The city document snapshot cancellable
    private var cityDocumentSnapshotCancellable: AnyCancellable?
    
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
        // Add remote config update listener
        self.remoteConfigUpdateSubscription = self.firebaseRemoteConfig
            .addOnConfigUpdateListener { [weak self] _, _ in
                // Activate changes
                self?.firebaseRemoteConfig.activate()
            }
        Task {
            // Fetch and active remote config
            try? await self.firebaseRemoteConfig.fetchAndActivate()
        }
    }
    
    /// Deinit
    deinit {
        // Remove auth state did change subscription
        self.authStateDidChangeSubscription.flatMap(self.firebaseAuth.removeStateDidChangeListener)
        // Remove remote config subscription
        self.remoteConfigUpdateSubscription?.remove()
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
    
    /// The Firebase RemoteConfig
    var remoteConfig: RemoteConfig {
        .init(
            remoteConfig: self.firebaseRemoteConfig
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
        // Clear current user document cancellable
        self.userDocumentSnapshotCancellable = nil
        // Clear current country document cancellable
        self.countryDocumentSnapshotCancellable = nil
        // Clear current city document cancellable
        self.cityDocumentSnapshotCancellable = nil
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
        self.userDocumentSnapshotCancellable = self.firestore
            .publisher(
                User.self,
                id: userAccount.id
            )
            .sink { [weak self] user in
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
        // Clear current country document cancellable
        self.countryDocumentSnapshotCancellable = nil
        // Clear current city document cancellable
        self.cityDocumentSnapshotCancellable = nil
        // Switch on user
        switch user {
        case .success(let user):
            // Check if a user is available
            if let user = user {
                // Add snapshot listener to country
                self.countryDocumentSnapshotCancellable = self.firestore
                    .publisher(
                        Country.self,
                        id: user.country.id
                    )
                    .sink { [weak self] country in
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
                self.cityDocumentSnapshotCancellable = self.firestore
                    .publisher(
                        City.self,
                        context: user.country,
                        id: cityReference.id
                    )
                    .sink { [weak self] city in
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
