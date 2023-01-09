import SwiftUI

public extension View {
    
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

private struct ClosureEquatable<Value>: Equatable {
    
    let value: Value
    
    let predicate: (Value, Value) -> Bool
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.predicate(lhs.value, rhs.value)
    }
    
}
