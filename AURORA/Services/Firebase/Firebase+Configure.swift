import Firebase
import FirebaseAnalytics
import FirebaseAppCheck
import FirebaseCrashlytics
import FirebasePerformance
import Foundation

// MARK: - Configure

extension Firebase {
    
    /// Bool value if Firebase is configured.
    private(set) static var isConfigured = false
    
    /// Configure FIrebase
    /// - Parameter bundle: The Bundle. Default value `.main`
    /// - Returns: Returns `true` if Firebase configured successfully and returns `false` if Firebase has already been configured.
    @discardableResult
    static func configure(
        in bundle: Bundle = .main
    ) -> Bool {
        // Verify is not configured
        guard !self.isConfigured else {
            // Otherwise return out of function
            // This way we are preventing any runtime crash
            // when accidentally calling `configure` multiple times.
            return false
        }
        // Toggle is configured
        self.isConfigured.toggle()
        // Initialize bool if is debug
        let isDebug: Bool = {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()
        // Set AppCheckProviderFactory
        FirebaseAppCheck
            .AppCheck
            .setAppCheckProviderFactory(
                AppCheckProviderFactory(
                    isDebug: isDebug
                )
            )
        // Check if the default Firebase options and the bundle identifier are available
        if let firebaseOptions = FirebaseOptions.defaultOptions(),
           let bundleIdentifier = bundle.bundleIdentifier {
            // Set app group identifier
            firebaseOptions.appGroupID = "group.\(bundleIdentifier)"
            // Configure FirebaseApp with options
            FirebaseCore
                .FirebaseApp
                .configure(
                    options: firebaseOptions
                )
        } else {
            // Otherwise configure FirebaseApp without custom options
            FirebaseCore
                .FirebaseApp
                .configure()
        }
        // Use App Language
        FirebaseAuth
            .Auth
            .auth()
            .useAppLanguage()
        // Disable Firebase Analytics for debug builds
        FirebaseAnalytics
            .Analytics
            .setAnalyticsCollectionEnabled(!isDebug)
        // Disable Firebase Crashlytics for debug builds
        FirebaseCrashlytics
            .Crashlytics
            .crashlytics()
            .setCrashlyticsCollectionEnabled(!isDebug)
        // Disable Firebase Performance for debug builds
        FirebasePerformance
            .Performance
            .sharedInstance()
            .isInstrumentationEnabled = !isDebug
        FirebasePerformance
            .Performance
            .sharedInstance()
            .isDataCollectionEnabled = !isDebug
        // Return success
        return true
    }
    
}

// MARK: - AppCheckProviderFactory

private extension Firebase {

    /// The AppCheckProviderFactory
    final class AppCheckProviderFactory: NSObject, FirebaseAppCheck.AppCheckProviderFactory {
        
        // MARK: Properties
        
        /// Bool if is debug.
        let isDebug: Bool
        
        // MARK: Initializer
        
        /// Creates a new instance of `Firebase.AppCheckProviderFactory`
        /// - Parameter isDebug: Bool if is debug.
        init(
            isDebug: Bool
        ) {
            self.isDebug = isDebug
            super.init()
        }
        
        // MARK: AppCheckProviderFactory
        
        /// Creates a new instance of `AppCheckProvider`
        /// - Parameter app: The FirebaseApp
        func createProvider(
            with app: FirebaseCore.FirebaseApp
        ) -> FirebaseAppCheck.AppCheckProvider? {
            if self.isDebug {
                if let debugToken = UserDefaults.standard.string(forKey: "FIRAAppCheckDebugToken") {
                    print("[FirebaseAppCheck] Debug-Token: \(debugToken)")
                }
                return FirebaseAppCheck.AppCheckDebugProvider(app: app)
            } else {
                return FirebaseAppCheck.AppAttestProvider(app: app)
            }
        }
        
    }

}
