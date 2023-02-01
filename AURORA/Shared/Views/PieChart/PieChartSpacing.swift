import SwiftUI

// MARK: - PieChartSpacing

/// A PieChart Spacing data model.
struct PieChartSpacing: Hashable {
    
    // MARK: Properties
    
    /// The width.
    var width: Double
    
    /// The color.
    var color: Color
    
    // MARK: Initializer
    
    /// Creates a new instance of `PieChartSpacing`
    /// - Parameters:
    ///   - width: The width.
    ///   - color: The color. Default value `.systemBackground`
    init(
        width: Double,
        color: Color = .init(.systemBackground)
    ) {
        self.width = width
        self.color = color
    }
    
}

// MARK: - ExpressibleByFloatLiteral

extension PieChartSpacing: ExpressibleByFloatLiteral {
    
    /// Creates a new instance of `PieChartSpacing`
    /// - Parameter width: The width float literal value.
    init(
        floatLiteral width: Double
    ) {
        self.init(width: width)
    }
    
}

// MARK: - ExpressibleByIntegerLiteral

extension PieChartSpacing: ExpressibleByIntegerLiteral {
    
    /// Creates a new instance of `PieChartSpacing`
    /// - Parameter width: The width integer literal value.
    init(
        integerLiteral width: Int
    ) {
        self.init(width: .init(width))
    }
    
}
