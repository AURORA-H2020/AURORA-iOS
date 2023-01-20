import Foundation

// MARK: - PartialConvertible

/// A Partial convertible type
public protocol PartialConvertible {
    
    /// Creates a new instance from `Partial`.
    /// - Parameter partial: The partial instance.
    init(partial: Partial<Self>) throws
    
}
