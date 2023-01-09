import SwiftUI

public extension View {
    
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

private struct DelayViewModifier: ViewModifier {
    
    let duration: Measurement<UnitDuration>
    
    let animation: Animation?
    
    @State
    private var isVisible = false
    
    func body(content: Content) -> some View {
        if self.isVisible {
            content
        } else {
            content
                .hidden()
                .onReceive(
                    Timer
                        .publish(
                            every: .init(
                                self.duration
                                    .converted(to: .seconds)
                                    .value
                            ),
                            on: .main,
                            in: .common
                        )
                        .autoconnect()
                ) { _ in
                    guard !self.isVisible else {
                        return
                    }
                    withAnimation(self.animation) {
                        self.isVisible = true
                    }
                }
        }
    }
    
}
