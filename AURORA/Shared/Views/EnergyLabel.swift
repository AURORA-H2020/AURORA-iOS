import SwiftUI

// MARK: - EnergyLabel

/// An energy label based on the following specification:
/// https://www.aurora-h2020.eu/wp-content/uploads/2022/09/D1.1-Near-Zero-Emission-Citizens-Label-PU.pdf
struct EnergyLabel {

    /// The label.
    let label: ConsumptionSummary.Label?
    
    /// The direction. Default value `.trailing`
    var direction: Direction = .trailing
    
}

// MARK: - Direction

extension EnergyLabel {
    
    /// A direction.
    enum Direction: String, Hashable, CaseIterable, Sendable {
        /// Leading.
        case leading
        /// Trailing.
        case trailing
    }
    
}

// MARK: - View

extension EnergyLabel: View {
    
    /// The content and behavior of the view
    var body: some View {
        GeometryReader { geometry in
            ArrowShape()
                .scale(
                    x: self.direction == .leading ? -1 : 1,
                    y: 1,
                    anchor: .center
                )
                .fill(self.label?.color.flatMap(Color.init) ?? Color.gray)
                .frame(
                    width: geometry.size.width * (self.label?.scaleFactor ?? 0.4),
                    height: 25
                )
                .overlay {
                    Text(
                        self.label?.value ?? "?"
                    )
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .align({
                        switch self.direction {
                        case .leading:
                            return .trailing
                        case .trailing:
                            return .leading
                        }
                    }())
                    .padding(.horizontal, 8)
                }
        }
        .frame(height: 25)
    }
    
}

// MARK: - ArrowShape

private extension EnergyLabel {
    
    /// An arrow shape.
    struct ArrowShape: Shape {
        
        /// Describes this shape as a path within a rectangular frame of reference.
        /// - Parameter rect: The frame of reference for describing this shape.
        /// - Returns: A path that describes this shape.
        func path(
            in rect: CGRect
        ) -> Path {
            let xOffset: CGFloat = 15
            var path = Path()
            path.move(to: .zero)
            path.addLine(to: .init(x: rect.size.width - xOffset, y: 0))
            path.addLine(to: .init(x: rect.size.width, y: rect.size.height / 2))
            path.addLine(to: .init(x: rect.size.width - xOffset, y: rect.size.height))
            path.addLine(to: .init(x: 0, y: rect.size.height))
            path.addLine(to: .init(x: 0, y: rect.size.height))
            path.closeSubpath()
            return path
        }
        
    }
    
}

// MARK: - ConsumptionSummary+Label+scaleFactor

private extension ConsumptionSummary.Label {
    
    /// The scale factor, if any.
    var scaleFactor: Double? {
        switch self {
        case .aPlus:
            return 0.2
        case .a:
            return 0.3
        case .b:
            return 0.4
        case .c:
            return 0.5
        case .d:
            return 0.6
        case .e:
            return 0.7
        case .f:
            return 0.8
        case .g:
            return 0.9
        default:
            return nil
        }
    }
    
}
