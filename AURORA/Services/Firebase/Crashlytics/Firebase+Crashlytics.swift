import FirebaseCrashlytics
import Foundation

// MARK: - Firebase+Crashlytics

extension Firebase {
    
    /// The Firebase Crashlytics
    struct Crashlytics {
        
        /// The Firebase Crashlytics instance.
        let crashlytics: FirebaseCrashlytics.Crashlytics
        
    }
    
}

// MARK: - Record Error

extension Firebase.Crashlytics {
    
    /// Records a non-fatal event described by an Error.
    /// - Parameters:
    ///   - error: The non-fatal Error which should be recorded.
    ///   - userInfo: The optional user infos. Default value `nil`
    ///   - file: The file. Default value `#file`
    ///   - function: The function. Default value `#function`
    ///   - line: The line. Default value `#line`
    func record(
        error: Error,
        userInfo: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Verify error is not a CancellationError
        guard !(error is CancellationError) else {
            // Otherwise return out of function
            // as CancellationError shouldn't be recorded.
            return
        }
        #if DEBUG
        // Check if collection is disabled
        if !self.crashlytics.isCrashlyticsCollectionEnabled() {
            print(
                "[Crashlytics]",
                "\(error)",
                "File: \(file)",
                "Function: \(function)",
                "Line: \(line)",
                userInfo ?? .init()
            )
        }
        #endif
        // Record error
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
    
    /// Records a non-fatal Error which may occur
    /// when executing the given asynchronous operation.
    /// - Parameters:
    ///   - userInfo: The optional user infos. Default value `nil`
    ///   - file: The file. Default value `#file`
    ///   - function: The function. Default value `#function`
    ///   - line: The line. Default value `#line`
    ///   - operation: An asynchronous closure to execute.
    @discardableResult
    func recordError<Result>(
        userInfo: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        operation: () async throws -> Result
    ) async rethrows -> Result {
        do {
            return try await operation()
        } catch {
            self.record(
                error: error,
                userInfo: userInfo,
                file: file,
                function: function,
                line: line
            )
            throw error
        }
    }
    
    /// Records a non-fatal Error which may occur
    /// when executing the given synchronous operation.
    /// - Parameters:
    ///   - userInfo: The optional user infos. Default value `nil`
    ///   - file: The file. Default value `#file`
    ///   - function: The function. Default value `#function`
    ///   - line: The line. Default value `#line`
    ///   - operation: A synchronous closure to execute.
    @discardableResult
    func recordError<Result>(
        userInfo: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        operation: () throws -> Result
    ) rethrows -> Result {
        do {
            return try operation()
        } catch {
            self.record(
                error: error,
                userInfo: userInfo,
                file: file,
                function: function,
                line: line
            )
            throw error
        }
    }
    
}
