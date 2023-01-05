import FirebaseKit
import SwiftUI

// MARK: - App

/// An App
open class App {
    
    // MARK: Properties
    
    /// The Firebase Instance
    private let firebase: Firebase = .default
    
    // MARK: Initializer
    
    /// Creates a new instance of `App`
    public required init() {}
    
}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    
    /// The content and behavior of the app.
    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.firebase)
        }
    }
    
}
