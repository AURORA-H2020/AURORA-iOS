import SwiftUI

// MARK: - AuthenticationForgotPasswordForm

/// The AuthenticationForgotPasswordForm
struct AuthenticationForgotPasswordForm {
    
    // MARK: Properties
    
    /// The mail address
    @State
    private var mailAddress: String
    
    /// The AsyncButtonState
    @State
    private var asyncButtonState: AsyncButtonState = .idle
    
    /// Bool value if a TextField is focused
    @FocusState
    private var isTextFieldFocused
    
    /// The dismiss action
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `ForgotPasswordForm`
    /// - Parameter mailAddress: The initial mail address.
    init(
        mailAddress: String
    ) {
        self._mailAddress = .init(
            initialValue: mailAddress
        )
    }
    
}

// MARK: - View

extension AuthenticationForgotPasswordForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
                header: Text("E-Mail Address"),
                footer: Text("An E-Mail will be sent to your inbox containing a link to reset your password.")
            ) {
                TextField(
                    "E-Mail",
                    text: self.$mailAddress
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .focused(self.$isTextFieldFocused)
            }
            .headerProminence(.increased)
            Section(
                footer: AsyncButton(
                    fillWidth: true,
                    alert: { result in
                        switch result {
                        case .success:
                            return .init(
                                title: Text("Password reset"),
                                message: Text(
                                    "You will shortly receive an E-Mail to reset your password."
                                ),
                                dismissButton: .default(
                                    Text("Okay"),
                                    action: self.dismiss.callAsFunction
                                )
                            )
                        case .failure:
                            return .init(
                                title: Text("Error"),
                                message: Text(
                                    // swiftlint:disable:next line_length
                                    "An error occurred while trying to reset your password. Please check your E-Mail address and try again."
                                )
                            )
                        }
                    },
                    action: {
                        self.isTextFieldFocused = false
                        try await self.firebase
                            .authentication
                            .sendPasswordReset(
                                to: self.mailAddress
                            )
                    },
                    label: {
                        Text("Reset Password")
                            .font(.headline)
                    }
                )
                .onStateChange { state in
                    self.asyncButtonState = state
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
                .disabled(!self.mailAddress.isMailAddress)
            ) {
            }
        }
        .navigationTitle("Forgot Password")
        .disabled(self.asyncButtonState == .busy)
        .interactiveDismissDisabled(self.asyncButtonState == .busy)
    }
    
}
