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
        guard Firebase.configure() else {
            // Otherwise return false
            return false
        }
        // Prepare application
        self.prepare(application: application)
        return true
    }
    
}

// MARK: - Prepare Application

private extension AppDelegate {
    
    /// Prepare application.
    /// - Parameter application: The UIApplication.
    func prepare(
        application: UIApplication
    ) {
        // Check if app is running an ui tests environment
        if ProcessInfo.processInfo.arguments.contains("UITests") {
            // Disable animations
            UIView.setAnimationsEnabled(false)
        }
        // Check if email and password are available
        if let email = UserDefaults.standard.string(forKey: "ui_test_login_email"),
           !email.isEmpty,
           let password = UserDefaults.standard.string(forKey: "ui_test_login_password"),
           !password.isEmpty {
            // Logout
            try? self.firebase.authentication.logout()
            // Login
            Task {
                try? await self.firebase
                    .authentication
                    .login(
                        using: .password(
                            method: .login,
                            email: email,
                            password: password
                        )
                    )
            }
        }
    }
    
}
