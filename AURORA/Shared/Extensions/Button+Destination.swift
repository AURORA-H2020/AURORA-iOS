import SwiftUI

// MARK: - Button+init(destination:)

extension Button {
    
    /// Creates a button that displays a custom label and opens the given URL.
    /// - Parameters:
    ///   - application: The application. Default value `.shared`
    ///   - destination: The destination url.
    ///   - label: The label
    init(
        application: UIApplication = .shared,
        destination: @autoclosure @escaping () -> URL,
        @ViewBuilder
        label: () -> Label
    ) {
        self.init {
            application.open(destination())
        } label: {
            label()
        }
    }
    
}
