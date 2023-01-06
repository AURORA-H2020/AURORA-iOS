@_exported import Firebase
@_exported import FirebaseAuth
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift
import Foundation

// MARK: - Firebase

/// A Firebase object
public final class Firebase: ObservableObject {
    
    // MARK: Static-Properties
    
    /// The default Firebase instance
    public static let `default`: Firebase = {
        // Configure FirebaseApp
        FirebaseApp.configure()
        // Return Firebase instance
        return .init()
    }()
    
    // MARK: Properties
    
    /// The FirebaseAuth instance
    public let auth: FirebaseAuth.Auth = .auth()
    
    /// The Firestore instance
    public let firestore: FirebaseFirestore.Firestore = .firestore()
    
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
        // Verify a firebase user is available
        guard let user = user else {
            // Otherwise remove user document snapshot subscription
            self.userDocumentSnapshotSubscription?.remove()
            self.userDocumentSnapshotSubscription = nil
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
                if snapshot?.exists == false {
                    self?.user = .success(nil)
                } else if let snapshot = snapshot {
                    self?.user = .init {
                        try snapshot.data(as: User.self)
                    }
                } else {
                    self?.user = error.flatMap { .failure($0) }
                }
            }
    }
    
}
