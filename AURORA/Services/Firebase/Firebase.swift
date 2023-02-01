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
    
    /// The user document snapshot subscription
    private var userDocumentSnapshotSubscription: FirebaseFirestore.ListenerRegistration?
    
    /// The auth state did change subscription
    private var authStateDidChangeSubscription: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
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
        // Verify a user account is available
        guard let userAccount = userAccount else {
            // Clear user
            self.user = nil
            // Return out of function
            return
        }
        // Subscribe to user document snapshots
        self.userDocumentSnapshotSubscription = User
            .collectionReference(in: self.firebaseFirestore)
            .document(userAccount.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                // Update user
                self?.user = {
                    // Check if document does not exists
                    if snapshot?.exists == false {
                        // Return success with nil
                        return .success(nil)
                    }
                    // Otherwise check if a snapshot is available
                    else if let snapshot = snapshot {
                        // Try to decode data as User
                        return .init {
                            // Record any decoding error
                            try self?.crashlytics.recordError {
                                // Decode data as User
                                try snapshot.data(as: User.self)
                            }
                        }
                    } else {
                        // Otherwise return failure
                        return error.flatMap { .failure($0) }
                    }
                }()
                // Check if an error is available
                if let error = error {
                    // Record error
                    self?.crashlytics.record(
                        error: error,
                        userInfo: [
                            "Hint": "SnapshotListener Error for /user/{userId}"
                        ]
                    )
                }
            }
    }
    
}
