import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

// swiftlint:disable line_length

// MARK: - FirestoreEntityQuery

/// A property wrapper that listens to a Firestore entity collection.
@propertyWrapper
public struct FirestoreEntityQuery<Entity: FirestoreEntity>: DynamicProperty {
    
    // MARK: Properties
    
    /// The Entities
    @FirebaseFirestoreSwift.FirestoreQuery
    private var entity: Result<[Entity], Error>
    
    /// The results of the query.
    /// This property returns an empty collection when there are no matching results.
    public var wrappedValue: [Entity] {
        switch self.entity {
        case .success(let entities):
            return entities
        case .failure:
            return .init()
        }
    }
    
    /// A binding to the request's mutable configuration properties
    public var projectedValue: FirebaseFirestoreSwift.FirestoreQuery<Result<[Entity], Error>>.Configuration {
        self.$entity
    }
    
    /// The query's predicates.
    public var predicates: [FirebaseFirestoreSwift.QueryPredicate] {
        get {
            self.$entity.predicates
        }
        set {
            self.$entity.predicates = newValue
        }
    }
    
    /// The error, if any.
    public var error: Error? {
        if case .failure(let error) = self.entity {
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
    public init(
        context: Entity.CollectionReferenceContext,
        predicates: [FirebaseFirestoreSwift.QueryPredicate] = .init()
    ) {
        self._entity = .init(
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

public extension FirestoreEntityQuery where Entity.CollectionReferenceContext == Void {
    
    /// Creates a new instance of `FirestoreEntityQuery`
    /// - Parameters:
    ///   - predicates: An array of `QueryPredicate`s that defines a filter for the fetched results. Default value `.init()`
    init(
        predicates: [FirebaseFirestoreSwift.QueryPredicate] = .init()
    ) {
        self._entity = .init(
            collectionPath: Entity
                .collectionReference(context: ())
                .path,
            predicates: predicates
        )
    }
    
}
