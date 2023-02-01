import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

// swiftlint:disable line_length

// MARK: - FirestoreEntityQuery

/// A property wrapper that listens to a Firestore entity collection.
@propertyWrapper
struct FirestoreEntityQuery<Entity: FirestoreEntity>: DynamicProperty {
    
    // MARK: Properties
    
    /// The Firebase instance.
    private let firebase: Firebase
    
    /// The FirestoreQuery Result
    @FirebaseFirestoreSwift.FirestoreQuery
    private var queryResult: Result<[Entity], Error>
    
    /// The results of the query.
    /// This property returns an empty collection when there are no matching results.
    var wrappedValue: [Entity] {
        switch self.queryResult {
        case .success(let entities):
            return entities
        case .failure(let error):
            self.firebase.crashlytics.record(error: error)
            return .init()
        }
    }
    
    /// A binding to the request's mutable configuration properties
    var projectedValue: FirebaseFirestoreSwift.FirestoreQuery<Result<[Entity], Error>>.Configuration {
        self.$queryResult
    }
    
    /// The query's predicates.
    var predicates: [FirebaseFirestoreSwift.QueryPredicate] {
        get {
            self.$queryResult.predicates
        }
        set {
            self.$queryResult.predicates = newValue
        }
    }
    
    /// The error, if any.
    var error: Error? {
        if case .failure(let error) = self.queryResult {
            self.firebase.crashlytics.record(error: error)
            return error
        } else {
            return nil
        }
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `FirestoreEntityQuery`
    /// - Parameters:
    ///   - context: The CollectionReferenceContext.
    ///   - predicates: An array of `QueryPredicate`s that defines a filter for the fetched results. Default value `.init()`
    ///   - firebase: The Firebase instance. Default value `.default`
    init(
        context: Entity.CollectionReferenceContext,
        predicates: [FirebaseFirestoreSwift.QueryPredicate] = .init(),
        firebase: Firebase = .default
    ) {
        self.firebase = firebase
        self._queryResult = .init(
            collectionPath: Entity
                .collectionReference(
                    context: context
                )
                .path,
            predicates: predicates,
            decodingFailureStrategy: .raise
        )
    }
    
}

// MARK: - FirestoreEntityQuery+init()

extension FirestoreEntityQuery where Entity.CollectionReferenceContext == Void {
    
    /// Creates a new instance of `FirestoreEntityQuery`
    /// - Parameters:
    ///   - predicates: An array of `QueryPredicate`s that defines a filter for the fetched results. Default value `.init()`
    ///   - firebase: The Firebase instance. Default value `.default`
    init(
        predicates: [FirebaseFirestoreSwift.QueryPredicate] = .init(),
        firebase: Firebase = .default
    ) {
        self.firebase = firebase
        self._queryResult = .init(
            collectionPath: Entity
                .collectionReference(context: ())
                .path,
            predicates: predicates
        )
    }
    
}
