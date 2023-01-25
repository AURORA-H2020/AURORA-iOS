import FirebaseKit
import ModuleKit
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
                header: Text(
                    verbatim: "E-Mail Address"
                ),
                footer: Text(
                    verbatim: "An E-Mail will be sent to your inbox containing a link to reset your password."
                )
            ) {
                TextField(
                    "E-Mail",
                    text: self.$mailAddress
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            }
            .headerProminence(.increased)
            Section(
                footer: AsyncButton(
                    fillWidth: true,
                    alert: { result in
                        switch result {
                        case .success:
                            return .init(
                                title: .init(
                                    verbatim: "Password reset"
                                ),
                                message: .init(
                                    verbatim: "You will shortly receive an E-Mail to reset your password."
                                ),
                                dismissButton: .default(
                                    .init(verbatim: "Okay"),
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
                                    verbatim: "An error occurred while trying to reset your password. Please check your E-Mail address and try again."
                                )
                            )
                        }
                    },
                    action: {
                        try await self.firebase
                            .authentication
                            .sendPasswordReset(
                                to: self.mailAddress
                            )
                    },
                    label: {
                        Text(
                            verbatim: "Reset Password"
                        )
                        .font(.headline)
                    }
                )
                .onStateChange { state in
                    self.asyncButtonState = state
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
                .disabled(self.mailAddress.isEmpty)
            ) {
            }
        }
        .navigationTitle("Forgot Password")
        .disabled(self.asyncButtonState == .busy)
        .interactiveDismissDisabled(self.asyncButtonState == .busy)
    }
    
}
