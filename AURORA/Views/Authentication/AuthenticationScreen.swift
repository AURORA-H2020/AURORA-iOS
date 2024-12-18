import SwiftUI

// MARK: - AuthenticationScreen

/// The AuthenticationScreen
struct AuthenticationScreen {
    
    /// Bool value if View is busy
    @State
    private var isBusy = false
    
    /// Bool value if AuthenticationPasswordLoginForm is presented
    @State
    private var isPasswordLoginFormPresented = false
    
    /// The login error.
    @State
    private var loginError: Identified<Error>?
    
    /// The vertical size class.
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass
    
    /// The horizontal size class.
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    /// Bool value if is landscape.
    private var isLandscape: Bool {
        (
            self.horizontalSizeClass == .compact
                || self.horizontalSizeClass == .regular
        )
        &&
        self.verticalSizeClass == .compact
    }
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - Submit

private extension AuthenticationScreen {
    
    /// Login using authentication provider
    /// - Parameter provider: The authentication provider
    func login(
        using provider: Firebase.Authentication.Provider
    ) async {
        // Verify is currently not busy
        guard !self.isBusy else {
            // Otherwise return out of function
            return
        }
        // Enable isBusy
        self.isBusy = true
        // Defer
        defer {
            // Disable isBusy
            self.isBusy = false
        }
        do {
            // Try to login using provider
            try await self.firebase
                .authentication
                .login(using: .provider(provider))
        } catch is CancellationError {
            // User cancelled login
            // Simply return out of function
            return
        } catch {
            // Set login error
            self.loginError = .init(error)
        }
    }
    
}

// MARK: - View

extension AuthenticationScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                Image(
                    "Login-Background"
                )
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    height: geometry.frame(in: .local).size.height / 1.6
                )
                .mask {
                    LinearGradient(
                        gradient: .init(
                            stops: [
                                .init(color: .black, location: 0),
                                .init(color: .clear, location: 1),
                                .init(color: .black, location: 1),
                                .init(color: .clear, location: 1)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
            }
            VStack {
                Spacer()
                VStack(spacing: !self.isLandscape ? 50 : 25) {
                    if !self.isLandscape {
                        Image(
                            "AURORA-Logo"
                        )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    }
                    VStack {
                        Text("Your performance")
                            .font(.largeTitle.weight(.semibold))
                    }
                    .multilineTextAlignment(.center)
                    VStack(spacing: 25) {
                        VStack(
                            spacing: AuthenticationProviderButton.preferredStackSpacing
                        ) {
                            AuthenticationProviderButton(style: .apple) {
                                Task {
                                    await self.login(using: .apple)
                                }
                            }
                            AuthenticationProviderButton(style: .google) {
                                Task {
                                    await self.login(using: .google)
                                }
                            }
                            AuthenticationProviderButton(style: .mailAddress) {
                                guard !self.isBusy else {
                                    return
                                }
                                self.isPasswordLoginFormPresented = true
                            }
                        }
                        Text(
                            "This app was developed by the AURORA Horizon 2020 EU-funded project (No. [101036418](https://cordis.europa.eu/project/id/101036418)). Your data is processed by members of the project consortium and securely stored in Google Firebase. Your data will only be used for research purposes in an anonymised format and never commercially without your explicit consent. You can modify, download or delete your data at any time or reach out to our support under [app-support@aurora-h2020.eu](mailto:app-support@aurora-h2020.eu). By proceeding you agree to the AURORA’s [Terms of Service](\(AURORAWebsiteLink.appTermsOfServices.absoluteString)) and [Privacy Policy](\(AURORAWebsiteLink.appPrivacyPolicy.absoluteString))."
                        )
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
            }
        }
        .sheet(
            isPresented: self.$isPasswordLoginFormPresented
        ) {
            SheetNavigationView {
                AuthenticationPasswordLoginForm()
            }
            .environmentObject(self.firebase)
        }
        .alert(
            item: self.$loginError
        ) { loginError in
            .init(
                title: Text("Login failed"),
                message: Text(
                    "An error occurred while logging in. Please try again.\n\n\(loginError.value.localizedDescription)"
                )
            )
        }
    }
    
}
