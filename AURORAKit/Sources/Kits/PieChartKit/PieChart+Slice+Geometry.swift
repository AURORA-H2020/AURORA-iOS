import SwiftUI

// MARK: - PieChart+Slice+Geometry

extension PieChart.Slice {
    
    /// A geometry pie chart slice data model
    struct Geometry: Hashable, Identifiable {
        
        /// The identifier
        var id: ID {
            self.rawValue.id
        }
        
        /// The slice.
        let rawValue: PieChart<ID>.Slice
        
        /// The starting angle.
        let start: Angle
        
        /// The ending angle.
        let end: Angle
        
    }
    
}
