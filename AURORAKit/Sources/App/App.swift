import FirebaseKit
import SwiftUI

// MARK: - App

/// An App
open class App {
    
    // MARK: Properties
    
    /// The AppDelegate.
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
    
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
                .environmentObject(self.appDelegate.firebase)
                .onOpenURL { url in
                    self.appDelegate.firebase.handle(opened: url)
                }
        }
    }
    
}
