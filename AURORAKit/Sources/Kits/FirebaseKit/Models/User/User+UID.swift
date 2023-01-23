import Foundation

// MARK: - User+UID

public extension User {
    
    /// A User unique identifier
    struct UID: Hashable, Identifiable, Sendable {
        
        // MARK: Properties
        
        /// The identifier.
        public let id: String
        
        // MARK: Initializer
        
        /// Creates a new instance of `User.UID`
        /// - Parameter id: The identifier
        public init(
            _ id: String
        ) {
            self.id = id
        }
        
    }
    
}

// MARK: - Current

public extension User.UID {
    
    /// Retrieve the current User unique identifier or throws an error.
    /// - Parameter firebase: The Firebase instance. Default value `.default`
    static func current(
        firebase: Firebase = .default
    ) throws -> Self {
        .init(
            try firebase
                .authentication
                .state
                .userAccount
                .uid
        )
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension User.UID: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `User.UID`
    /// - Parameter id: The identifier
    public init(
        stringLiteral id: String
    ) {
        self.init(id)
    }
    
}

// MARK: - Codable

extension User.UID: Codable {
    
    /// Creates a new instance of `User.UID`
    /// - Parameter decoder: The Decoder
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(String.self))
    }
    
    /// Encode
    /// - Parameter encoder: The Encoder
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
    
}
