import SwiftUI

// MARK: - PieChart

/// A Pie Chart
public struct PieChart<ID: Hashable> {
    
    // MARK: Properties
    
    /// The geometry slices of the pie chart.
    private let slices: [Slice.Geometry]
    
    /// The optional spacing.
    private let spacing: PieChartSpacing?
    
    /// The slice selection binding.
    @Binding
    private var selection: Slice?
    
    // MARK: Initializer
    
    /// Creates a new instance of `PieChart`
    /// - Parameters:
    ///   - slices: The slices of the pie chart.
    ///   - selection: A binding to the selected slice. Default value `.constant(nil)`
    ///   - spacing: The optional spacing. Default value `nil`
    public init(
        _ slices: [Slice],
        selection: Binding<Slice?> = .constant(nil),
        spacing: PieChartSpacing? = nil
    ) {
        self.slices = PieChartGeometry.calculate(using: slices)
        self.spacing = spacing
        self._selection = selection
    }
    
}

// MARK: - View

extension PieChart: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        GeometryReader { geometry in
            let localFrame = geometry.frame(in: .local)
            let halfWidth = localFrame.size.width / 2
            let halfHeight = localFrame.size.height / 2
            let radius =  min(
                halfWidth,
                halfHeight
            )
            let center = CGPoint(
                x: halfWidth,
                y: halfHeight
            )
            ZStack(alignment: .center) {
                ForEach(self.slices) { slice in
                    let slicePath = Path { path in
                        path.move(
                            to: center
                        )
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: slice.start,
                            endAngle: slice.end,
                            clockwise: false
                        )
                        if self.spacing != nil {
                            path.addLine(
                                to: .init(
                                    x: localFrame.midX,
                                    y: localFrame.midY
                                )
                            )
                        }
                    }
                    slicePath
                        .fill()
                        .foregroundColor(slice.rawValue.color)
                        .overlay(self.spacing.flatMap { slicePath.stroke($0.color, lineWidth: $0.width) })
                        .opacity(self.selection.flatMap { $0 == slice.rawValue ? 1 : 0.2 } ?? 1)
                        .onTapGesture {
                            self.selection = slice.rawValue
                        }
                }
            }
        }
    }
    
}
