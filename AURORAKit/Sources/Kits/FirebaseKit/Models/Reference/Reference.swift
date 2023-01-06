import Foundation

// MARK: - Reference

/// A Reference
public struct Reference<Destination: Identifiable>: Hashable, Identifiable {
    
    // MARK: Properties
    
    /// The identifier.
    public var id: String
    
    // MARK: Initializer
    
    /// Creates a new instance of `Reference`
    /// - Parameter id: The identifier.
    public init(
        id: String
    ) {
        self.id = id
    }
    
}

// MARK: - Reference+init(destination:)

public extension Reference {
    
    /// Creates a new instance of `Reference`, if available
    /// - Parameter destination: The Destination.
    init?(
        _ destination: Destination
    ) where Destination.ID == Self.ID? {
        guard let id = destination.id else {
            return nil
        }
        self.init(id: id)
    }
    
}

// MARK: - Reference+ExpressibleByStringLiteral

extension Reference: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `Reference`
    /// - Parameter id: The string literal identifier
    public init(
        stringLiteral id: String
    ) {
        self.init(id: id)
    }
    
}

// MARK: - Reference+Codable

extension Reference: Codable {
    
    /// Creates a new instance of `Codable`
    /// - Parameter decoder: The Decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            id: try container.decode(String.self)
        )
    }
    
    /// Encode to Encoder
    /// - Parameter encoder: The Encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
    
}
