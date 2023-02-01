import SwiftUI

// MARK: - AsyncButtonState

/// An AsyncButtonState
enum AsyncButtonState: String, Codable, Hashable, CaseIterable {
    /// Idle
    case idle
    /// Busy
    case busy
}

extension AsyncButtonState {
    
    struct PreferenceKey: SwiftUI.PreferenceKey {
        
        static var defaultValue = AsyncButtonState.idle
        
        static func reduce(
            value: inout AsyncButtonState,
            nextValue: () -> AsyncButtonState
        ) {
            value = nextValue()
        }
        
    }
    
}
