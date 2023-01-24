import SwiftUI

// MARK: - OrientationReader

/// An Orientation Reader
public struct OrientationReader<Content: View> {
    
    // MARK: Properties
    
    /// The transaction to use when the orientation changes.
    private let transaction: Transaction
    
    /// A closure providing the Content for the current UIDeviceOrientation.
    private let content: (UIDeviceOrientation) -> Content
    
    /// The UIDeviceOrientation.
    @State
    private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    // MARK: Initializer
    
    /// Creates a new instancen of `OrientationReader`
    /// - Parameters:
    ///   - transaction: The transaction to use when the orientation changes. Default value `.init()`
    ///   - content: A closure providing the Content for the current UIDeviceOrientation.
    public init(
        transaction: Transaction = .init(),
        @ViewBuilder
        content: @escaping (UIDeviceOrientation) -> Content
    ) {
        self.transaction = transaction
        self.content = content
    }
    
}

// MARK: - Update Orientation

private extension OrientationReader {
    
    /// Update Orientation
    func updateOrientation() {
        withTransaction(self.transaction) {
            self.orientation = UIDevice.current.orientation
        }
    }
    
}

// MARK: - View

extension OrientationReader: View {
    
    /// The content and behavior of the view
    public var body: some View {
        ZStack {
            self.content(self.orientation)
        }
        .onAppear(
            perform: self.updateOrientation
        )
        .onReceive(
            NotificationCenter
                .default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .map { _ in },
            perform: self.updateOrientation
        )
    }
    
}
