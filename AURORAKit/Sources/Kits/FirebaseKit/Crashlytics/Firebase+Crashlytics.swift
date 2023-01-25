import FirebaseCrashlytics
import Foundation

// MARK: - Firebase+Crashlytics

public extension Firebase {
    
    /// The Firebase Crashlytics
    struct Crashlytics {
        
        /// The Firebase Crashlytics instance.
        let crashlytics: FirebaseCrashlytics.Crashlytics
        
    }
    
}

// MARK: - Record Error

public extension Firebase.Crashlytics {
    
    /// Records a non-fatal event described by an Error.
    /// - Parameters:
    ///   - error: The non-fatal Error which should be recorded.
    ///   - userInfo: The optional user infos. Default value `nil`
    func record(
        error: Error,
        userInfo: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.crashlytics
            .record(
                error: error,
                userInfo: {
                    var userInfo = userInfo ?? .init()
                    userInfo["File"] = file
                    userInfo["Function"] = function
                    userInfo["Line"] = line
                    return userInfo
                }()
            )
    }
    
}
