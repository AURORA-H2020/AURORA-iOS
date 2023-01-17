import SwiftUI

// MARK: - View+animation

public extension View {
    
    /// Applies the given animation to this view when the specified value changes.
    /// - Parameters:
    ///   - animation: The animation to apply. If animation is nil, the view doesn’t animate.
    ///   - value: A value to monitor for changes.
    ///   - predicate: A closure to evaluate whether two elements are equivalent.
    func animation<Value>(
        _ animation: Animation?,
        value: Value,
        by predicate: @escaping (Value, Value) -> Bool
    ) -> some View {
        self.animation(
            animation,
            value: ClosureEquatable(
                value: value,
                predicate: predicate
            )
        )
    }
    
}

// MARK: - ClosureEquatable

/// A closure based equatable data model
private struct ClosureEquatable<Value>: Equatable {
    
    // MARK: Properties
    
    /// The value
    let value: Value
    
    /// The predicate.
    let predicate: (Value, Value) -> Bool
    
    // MARK: Equatable
    
    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.predicate(lhs.value, rhs.value)
    }
    
}
