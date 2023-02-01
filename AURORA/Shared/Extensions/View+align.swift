import SwiftUI

// MARK: - ViewAlignment

/// A View Alignment
enum ViewAlignment: String, Codable, Hashable, CaseIterable {
    /// Center alignment.
    /// This alignment combines `centerHorizontal` and `centerVertical`
    case center
    /// Horizontal center alignment.
    case centerHorizontal
    /// Vertical center alignment.
    case centerVertical
    /// Leading alignment.
    case leading
    /// Trailing alignment.
    case trailing
    /// Top alignment.
    case top
    /// Bottom.alignment.
    case bottom
    /// Top leading alignment.
    /// This alignment combines `top` and `leading`
    case topLeading
    /// Top trailing alignment.
    /// This alignment combines `top` and `trailing`
    case topTrailing
    /// Bottom leading alignment.
    /// This alignment combines `bottom` and `leading`
    case bottomLeading
    /// Bottom trailing alignment.
    /// This alignment combines `bottom` and `trailing`
    case bottomTrailing
}

// MARK: - View+align

extension View {
    
    /// Align this View using a given `ViewAlignment`
    /// - Parameter alignment: The ViewAlignment. When passing nil, the call has no effect.
    @ViewBuilder
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func align(
        _ alignment: ViewAlignment?
    ) -> some View {
        switch alignment {
        case .center:
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    self
                    Spacer()
                }
                Spacer()
            }
        case .centerHorizontal:
            HStack {
                Spacer()
                self
                Spacer()
            }
        case .centerVertical:
            VStack {
                Spacer()
                self
                Spacer()
            }
        case .leading:
            HStack {
                self
                Spacer()
            }
        case .trailing:
            HStack {
                Spacer()
                self
            }
        case .top:
            VStack {
                self
                Spacer()
            }
        case .bottom:
            VStack {
                Spacer()
                self
            }
        case .topLeading:
            VStack {
                HStack {
                    self
                    Spacer()
                }
                Spacer()
            }
        case .topTrailing:
            VStack {
                HStack {
                    Spacer()
                    self
                }
                Spacer()
            }
        case .bottomLeading:
            VStack {
                Spacer()
                HStack {
                    self
                    Spacer()
                }
            }
        case .bottomTrailing:
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    self
                }
            }
        case nil:
            self
        }
    }
    
}
