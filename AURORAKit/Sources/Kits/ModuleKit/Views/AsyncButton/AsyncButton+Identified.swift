import Foundation

// MARK: - AsyncButton+Identified

extension AsyncButton {
    
    /// A generic identified value
    struct Identified<Value>: Identifiable {
        
        /// The stable identity of the entity associated with this instance
        var id = UUID()
        
        /// The Value
        let value: Value
        
    }
    
}
