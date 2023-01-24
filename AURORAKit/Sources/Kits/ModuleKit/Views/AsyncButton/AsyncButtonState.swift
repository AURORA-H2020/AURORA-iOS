import SwiftUI

// MARK: - AsyncButtonState

/// An AsyncButtonState
public enum AsyncButtonState: String, Codable, Hashable, CaseIterable {
    /// Idle
    case idle
    /// Busy
    case busy
}

public extension AsyncButtonState {
    
    struct PreferenceKey: SwiftUI.PreferenceKey {
        
        public static var defaultValue = AsyncButtonState.idle
        
        public static func reduce(
            value: inout AsyncButtonState,
            nextValue: () -> AsyncButtonState
        ) {
            value = nextValue()
        }
        
    }
    
}
