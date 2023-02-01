import Foundation

// MARK: - Collection+Safe

extension Collection {
    
    /// Retrieve an Element at the specified index if it is withing bounds, otherwise return nil.
    /// - Parameter index: The Index
    subscript(
        safe index: Index
    ) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
    
}
