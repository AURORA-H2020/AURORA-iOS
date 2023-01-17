import SwiftUI

// MARK: - PieChart+Slice

public extension PieChart {
    
    /// A pie chart slice data model.
    struct Slice: Hashable, Identifiable {
        
        // MARK: Properties
        
        /// The identifier.
        public let id: ID
        
        /// The value.
        public let value: Double
        
        /// The color.
        public let color: Color
        
        // MARK: Initializer
        
        /// Creates a new instance of `PieChart.Slice`
        /// - Parameters:
        ///   - id: The identifier.
        ///   - value: The value.
        ///   - color: The color. Default value `.accentColor`
        public init(
            id: ID,
            value: Double,
            color: Color = .accentColor
        ) {
            self.id = id
            self.value = value
            self.color = color
        }
        
    }
    
}

// MARK: - PieChart<String>+Slice+init

public extension PieChart.Slice where ID == String {
    
    /// Creates a new instance of `PieChart.Slice`
    /// using a random UUIDv4 as identifier.
    /// - Parameters:
    ///   - value: The value.
    ///   - color: The color. Default value `.accentColor`
    init(
        value: Double,
        color: Color = .accentColor
    ) {
        self.init(
            id: UUID().uuidString,
            value: value,
            color: color
        )
    }
    
}
