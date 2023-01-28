import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - AuthenticationPasswordLoginForm

/// The AuthenticationPasswordLoginForm
struct AuthenticationPasswordLoginForm {
    
    /// The mail address
    @State
    private var mailAddress = String()
    
    /// The password
    @State
    private var password = String()
    
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
    
}

// MARK: - View

extension AuthenticationPasswordLoginForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
                header: Text(verbatim: "E-Mail")
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
                header: Text(verbatim: "Password")
            ) {
                SecureField(
                    "Password",
                    text: self.$password
                )
                .textContentType(.password)
                .focused(self.$isTextFieldFocused)
            }
            .headerProminence(.increased)
            Section(
                footer: VStack(spacing: 20) {
                    AsyncButton(
                        fillWidth: true,
                        alert: { result in
                            guard case .failure = result else {
                                return nil
                            }
                            return .init(
                                title: .init(
                                    verbatim: "Login failed"
                                ),
                                message: .init(
                                    // swiftlint:disable:next line_length
                                    verbatim: "An error occurred while trying to login. Please check your inputs and try again."
                                )
                            )
                        },
                        action: {
                            self.isTextFieldFocused = false
                            try await self.firebase
                                .authentication
                                .login(
                                    using: .password(
                                        email: self.mailAddress,
                                        password: self.password
                                    )
                                )
                            self.dismiss()
                        },
                        label: {
                            Text(
                                verbatim: "Continue"
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
                    .disabled(MailAddress(self.mailAddress) == nil || self.password.isEmpty)
                    NavigationLink(
                        destination: AuthenticationForgotPasswordForm(
                            mailAddress: self.mailAddress
                        )
                    ) {
                        Text(
                            verbatim: "Forgot Password"
                        )
                    }
                }
            ) {
            }
        }
        .navigationTitle("Continue with E-Mail")
        .disabled(self.asyncButtonState == .busy)
        .interactiveDismissDisabled(self.asyncButtonState == .busy)
        .onDisappear(perform: MailAddress.clearCache)
    }
    
}
