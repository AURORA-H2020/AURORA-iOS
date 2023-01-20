@_exported import FirebaseAnalyticsSwift
@_exported import FirebaseAuth
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift
@_exported import struct GoogleSignInSwift.GoogleSignInButton
import FirebaseFunctions
import Foundation

// MARK: - Firebase

/// A Firebase object
public final class Firebase: ObservableObject {
    
    // MARK: Static-Properties
    
    /// The default Firebase instance
    public static let `default` = Firebase()
    
    // MARK: Properties
    
    /// The Firebase Auth instance.
    let firebaseAuth: FirebaseAuth.Auth
    
    /// The Firebase Firestore instance.
    let firebaseFirestore: FirebaseFirestore.Firestore
    
    /// The Firebase Functions instance.
    let firebaseFunctions: FirebaseFunctions.Functions
    
    /// The FirebaseAuthenticationProviders
    let firebaseAuthenticationProviders: [FirebaseAuthenticationProvider]
    
    /// The User.
    @Published
    var user: Result<User?, Error>?
    
    /// The user document snapshot subscription
    var userDocumentSnapshotSubscription: FirebaseFirestore.ListenerRegistration?
    
    /// The auth state did change subscription
    private var authStateDidChangeSubscription: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
    // MARK: Initializer
    
    /// Creates a new instance of `Firebase`
    private init() {
        // Configure Firebase
        Self.configure()
        // Initialize
        self.firebaseAuth = .auth()
        self.firebaseFirestore = .firestore()
        self.firebaseFunctions = .functions()
        self.firebaseAuthenticationProviders = [
            AppleFirebaseAuthenticationProvider(),
            GoogleFirebaseAuthenticationProvider()
        ]
        // Perform Setup
        self.setup()
    }
    
    /// Deinit
    deinit {
        // Remove auth state did change subscription
        self.authStateDidChangeSubscription.flatMap(self.firebaseAuth.removeStateDidChangeListener)
        // Remove user document snapshot subscription
        self.userDocumentSnapshotSubscription?.remove()
    }
    
}

// MARK: - Public API

public extension Firebase {
    
    /// The Firebase Authentication
    var authentication: Authentication {
        .init(
            firebase: self
        )
    }
    
    /// The Firebase Firestore
    var firestore: Firestore {
        .init(
            firestore: self.firebaseFirestore,
            auth: self.firebaseAuth
        )
    }
    
    /// The Firebase Functions
    var functions: Functions {
        .init(
            functions: self.firebaseFunctions
        )
    }
    
    /// Handle opened URL
    /// - Parameter url: The opened URL.
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

// MARK: - Setup

private extension Firebase {
    
    /// Setup Firebase
    func setup() {
        self.authStateDidChangeSubscription = self.firebaseAuth
            .addStateDidChangeListener { [weak self] _, user in
                // Send object will change event
                self?.objectWillChange.send()
                // Setup using user
                self?.setup(using: user)
            }
    }
    
}

// MARK: - Setup using User Account

extension Firebase {
    
    /// Setup Firebase using the user account
    /// - Parameter user: The user account, if available.
    func setup(
        using userAccount: UserAccount?
    ) {
        // Clear current user document subscription
        self.userDocumentSnapshotSubscription?.remove()
        self.userDocumentSnapshotSubscription = nil
        // Verify a user account is available
        guard let userAccount = userAccount else {
            // Clear user
            self.user = nil
            // Sign out on authentication providers
            try? AppleFirebaseAuthenticationProvider().signOut()
            try? GoogleFirebaseAuthenticationProvider().signOut()
            // Return out of function
            return
        }
        // Subscribe to user document snapshots
        self.userDocumentSnapshotSubscription = User
            .collectionReference(in: self.firebaseFirestore)
            .document(userAccount.uid)
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
