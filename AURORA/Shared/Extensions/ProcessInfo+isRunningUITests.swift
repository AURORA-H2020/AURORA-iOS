import Foundation

// MARK: - ProcessInfo+isRunningUITests

extension ProcessInfo {
    
    /// Bool value if the process is running in an UI test.
    var isRunningUITests: Bool {
        self.arguments.contains("UITests")
    }
    
}
