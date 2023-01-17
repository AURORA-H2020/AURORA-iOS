import Combine
import SwiftUI

// MARK: - View+delay

public extension View {
    
    /// Delay the appearance of the view by a given duration.
    /// - Parameters:
    ///   - duration: The duration.
    ///   - animation: The animation.
    func delay(
        by duration: Measurement<UnitDuration>,
        animation: Animation? = nil
    ) -> some View {
        self.modifier(
            DelayViewModifier(
                duration: duration,
                animation: animation
            )
        )
    }
    
}

// MARK: - DelayViewModifier

/// A Delay ViewModifier
private struct DelayViewModifier: ViewModifier {
    
    // MARK: Properties
    
    /// The duration.
    let duration: Measurement<UnitDuration>
    
    /// The animation.
    let animation: Animation?
    
    /// Bool value if is visible
    @State
    private var isVisible = false
    
    // MARK: ViewModifier
    
    /// Gets the current body of the caller.
    /// - Parameter content: The content.
    func body(
        content: Content
    ) -> some View {
        content
            .opacity(self.isVisible ? 1 : 0)
            .disabled(!self.isVisible)
            .onReceive(
                self.isVisible
                    ? Empty()
                        .eraseToAnyPublisher()
                    : Timer
                        .publish(
                            every: .init(self.duration.converted(to: .seconds).value),
                            on: .main,
                            in: .common
                        )
                        .autoconnect()
                        .eraseToAnyPublisher()
            ) { _ in
                guard !self.isVisible else {
                    return
                }
                withAnimation(self.animation) {
                    self.isVisible.toggle()
                }
            }
    }
    
}
