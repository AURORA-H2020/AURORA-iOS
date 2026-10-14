import SwiftUI

// MARK: - Button+init(destination:)

extension Button {
    
    /// Creates a button that displays a custom label and opens the given URL.
    /// - Parameters:
    ///   - application: The application. Default value `nil`, which resolves to `.shared`
    ///   - destination: The destination url.
    ///   - label: The label
    init(
        application: UIApplication? = nil,
        destination: @autoclosure @escaping () -> URL,
        @ViewBuilder
        label: () -> Label
    ) {
        self.init {
            (application ?? .shared).open(destination())
        } label: {
            label()
        }
    }
    
}
