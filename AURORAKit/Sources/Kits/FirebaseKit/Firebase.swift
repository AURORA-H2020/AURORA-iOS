import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// MARK: - Firebase

/// A Firebase object
public final class Firebase: ObservableObject {
    
    // MARK: Static-Properties
    
    /// The default Firebase instance
    public static let `default` = Firebase()
    
    // MARK: Properties
    
    /// The FirebaseAuth instance
    public let auth: FirebaseAuth.Auth = .auth()
    
    /// The Firestore instance
    public let firestore: FirebaseFirestore.Firestore = .firestore()
    
    /// The User, if available
    @Published
    public var user: Result<User, Error>?
    
    /// The auth state did change subscription
    private var authStateDidChangeSubscription: FirebaseAuth.AuthStateDidChangeListenerHandle?
    
    /// The user document snapshot subscription
    private var userDocumentSnapshotSubscription: ListenerRegistration?
    
    // MARK: Initializer
    
    /// Creates a new instance of `Firebase`
    private init() {
        // Configure Firebase
        FirebaseApp.configure()
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
        self.userDocumentSnapshotSubscription = self.firestore
            .collection(FirestoreCollectionName.users.rawValue)
            .document(user.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let snapshot = snapshot {
                    self?.user = .init {
                        try snapshot.data(as: User.self)
                    }
                } else {
                    self?.user = error.flatMap { .failure($0) }
                }
            }
    }
    
}

// MARK: - Authentication

public extension Firebase {
    
    /// A Firebase Authentication Method
    enum AuthenticationMethod {
        /// Password
        case password(email: String, password: String)
    }
    
    /// Register a new user by providing a E-Mail address and a password
    /// - Parameters:
    ///   - email: The E-Mail address
    ///   - password: The password
    @discardableResult
    func register(
        email: String,
        password: String
    ) async throws -> FirebaseAuth.AuthDataResult {
        try await self.auth
            .createUser(
                withEmail: email,
                password: password
            )
    }
    
    /// Login user using a given AuthenticationMethod
    /// - Parameter authenticationMode: The AuthenticationMode used to login the user.
    @discardableResult
    func login(
        using authenticationMode: AuthenticationMethod
    ) async throws -> FirebaseAuth.AuthDataResult {
        switch authenticationMode {
        case .password(let email, let password):
            return try await self.auth
                .signIn(
                    withEmail: email,
                    password: password
                )
        }
    }
    
    /// Logout the currently authenticated user.
    func logout() throws {
        try self.auth.signOut()
    }
    
    /// Delete the currently authenticated user account.
    func deleteUser() async throws {
        try await self.auth.currentUser?.delete()
        self.user = nil
        self.userDocumentSnapshotSubscription?.remove()
        self.userDocumentSnapshotSubscription = nil
    }
    
}

// MARK: - Firestore

public extension Firebase {
    
    enum FirestoreCollectionName: String, Codable, Hashable, CaseIterable {
        case users
        case consumptions
    }
    
    func update(
        user: User
    ) throws {
        guard let firebaseUser = self.auth.currentUser else {
            return
        }
        try self.firestore
            .collection(FirestoreCollectionName.users.rawValue)
            .document(firebaseUser.uid)
            .setData(from: user)
        self.user = .success(user)
    }
    
    func add(
        consumption: Consumption
    ) throws {
        guard let firebaseUser = self.auth.currentUser else {
            return
        }
        _ = try self.firestore
            .collection(FirestoreCollectionName.users.rawValue)
            .document(firebaseUser.uid)
            .collection(FirestoreCollectionName.consumptions.rawValue)
            .addDocument(from: consumption)
    }
    
    func update(
        consumption: Consumption
    ) throws {
        guard let consumptionId = consumption.id,
              let firebaseUser = self.auth.currentUser else {
            return
        }
        try self.firestore
            .collection(FirestoreCollectionName.users.rawValue)
            .document(firebaseUser.uid)
            .collection(FirestoreCollectionName.consumptions.rawValue)
            .document(consumptionId)
            .setData(from: consumptionId)
    }
    
    func remove(
        consumption: Consumption
    ) {
        guard let consumptionId = consumption.id,
              let firebaseUser = self.auth.currentUser else {
            return
        }
        self.firestore
            .collection(FirestoreCollectionName.users.rawValue)
            .document(firebaseUser.uid)
            .collection(FirestoreCollectionName.consumptions.rawValue)
            .document(consumptionId)
            .delete()
    }
    
}
