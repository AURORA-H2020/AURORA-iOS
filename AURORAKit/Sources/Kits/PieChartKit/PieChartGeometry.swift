import Foundation

// MARK: - PieChartGeometry

/// A Pie Chart Geometry helper
enum PieChartGeometry {}

// MARK: - Calculate

extension PieChartGeometry {
    
    /// Calculate geometry from slices
    /// - Parameter slices: The slices.
    static func calculate<ID: Hashable>(
        using slices: [PieChart<ID>.Slice]
    ) -> [PieChart<ID>.Slice.Geometry] {
        // Calculate the sum of all slices
        let sum = slices.map(\.value).reduce(0, +)
        // Verify the sum is greater zero
        guard sum > 0 else {
            // Otherwise return an empty array
            return .init()
        }
        // Calculate the degree per slice
        let degreePerSlice = 360.0 / sum
        // Initialize a mutable angle starting a -90 degrees
        var angle: Double = -90.0
        // Map slices
        return slices
            .sorted { $0.value > $1.value }
            .map { slice in
                // Calculate the ending angle
                let endAngle = degreePerSlice * slice.value + angle
                // Defer
                defer {
                    // Update angle with ending angle.
                    angle = endAngle
                }
                // Return pie chart slice
                return .init(
                    rawValue: slice,
                    start: .init(degrees: angle),
                    end: .init(degrees: endAngle)
                )
            }
    }
    
}
