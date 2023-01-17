import FirebaseKit
import SwiftUI

// MARK: - App

/// An App
open class App {
    
    // MARK: Properties
    
    /// The Firebase instance.
    private let firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `App`
    public required init() {
        self.firebase = .default
    }
    
}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    
    /// The content and behavior of the app.
    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.firebase)
                .onOpenURL { url in
                    self.firebase.handle(opened: url)
                }
        }
    }
    
}
