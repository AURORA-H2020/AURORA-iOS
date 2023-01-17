import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - AuthenticationContentView

/// The AuthenticationContentView
public struct AuthenticationContentView {
    
    // MARK: Properties
    
    /// Bool value if View is busy
    @State
    private var isBusy = false
    
    /// The E-Mail address
    @State
    private var mailAddress = String()
    
    /// The password
    @State
    private var password = String()
    
    /// Bool value if ForgotPasswordForm is presented
    @State
    private var isForgotPassswordFormPresented = false
    
    /// Bool value if login has failed
    @State
    private var loginHasFailed = false
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `AuthenticationContentView`
    public init() {}
    
}

// MARK: - Submit

private extension AuthenticationContentView {
    
    /// Submit form using authentication method
    /// - Parameter authenticationMethod: The authentication method
    func submit(
        using authenticationMethod: FirebaseKit.Firebase.Authentication.Method
    ) async {
        self.isBusy = true
        defer {
            self.isBusy = false
        }
        do {
            try await self.firebase
                .authentication
                .login(using: authenticationMethod)
        } catch {
            self.loginHasFailed = !(error is CancellationError)
            self.password.removeAll()
        }
    }
    
}

// MARK: - View

extension AuthenticationContentView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        ScrollView {
            VStack(spacing: 65) {
                Image(
                    "logo",
                    bundle: .module
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 70)
                .padding(.top, 65)
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        SignInWithAppleButton {
                            Task {
                                await self.submit(using: .apple)
                            }
                        }
                        SignInWithGoogleButton {
                            Task {
                                await self.submit(using: .google)
                            }
                        }
                    }
                    .controlSize(.large)
                    HStack(alignment: .center) {
                        Rectangle()
                            .frame(
                                height: 0.5
                            )
                        Text("or")
                            .font(.caption)
                        Rectangle()
                            .frame(
                                height: 0.5
                            )
                    }
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            InputField(
                                .email(self.$mailAddress)
                            )
                            InputField(
                                .password(self.$password)
                            )
                        }
                        Button {
                            InputField.endEditing()
                            Task {
                                await self.submit(
                                    using: .password(
                                        email: self.mailAddress,
                                        password: self.password
                                    )
                                )
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if self.isBusy {
                                    ProgressView()
                                        .controlSize(.regular)
                                }
                                Text("Log In")
                                    .font(.headline)
                            }
                            .align(.centerHorizontal)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(self.mailAddress.isEmpty || self.password.isEmpty)
                        Button {
                            self.isForgotPassswordFormPresented = true
                        } label: {
                            Text(
                                verbatim: "Forgot Password"
                            )
                            .font(.subheadline.weight(.semibold))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(
            Image(
                "background",
                bundle: .module
            )
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .blur(radius: 40)
        )
        .overlay(alignment: .top) {
            Color
                .clear
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 0)
        }
        .preferredColorScheme(.light)
        .disabled(self.isBusy)
        .sheet(
            isPresented: self.$isForgotPassswordFormPresented
        ) {
            SheetNavigationView {
                ForgotPasswordForm(
                    mailAddress: self.mailAddress
                )
            }
            .environmentObject(self.firebase)
        }
        .alert(
            "Login failed",
            isPresented: self.$loginHasFailed,
            actions: {
                Button {
                } label: {
                    Text(verbatim: "Okay")
                }
            },
            message: {
                Text(
                    verbatim: "The login has failed. Please check your inputs and try again."
                )
            }
        )
    }
    
}
