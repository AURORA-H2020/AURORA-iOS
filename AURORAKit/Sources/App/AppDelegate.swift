import FirebaseKit
import UIKit

// MARK: - AppDelegate

/// The AppDelegate
final class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// The Firebase instance.
    private(set) lazy var firebase: Firebase = .default
    
}

// MARK: - Did finish launching with options

extension AppDelegate {
    
    /// UIApplication did finish launching with options
    /// - Parameters:
    ///   - application: The UIApplication.
    ///   - launchOptions: The launch options.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        // Firebase gets configured during `didFinishLaunchingWithOptions` lifecycle
        // as some Firebase products rely on swizzling which is not supported
        // when configuring Firebase during the initialization of a `SwiftUI.App`
        // - Read more: https://firebase.google.com/docs/ios/learn-more#app_delegate_swizzling
        Firebase.configure()
        return true
    }
    
}
