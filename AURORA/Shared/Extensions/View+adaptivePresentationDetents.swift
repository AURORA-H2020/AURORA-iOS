import SwiftUI

// MARK: - AdaptivePresentationDetents

/// An adapative presentation detent
enum AdaptivePresentationDetent: Hashable, Sendable {
    /// The system detent for a sheet that's approximately half the height of the screen.
    case medium
    /// The system detent for a sheet at full height.
    case large
    /// A custom detent with the specified fractional height.
    case fraction(CGFloat)
    /// A custom detent with the specified height.
    case height(CGFloat)
}

// MARK: - View+adaptivePresentationDetents

extension View {
    
    /// Sets the available detents for the enclosing sheet, if available.
    /// - Parameter detents: A set of supported detents for the sheet.
    @ViewBuilder
    func adaptivePresentationDetents(
        _ detents: Set<AdaptivePresentationDetent>
    ) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents(
                .init(
                    detents.map { detent in
                        switch detent {
                        case .large:
                            return .large
                        case .medium:
                            return .medium
                        case .fraction(let fraction):
                            return .fraction(fraction)
                        case .height(let height):
                            return .height(height)
                        }
                    }
                )
            )
        } else {
            self
        }
    }
    
}
