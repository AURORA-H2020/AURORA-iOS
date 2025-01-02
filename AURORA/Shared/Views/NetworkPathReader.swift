import Network
import SwiftUI

// MARK: - NetworkPathReader

/// A NetworkPathReader
struct NetworkPathReader<Content: View> {
    
    // MARK: Properties
    
    /// A closure providing the content for a network path
    private let content: (NWPath?) -> Content
    
    /// The monitor.
    @StateObject
    private var monitor = Monitor()
    
    // MARK: Initializer
    
    /// Creates a new instance of ``NetworkPathReader``
    /// - Parameter content: A closure providing the content for a network path
    init(
        @ViewBuilder
        content: @escaping (NWPath?) -> Content
    ) {
        self.content = content
    }
    
}

// MARK: - Unsatisfied Warning

extension NetworkPathReader where Content == Text? {
    
    /// A network path reader view which displays an information text in case the path is unsatisfied.
    static let unsatisfiedWarning = Self { path in
        if path?.status != .satisfied {
            Text(
                "It seems you're offline. Your data will automatically sync as soon as you reconnect to the internet."
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
}

// MARK: - View

extension NetworkPathReader: View {
    
    /// The content and behavior of the view.
    var body: some View {
        self.content(self.monitor.path)
    }
    
}

// MARK: - Monitor

private extension NetworkPathReader {
    
    /// A monitor.
    final class Monitor: ObservableObject {
        
        // MARK: Properties
        
        /// The current network path.
        @Published
        private(set) var path: NWPath?
        
        /// The network path monitor.
        private let networkPathMonitor = NWPathMonitor()
        
        // MARK: Initializer
        
        /// Creates a new instance of ``NetworkPathReader.Monitor``
        init() {
            self.networkPathMonitor.pathUpdateHandler = { [weak self] path in
                self?.path = path
            }
            self.networkPathMonitor.start(queue: .main)
        }
        
        /// Deinit
        deinit {
            self.networkPathMonitor.cancel()
        }
        
    }
    
}
