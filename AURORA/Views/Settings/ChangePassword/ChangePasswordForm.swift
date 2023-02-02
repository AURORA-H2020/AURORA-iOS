import SwiftUI

// MARK: - ChangePasswordForm

/// The ChangePasswordForm
struct ChangePasswordForm {
    
    /// The current password.
    @State
    private var currentPassword = String()
    
    /// The password.
    @State
    private var password = String()
    
    /// The password confirmation.
    @State
    private var passwordConfirmation = String()
    
    /// The dismiss action
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - Can Submit

private extension ChangePasswordForm {
    
    /// Bool value if Form can be submitted
    var canSubmit: Bool {
        // Verify current password is not empty and
        // password & password-confirmation are valid
        !self.currentPassword.isEmpty
            && Password(
                password: self.password,
                passwordConfirmation: self.passwordConfirmation
            )
            .isValid
    }
    
}

// MARK: - View

extension ChangePasswordForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
                header: Text("Current Password")
            ) {
                SecureField(
                    "Current Password",
                    text: self.$currentPassword
                )
                .textContentType(.password)
            }
            .headerProminence(.increased)
            Section(
                header: Text("New Password"),
                footer: VStack(alignment: .leading) {
                    if !self.password.isEmpty {
                        let password = Password(
                            password: self.password,
                            passwordConfirmation: self.passwordConfirmation
                        )
                        if !password.validationErrors.isEmpty {
                            ForEach(password.validationErrors, id: \.self) { validationError in
                                if validationError == .mismatchingConfirmation
                                    && self.passwordConfirmation.isEmpty {
                                    EmptyView()
                                } else {
                                    Text(
                                        verbatim: "• \(validationError.localizedDescription)"
                                    )
                                }
                            }
                        }
                    }
                }
                .multilineTextAlignment(.leading)
            ) {
                SecureField(
                    "New Password",
                    text: self.$password
                )
                .textContentType(.newPassword)
                SecureField(
                    "Confirm new password",
                    text: self.$passwordConfirmation
                )
            }
            .headerProminence(.increased)
            Section(
                footer: AsyncButton(
                    fillWidth: true,
                    alert: self.alert,
                    action: {
                        try await self.firebase
                            .authentication
                            .updatePassword(
                                newPassword: self.password,
                                currentPassword: self.currentPassword
                            )
                    },
                    label: {
                        Text("Submit")
                            .font(.headline)
                    }
                )
                .disabled(!self.canSubmit)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
            ) {
            }
        }
        .navigationTitle("Change Password")
    }
    
}

// MARK: - Alert

private extension ChangePasswordForm {
    
    /// Make Alert for a given Result
    /// - Parameter result: The Result
    func alert(
        for result: Result<Void, Error>
    ) -> Alert? {
        switch result {
        case .success:
            return .init(
                title: Text("Password changed"),
                message: Text("Your Password has successfully been changed."),
                dismissButton: .default(
                    Text("Okay"),
                    action: self.dismiss.callAsFunction
                )
            )
        case .failure:
            return .init(
                title: Text("Error"),
                message: Text(
                    "An error occurred while trying to update your password. Please check your inputs and try again."
                )
            )
        }
    }
    
}
