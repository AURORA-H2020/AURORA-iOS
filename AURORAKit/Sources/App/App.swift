import FirebaseKit
import SwiftUI

// MARK: - App

/// An App
open class App {
    
    // MARK: Properties
    
    /// The AppDelegate
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
                .environmentObject(Firebase.default)
        }
    }
    
}

// MARK: - AppDelegate

extension App {
    
    /// The AppDelegate
    final class AppDelegate: NSObject, UIApplicationDelegate {
        
        /// UIApplication did finish launching with options.
        /// - Parameters:
        ///   - application: The UIApplication.
        ///   - launchOptions: The launch options.
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            // Configure Firebase
            Firebase.configure()
            return true
        }
        
    }
    
}
