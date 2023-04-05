import SwiftUI

// MARK: - AuthenticationPasswordLoginForm

/// The AuthenticationPasswordLoginForm
struct AuthenticationPasswordLoginForm {
    
    /// The PasswordMethod
    @State
    private var method: Firebase.Authentication.PasswordMethod = .login
    
    /// The mail address
    @State
    private var mailAddress = String()
    
    /// The password
    @State
    private var password = String()
    
    /// The password confirmation
    @State
    private var passwordConfirmation = String()
    
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

// MARK: - Can Submit

private extension AuthenticationPasswordLoginForm {
    
    /// Bool value if Form can be submitted
    var canSubmit: Bool {
        switch self.method {
        case .login:
            // Verify mail address is valid and password is not empty
            return self.mailAddress.isMailAddress && !self.password.isEmpty
        case .register:
            // Verify mail address and password & password-confirmation are valid
            return self.mailAddress.isMailAddress
                && Password(
                    password: self.password,
                    passwordConfirmation: self.passwordConfirmation
                )
                .isValid
        }
    }
    
}

// MARK: - View

extension AuthenticationPasswordLoginForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                Picker(
                    "",
                    selection: self.$method
                ) {
                    ForEach(
                        Firebase
                            .Authentication
                            .PasswordMethod
                            .allCases,
                        id: \.self
                    ) { method in
                        Text(method.localizedString)
                            .tag(method)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top)
                .onChange(
                    of: self.method
                ) { _ in
                    self.password.removeAll()
                    self.passwordConfirmation.removeAll()
                }
            }
            .listRowBackground(Color(.systemGroupedBackground))
            .listRowInsets(.init())
            Section(
                header: Text("Email")
            ) {
                TextField(
                    "Email",
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
                header: Text("Password"),
                footer: VStack(alignment: .leading) {
                    if self.method == .register && !self.password.isEmpty {
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
                    "Password",
                    text: self.$password
                )
                .textContentType(self.method == .login ? .password : .newPassword)
                .focused(self.$isTextFieldFocused)
                if self.method == .register {
                    SecureField(
                        "Confirm Password",
                        text: self.$passwordConfirmation
                    )
                    .focused(self.$isTextFieldFocused)
                }
            }
            .headerProminence(.increased)
            Section(
                footer: VStack(spacing: 25) {
                    AsyncButton(
                        fillWidth: true,
                        alert: { result in
                            guard case .failure = result else {
                                return nil
                            }
                            switch self.method {
                            case .login:
                                return .init(
                                    title: Text("Login failed"),
                                    message: Text(
                                        "An error occurred while trying to login. Please check your inputs and try again."
                                    )
                                )
                            case .register:
                                return .init(
                                    title: Text("Registration failed"),
                                    message: Text(
                                        "An error occurred while trying to create a new account. Please check your inputs and try again."
                                    )
                                )
                            }
                        },
                        action: {
                            self.isTextFieldFocused = false
                            try await self.firebase
                                .authentication
                                .login(
                                    using: .password(
                                        method: self.method,
                                        email: self.mailAddress,
                                        password: self.password
                                    )
                                )
                            self.dismiss()
                        },
                        label: {
                            Text(self.method.localizedString)
                                .font(.headline)
                                .frame(minHeight: 36)
                        }
                    )
                    .onStateChange { state in
                        self.asyncButtonState = state
                    }
                    .buttonStyle(.borderedProminent)
                    .align(.centerHorizontal)
                    .disabled(!self.canSubmit)
                    if self.method == .login {
                        NavigationLink(
                            destination: AuthenticationForgotPasswordForm(
                                mailAddress: self.mailAddress
                            )
                        ) {
                            Text("Forgot Password")
                        }
                    }
                }
            ) {
            }
            .listRowInsets(.init())
        }
        .navigationTitle("Continue with email")
        .disabled(self.asyncButtonState == .busy)
        .interactiveDismissDisabled(self.asyncButtonState == .busy)
    }
    
}
