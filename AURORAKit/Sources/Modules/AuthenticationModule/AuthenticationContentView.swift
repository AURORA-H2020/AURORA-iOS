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
    
    /// The Mode
    @State
    private var mode: Mode = .login
    
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

// MARK: - Mode

private extension AuthenticationContentView {
    
    /// A Mode
    enum Mode: String, Codable, Hashable, CaseIterable {
        /// Login
        case login
        /// Register
        case register
    }
    
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
            switch self.mode {
            case .login:
                try await self.firebase.login(
                    using: .password(
                        email: self.mailAddress,
                        password: self.password
                    )
                )
            case .register:
                try await self.firebase.register(
                    email: self.mailAddress,
                    password: self.password
                )
            }
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
                .padding(.top, 30)
                VStack(spacing: 20) {
                    Picker("", selection: self.$mode) {
                        ForEach(Mode.allCases, id: \.self) { mode in
                            Text(
                                verbatim: mode.rawValue.capitalized
                            )
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
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
                            Text("Submit")
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
