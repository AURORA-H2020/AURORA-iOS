import Firebase
@_exported import FirebaseAnalyticsSwift
import FirebaseAppCheck
import FirebaseAuth
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift
import FirebaseFunctions
import FirebasePerformance
import Foundation

// MARK: - Firebase

/// A Firebase object
public final class Firebase: ObservableObject {
    
    // MARK: Static-Properties
    
    /// The default Firebase instance
    public static let `default` = Firebase()
    
    // MARK: Properties
    
    /// The FirebaseAuth instance
    public let auth: FirebaseAuth.Auth
    
    /// The Firestore instance
    public let firestore: FirebaseFirestore.Firestore
    
    /// The User, if available
    @Published
    public var user: Result<User?, Error>?
    
    /// The auth state did change subscription
    private var authStateDidChangeSubscription: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
    /// The user document snapshot subscription
    var userDocumentSnapshotSubscription: ListenerRegistration?
    
    // MARK: Initializer
    
    /// Creates a new instance of `Firebase`
    private init() {
        // Configure Firebase
        Self.configure()
        // Initialize
        self.auth = .auth()
        self.firestore = .firestore()
        // Perform Setup
        self.setup()
    }
    
    /// Deinit
    deinit {
        // Remove auth state did change subscription
        self.authStateDidChangeSubscription.flatMap(self.auth.removeStateDidChangeListener)
        // Remove user document snapshot subscription
        self.userDocumentSnapshotSubscription?.remove()
    }
    
}

// MARK: - Configure

public extension Firebase {
    
    /// Bool value if FirebaseApp is configured.
    private(set) static var isConfigured = false
    
    /// Configure FIrebase
    static func configure() {
        // Verify is not configured
        guard !self.isConfigured else {
            // Otherwise return out of function
            return
        }
        // Enable is configured
        self.isConfigured = true
        // Set AppCheckProviderFactory
        FirebaseAppCheck
            .AppCheck
            .setAppCheckProviderFactory(
                AppCheckProviderFactory()
            )
        // Configure FirebaseApp
        FirebaseApp.configure()
    }
    
}

// MARK: - Setup

private extension Firebase {
    
    /// Setup Firebase
    func setup() {
        self.authStateDidChangeSubscription = self.auth
            .addStateDidChangeListener { [weak self] _, user in
                // Send object will change event
                self?.objectWillChange.send()
                // Setup using user
                self?.setup(using: user)
            }
    }
    
    /// Setup Firebase using Firebase User
    /// - Parameter user: The optional Firebase User
    func setup(
        using user: FirebaseAuth.User?
    ) {
        // Clear current user document subscription
        self.userDocumentSnapshotSubscription?.remove()
        self.userDocumentSnapshotSubscription = nil
        // Verify a firebase user is available
        guard let user = user else {
            // Clear user
            self.user = nil
            // Return out of function
            return
        }
        // Subscribe to user document snapshots
        self.userDocumentSnapshotSubscription = User
            .collectionReference(in: self.firestore)
            .document(user.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                // Check if document does not exists
                if snapshot?.exists == false {
                    // Set success with nil
                    self?.user = .success(nil)
                }
                // Otherwise check if a snapshot is available
                else if let snapshot = snapshot {
                    // Try to decode data as User
                    self?.user = .init {
                        try snapshot.data(as: User.self)
                    }
                } else {
                    // Otherwise set failure
                    self?.user = error.flatMap { .failure($0) }
                }
            }
    }
    
}

// MARK: - Reload User

public extension Firebase {
    
    /// Reload User
    func reloadUser() {
        self.user = nil
        self.auth.currentUser.flatMap(self.setup)
    }
    
}

// MARK: - Reload User

public extension Firebase {
    
    /// Send download data request
    func sendDownloadDataRequest() async throws {
        _ = try await FirebaseFunctions
            .Functions
            .functions(region: "europe-west3")
            .httpsCallable("download-data")
            .call()
    }
    
}

// MARK: - AppCheckProviderFactory

private extension Firebase {

    /// The AppCheckProviderFactory
    final class AppCheckProviderFactory: NSObject, FirebaseAppCheck.AppCheckProviderFactory {
        
        /// Creates a new instance of `AppCheckProvider`
        /// - Parameter app: The FirebaseApp
        func createProvider(
            with app: FirebaseApp
        ) -> FirebaseAppCheck.AppCheckProvider? {
            #if targetEnvironment(simulator) || DEBUG
            return FirebaseAppCheck.AppCheckDebugProvider(app: app)
            #else
            if #available(iOS 14.0, *) {
                return FirebaseAppCheck.AppAttestProvider(app: app)
            } else {
                return FirebaseAppCheck.DeviceCheckProvider(app: app)
            }
            #endif
        }
        
    }

}
