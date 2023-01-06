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
    
    /// Bool value if can submit
    var canSubmit: Bool {
        !self.mailAddress.isEmpty && !self.password.isEmpty
    }
    
    /// Submit
    func submit() async {
        self.isBusy = true
        defer {
            self.isBusy = false
        }
        do {
            try await self.firebase.login(
                using: .password(
                    email: self.mailAddress,
                    password: self.password
                )
            )
        } catch {
            self.loginHasFailed = true
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
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        TextField(
                            "E-Mail",
                            text: self.$mailAddress
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        SecureField(
                            "Password",
                            text: self.$password
                        )
                        .textContentType(.password)
                    }
                    .textFieldStyle(InputTextFieldStyle())
                    Button {
                        Task {
                            await self.submit()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if self.isBusy {
                                ProgressView()
                                    .controlSize(.regular)
                            }
                            Text("Login")
                                .font(.headline)
                        }
                        .align(.centerHorizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!self.canSubmit)
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
        .alert(
            "Error",
            isPresented: self.$loginHasFailed,
            actions: EmptyView.init,
            message: {
                Text("An error occurred. Please check your inputs and try again.")
            }
        )
    }
    
}

// MARK: - InputTextFieldStyle

private extension AuthenticationContentView {
    
    /// The InputTextFieldStyle
    struct InputTextFieldStyle: TextFieldStyle {
        
        /// Configure Body
        /// - Parameter configuration: The Configuration
        func _body(
            configuration: TextField<Self._Label>
        ) -> some View {
            configuration
                .padding(
                    .init(
                        top: 15,
                        leading: 12,
                        bottom: 15,
                        trailing: 12
                    )
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: 8
                    )
                    .foregroundColor(Color(.systemBackground))
                )
        }
        
    }
    
}
