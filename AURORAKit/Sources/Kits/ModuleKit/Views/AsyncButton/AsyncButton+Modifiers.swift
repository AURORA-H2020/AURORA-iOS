import Foundation

// MARK: - AsyncButton+map

private extension AsyncButton {
    
    /// Transform this AsyncButton instance using a value, if available.
    /// - Parameters:
    ///   - value: The value.
    ///   - transform: A mapping closure.
    /// - Returns: The transformed AsyncButton.
    func map<Value>(
        using value: Value?,
        _ transform: (Value, inout Self) -> Void
    ) -> Self {
        // Verify value is available
        guard let value = value else {
            // Otherwise return non mutated AsyncButton
            return self
        }
        // Initialize a mutable AsyncButton
        var asyncButton = self
        // Transform mutable AsyncButton
        transform(value, &asyncButton)
        // Return mutated AsyncButton
        return asyncButton
    }
    
}

// MARK: - AsyncButton+taskPriority

public extension AsyncButton {
    
    /// Sets the TaskPriority
    /// - Parameter taskPriority: The TaskPriority. When passing nil, the call has no effect.
    func taskPriority(
        _ taskPriority: TaskPriority? = nil
    ) -> Self {
        self.map(
            using: taskPriority
        ) { taskPriority, asyncButton in
            asyncButton.taskPriority = taskPriority
        }
    }
    
}

// MARK: - AsyncButton+hapticFeedbackEnabled

public extension AsyncButton {
    
    /// Sets the bool value  if HapticFeedback is enabled
    /// - Parameter isHapticFeedbackEnabled: Bool value if HapticFeedback is enabled.
    /// When passing nil, the call has no effect.
    func hapticFeedbackEnabled(
        _ isHapticFeedbackEnabled: Bool? = nil
    ) -> Self {
        self.map(
            using: isHapticFeedbackEnabled
        ) { isHapticFeedbackEnabled, asyncButton in
            asyncButton.isHapticFeedbackEnabled = isHapticFeedbackEnabled
        }
    }
    
}

// MARK: - AsyncButton+autoProgressViewEnabled

public extension AsyncButton {
    
    /// Sets the bool value if automatically showing a progress view is enabled.
    /// - Parameter isAutoProgressViewEnabled: The bool value if enabled or disabled.
    /// When passing nil, the call has no effect.
    func autoProgressViewEnabled(
        _ isAutoProgressViewEnabled: Bool? = nil
    ) -> Self {
        self.map(
            using: isAutoProgressViewEnabled
        ) { isAutoProgressViewEnabled, asyncButton in
            asyncButton.isAutoProgressViewEnabled = isAutoProgressViewEnabled
        }
    }
    
}

// MARK: - AsyncButton+confirmationDialog

public extension AsyncButton {
    
    /// Sets the confirmation dialog.
    /// - Parameter confirmationDialogProvider: A closure to show a confirmation dialog
    /// When passing nil, the call has no effect.
    func confirmationDialog(
        _ confirmationDialogProvider: ConfirmationDialogProvider? = nil
    ) -> Self {
        self.map(
            using: confirmationDialogProvider
        ) { confirmationDialogProvider, asyncButton in
            asyncButton.confirmationDialogProvider = confirmationDialogProvider
        }
    }
    
}

// MARK: - AsyncButton+alert

public extension AsyncButton {
    
    /// Sets the alert.
    /// - Parameter alertProvider: A closure to show an alert after the action finishes
    /// When passing nil, the call has no effect.
    func alert(
        _ alertProvider: AlertProvider? = nil
    ) -> Self {
        self.map(
            using: alertProvider
        ) { alertProvider, asyncButton in
            asyncButton.alertProvider = alertProvider
        }
    }
    
}
