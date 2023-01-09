import Foundation

// MARK: - AsyncButtonState

/// An AsyncButtonState
public enum AsyncButtonState: String, Codable, Hashable, CaseIterable {
    /// Idle
    case idle
    /// Busy
    case busy
}
