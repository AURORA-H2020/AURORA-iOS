import Foundation

// MARK: - ProcessInfo+isRunningUITests

extension ProcessInfo {
    
    /// Bool value if the process is running ui tests.
    var isRunningUITests: Bool {
        self.arguments.contains("UITests")
    }
    
}
