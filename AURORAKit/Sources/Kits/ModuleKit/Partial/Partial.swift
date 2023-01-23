import Foundation

// MARK: - Partial

/// A generic Partial type.
@dynamicMemberLookup
public struct Partial<Wrapped> {
    
    // MARK: Typealias
    
    /// The partial values.
    public typealias Values = [PartialKeyPath<Wrapped>: Any]
    
    // MARK: Properties

    /// The partial values.
    private var values: Values
    
    // MARK: Initializer
    
    /// Creates a new instance of `Partial`
    /// - Parameter values: The partial values. Default value `.init()`
    public init(
        values: Values = .init()
    ) {
        self.values = values
    }

}

// MARK: - DynamicMemberLookup

public extension Partial {
    
    /// Get or set a value for a given key path
    /// - Parameter keyPath: The key path.
    subscript<Value>(
        dynamicMember keyPath: KeyPath<Wrapped, Value>
    ) -> Value? {
        get {
            self.values[keyPath] as? Value
        }
        set {
            if let newValue = newValue {
                self.values[keyPath] = newValue
            } else {
                self.values.removeValue(forKey: keyPath)
            }
        }
    }
    
}

// MARK: - Error

public extension Partial {
    
    /// A Partial Error.
    enum Error<Value>: Swift.Error {
        /// KeyPath is missing.
        case keyPathMissing(KeyPath<Wrapped, Value>)
        /// Mismatching value type.
        case mismatchingValueType(
            KeyPath<Wrapped, Value>,
            value: Any
        )
    }
    
}

// MARK: - CallAsFunction

public extension Partial {
    
    /// Call partial as function to retrieve the value for a given key path or throws an `Error`.
    /// - Parameter keyPath: The key path.
    func callAsFunction<Value>(
        _ keyPath: KeyPath<Wrapped, Value>
    ) throws -> Value {
        guard let partialValue = self.values[keyPath] else {
            throw Error.keyPathMissing(keyPath)
        }
        guard let value = partialValue as? Value else {
            throw Error.mismatchingValueType(
                keyPath,
                value: partialValue
            )
        }
        return value
    }
    
    /// Call partial as function to convert it to the `Wrapped` type, if possible.
    /// - Parameter transform: A closure returning an optional instance of `Wrapped`.
    func callAsFunction(
        _ transform: (Self) throws -> Wrapped?
    ) rethrows -> Wrapped? {
        try transform(self)
    }
    
    /// Call partial as function to initialize an instance of `Wrapped`.
    func callAsFunction() throws -> Wrapped where Wrapped: PartialConvertible {
        try .init(partial: self)
    }
    
}

// MARK: - Count

public extension Partial {
    
    /// The number of partial values.
    var count: Int {
        self.values.count
    }
    
}

// MARK: - Contains

public extension Partial {
    
    /// Returns a Boolean value that indicates whether a given key path exists.
    /// - Parameter keyPath: The key path.
    func contains(
        _ keyPath: PartialKeyPath<Wrapped>
    ) -> Bool {
        self.values[keyPath] != nil
    }
    
}

// MARK: - Remove Value

public extension Partial {
    
    /// Removes the partial value.
    /// - Parameter keyPath: The key path.
    @discardableResult
    mutating func removeValue(
        for keyPath: PartialKeyPath<Wrapped>
    ) -> Any? {
        self.values.removeValue(forKey: keyPath)
    }
    
}

// MARK: - Remove All

public extension Partial {
    
    /// Removes all partial values.
    mutating func removeAll() {
        self.values.removeAll()
    }
    
}
