import SwiftUI

// MARK: - App

/// The App
@main
struct App {
    
    /// The AppDelegate.
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
    
}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    
    /// The content and behavior of the app.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.appDelegate.firebase)
                .onOpenURL { url in
                    self.appDelegate.firebase.handle(opened: url)
                }
        }
    }
    
}
