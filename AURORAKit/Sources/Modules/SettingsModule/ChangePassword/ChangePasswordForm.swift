import FirebaseKit
import ModuleKit
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

// MARK: - View

extension ChangePasswordForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
                header: Text(
                    verbatim: "Current Password"
                )
            ) {
                SecureField(
                    "Current Password",
                    text: self.$currentPassword
                )
                .textContentType(.newPassword)
            }
            .headerProminence(.increased)
            Section(
                header: Text(
                    verbatim: "New Password"
                )
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
                .textContentType(.newPassword)
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
                        Text(
                            verbatim: "Submit"
                        )
                        .font(.headline)
                    }
                )
                .disabled(
                    self.currentPassword.isEmpty
                        || self.password.isEmpty
                        || self.password != self.passwordConfirmation
                )
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
            ) {
            }
        }
        .navigationTitle("Change Password")
    }
    
}

private extension ChangePasswordForm {
    
    func alert(
        for result: Result<Void, Error>
    ) -> Alert? {
        switch result {
        case .success:
            return .init(
                title: .init(
                    verbatim: "Password changed"
                ),
                message: .init(
                    verbatim: "Your Password has successfully been changed."
                ),
                dismissButton: .default(
                    Text(verbatim: "Okay"),
                    action: self.dismiss.callAsFunction
                )
            )
        case .failure:
            return .init(
                title: .init(
                    verbatim: "Error"
                ),
                message: .init(
                    // swiftlint:disable:next line_length
                    verbatim: "An error occurred while trying to update your password. Please check your inputs and try again."
                )
            )
        }
    }
    
}
