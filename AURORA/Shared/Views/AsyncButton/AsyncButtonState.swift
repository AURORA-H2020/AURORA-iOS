import SwiftUI

// MARK: - AsyncButtonState

/// An AsyncButtonState
enum AsyncButtonState: String, Codable, Hashable, CaseIterable {
    /// Idle
    case idle
    /// Busy
    case busy
}

// MARK: - AsyncButtonState+PreferenceKey

extension AsyncButtonState {
    
    /// A SwiftUI AsyncButtonState PreferenceKey
    struct PreferenceKey: SwiftUI.PreferenceKey {
        
        /// The default value of the preference.
        static var defaultValue = AsyncButtonState.idle
        
        /// Combines a sequence of values by modifying the previously-accumulated
        /// value with the result of a closure that provides the next value.
        /// - Parameters:
        ///   - value: The value accumulated through previous calls to this method.
        ///   - nextValue: A closure that returns the next value in the sequence.
        static func reduce(
            value: inout AsyncButtonState,
            nextValue: () -> AsyncButtonState
        ) {
            value = nextValue()
        }
        
    }
    
}
