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
    
    /// Bool value if AuthenticationPasswordLoginForm is presented
    @State
    private var isPasswordLoginFormPresented = false
    
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
    
    /// Login using authentication method
    /// - Parameter authenticationMethod: The authentication method
    func login(
        using authenticationMethod: FirebaseKit.Firebase.Authentication.Method
    ) async {
        guard !self.isBusy else {
            return
        }
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
        }
    }
    
}

// MARK: - View

extension AuthenticationContentView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        OrientationReader(
            transaction: .init(animation: .default)
        ) { orientation in
            ZStack(alignment: .top) {
                GeometryReader { geometry in
                    Image(
                        "background",
                        bundle: .module
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
                    VStack(spacing: 52) {
                        if !orientation.isLandscape {
                            Image(
                                "logo",
                                bundle: .module
                            )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        }
                        VStack {
                            Text(
                                verbatim: "Welcome to AURORA"
                            )
                            .font(.largeTitle.weight(.semibold))
                            Text(
                                verbatim: "Empowering a new generation of\nnear zero-emission citizens"
                            )
                            .foregroundColor(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        VStack(
                            spacing: AuthenticationProviderButton.preferredStackSpacing
                        ) {
                            AuthenticationProviderButton(style: .apple) {
                                Task {
                                    await self.login(using: .provider(.apple))
                                }
                            }
                            AuthenticationProviderButton(style: .google) {
                                Task {
                                    await self.login(using: .provider(.google))
                                }
                            }
                            AuthenticationProviderButton(style: .mailAddress) {
                                guard !self.isBusy else {
                                    return
                                }
                                self.isPasswordLoginFormPresented = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 48)
                }
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
                    verbatim: "The login has failed."
                )
            }
        )
    }
    
}
