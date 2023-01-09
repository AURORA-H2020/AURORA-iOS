import SwiftUI

// MARK: - AsyncButton+AdaptiveProgressView

extension AsyncButton {
    
    /// An adaptive ProgressView
    struct AdaptiveProgressView {}
    
}

// MARK: - View

extension AsyncButton.AdaptiveProgressView: View {
    
    /// The content and behavior of the view
    var body: some View {
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *) {
            ProgressView()
        } else {
            #if os(iOS) || os(tvOS)
            UIActivityIndicatorRepresentable()
            #else
            // On watchOS < 7.0:
            // No system defined component available
            // to show a progress indicator
            EmptyView()
            #endif
        }
    }
    
}

#if os(iOS) || os(tvOS)
/// A SwiftUI UIActivityIndicator representable view.
private struct UIActivityIndicatorRepresentable: UIViewRepresentable {
    
    /// Make UIActivityIndicatorView
    /// - Parameter context: The Context
    func makeUIView(
        context: Context
    ) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    /// Update UIActivityIndicatorView
    /// - Parameters:
    ///   - activityIndicatorView: The UIActivityIndicatorView
    ///   - context: The Context
    func updateUIView(
        _ activityIndicatorView: UIActivityIndicatorView,
        context: Context
    ) {}
    
    /// Dismantle UIActivityIndicatorView
    /// - Parameters:
    ///   - activityIndicatorView: The UIActivityIndicatorView
    ///   - coordinator: The Coordinator
    static func dismantleUIView(
        _ activityIndicatorView: UIActivityIndicatorView,
        coordinator: Coordinator
    ) {
        activityIndicatorView.stopAnimating()
    }
    
}
#endif
