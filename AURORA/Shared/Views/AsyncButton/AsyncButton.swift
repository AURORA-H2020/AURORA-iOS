import SwiftUI

// MARK: - AsyncButton

/// A button that asynchronously performs an action
struct AsyncButton<Success, Label: View> {
    
    // MARK: Typealias
    
    /// The Action typealias represeting an async throwable closure
    typealias Action = () async throws -> Success
    
    /// The Alert Provider typealias representing a closure which provides an optional Alert for a Result
    typealias AlertProvider = (Result<Success, Error>) -> Alert?
    
    /// A ConfirmationDialog Provider typealias representing a closure which provides an optional ActionSheet
    typealias ConfirmationDialogProvider = (@escaping () -> Void) -> ActionSheet?
    
    // MARK: Properties
    
    /// The UIImpactFeedbackGenerator
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    /// The UINotificationFeedbackGenerator
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    /// The optional TaskPriority
    var taskPriority: TaskPriority?
    
    /// Bool value if HapticFeedback is enabled
    var isHapticFeedbackEnabled: Bool
    
    /// Bool value if automatically showing a progress view is enabled
    var isAutoProgressViewEnabled: Bool
    
    /// Bool value if the width of the button should be expanded
    var fillWidth: Bool
    
    /// An optional closure to show a confirmation dialog
    var confirmationDialogProvider: ConfirmationDialogProvider?
    
    /// An optional closure to show an alert after the action finishes
    var alertProvider: AlertProvider?
    
    /// The action to perform when the user triggers the button
    private let action: Action
    
    /// A view that describes the purpose of the button's action
    private let label: (AsyncButtonState) -> Label
    
    /// The AsyncButtonState
    @State
    private var state: AsyncButtonState = .idle
    
    /// The Identified ConfirmationDialog ActionSheet
    @State
    private var confirmationDialog: Identified<ActionSheet>?
    
    /// The Identified Alert
    @State
    private var alert: Identified<Alert>?
    
    // MARK: Initializer
    
    /// Creates a new instance of `AsyncButton`
    /// - Parameters:
    ///   - taskPriority: The optional TaskPriority. Default value `nil`
    ///   - isHapticFeedbackEnabled: Bool value if HapticFeedback is enabled. Default value `true`
    ///   - isAutoProgressViewEnabled: Bool value if automatically showing
    ///     a progress view is enabled. Default value `true`
    ///   - fillWidth: Bool value if the width of the button should be expanded. Default value `false`
    ///   - confirmationDialog: An optional closure to show a confirmation dialog. Default value `nil`
    ///   - alert: An optional closure to show an alert after the action finishes. Default value `nil`
    ///   - action: The action to perform when the user triggers the button
    ///   - label: A view that describes the purpose of the button's action which takes in an `AsyncButtonState`
    init(
        taskPriority: TaskPriority? = nil,
        isHapticFeedbackEnabled: Bool = true,
        isAutoProgressViewEnabled: Bool = true,
        fillWidth: Bool = false,
        confirmationDialog: ConfirmationDialogProvider? = nil,
        alert: AlertProvider? = nil,
        action: @escaping Action,
        @ViewBuilder
        label: @escaping (AsyncButtonState) -> Label
    ) {
        self.taskPriority = taskPriority
        self.isHapticFeedbackEnabled = isHapticFeedbackEnabled
        self.isAutoProgressViewEnabled = isAutoProgressViewEnabled
        self.fillWidth = fillWidth
        self.confirmationDialogProvider = confirmationDialog
        self.alertProvider = alert
        self.action = action
        self.label = label
    }
    
    /// Creates a new instance of `AsyncButton`
    /// - Parameters:
    ///   - taskPriority: The optional TaskPriority. Default value `nil`
    ///   - isHapticFeedbackEnabled: Bool value if HapticFeedback is enabled. Default value `true`
    ///   - isAutoProgressViewEnabled: Bool value if automatically showing
    ///     a progress view is enabled. Default value `true`
    ///   - fillWidth: Bool value if the width of the button should be expanded. Default value `false`
    ///   - confirmationDialog: An optional closure to show a confirmation dialog. Default value `nil`
    ///   - alert: An optional closure to show an alert after the action finishes. Default value `nil`
    ///   - action: The action to perform when the user triggers the button
    ///   - label: A view that describes the purpose of the button's action
    init(
        taskPriority: TaskPriority? = nil,
        isHapticFeedbackEnabled: Bool = true,
        isAutoProgressViewEnabled: Bool = true,
        fillWidth: Bool = false,
        confirmationDialog: ConfirmationDialogProvider? = nil,
        alert: AlertProvider? = nil,
        action: @escaping Action,
        @ViewBuilder
        label: @escaping () -> Label
    ) {
        self.init(
            taskPriority: taskPriority,
            isHapticFeedbackEnabled: isHapticFeedbackEnabled,
            isAutoProgressViewEnabled: isAutoProgressViewEnabled,
            fillWidth: fillWidth,
            confirmationDialog: confirmationDialog,
            alert: alert,
            action: action,
            label: { _ in label() }
        )
    }
    
}

// MARK: - View

extension AsyncButton: View {
    
    /// The content and behavior of the view
    var body: some View {
        Button {
            // Check if a confirmation dialog is available
            if let confirmationDialog = self.confirmationDialogProvider?(self.perform) {
                // Set confirmation dialog
                self.confirmationDialog = .init(confirmationDialog)
            } else {
                // Otherwise perform action
                self.perform()
            }
        } label: {
            HStack(spacing: 10) {
                if self.fillWidth {
                    Spacer()
                }
                // Check if auto progress view is enabled and is busy
                if self.isAutoProgressViewEnabled && self.state == .busy {
                    ProgressView()
                        .controlSize(.regular)
                }
                self.label(self.state)
                if self.fillWidth {
                    Spacer()
                }
            }
        }
        .disabled(self.state == .busy)
        .alert(
            item: self.$alert,
            content: \.value
        )
        .actionSheet(
            item: self.$confirmationDialog,
            content: \.value
        )
        .onAppear {
            // Verify haptic feedback is enabled
            guard self.isHapticFeedbackEnabled else {
                // Otherwise return out of function
                return
            }
            // Prepare impact feedback generator
            self.impactFeedbackGenerator.prepare()
        }
        .preference(
            key: AsyncButtonState.PreferenceKey.self,
            value: self.state
        )
    }
    
}

// MARK: - Perform

private extension AsyncButton {
    
    /// Perform action
    func perform() {
        // Check if haptic feedback is enabled
        if self.isHapticFeedbackEnabled {
            // Invoke impact feedback
            self.impactFeedbackGenerator.impactOccurred()
        }
        // Perform Task
        Task(
            priority: self.taskPriority
        ) {
            // Perform Action
            await self.perform()
        }
    }
    
    /// Perform action asynchronously
    func perform() async {
        // Set state to busy
        self.state = .busy
        // Defer
        defer {
            // Reset state to idle
            self.state = .idle
        }
        // Check if haptic feedback is enabled
        if self.isHapticFeedbackEnabled {
            // Prepare UINotificationFeedbackGenerator
            await self.notificationFeedbackGenerator.prepare()
        }
        // Initialize Result
        let result: Result<Success, Error> = await {
            do {
                // Try to perform action
                let success = try await self.action()
                // Initialize Result with success
                return .success(success)
            } catch {
                // Initialize Result with failure
                return .failure(error)
            }
        }()
        // Check if haptic feedback is enabled
        if self.isHapticFeedbackEnabled {
            // Invoke notification haptic feedback
            await self.notificationFeedbackGenerator
                .notificationOccurred({
                    switch result {
                    case .success:
                        return .success
                    case .failure:
                        return .error
                    }
                }())
        }
        // Verify an alert is availabl
        guard let alert = self.alertProvider?(result) else {
            // Otherwise return out of function
            return
        }
        // Set Alert item
        self.alert = .init(alert)
    }
    
}
