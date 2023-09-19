import FirebaseRemoteConfigSwift
import SwiftUI

// MARK: - ContentView

/// The ContentView
struct ContentView {
    
    /// Bool value if legal update consent form is presented
    @State
    private var isLegalUpdateConsentFormPresented = false
    
    /// The latest legal documents version
    @RemoteConfigProperty(
        key: Firebase.RemoteConfig.latestLegalDocumentsVersionKey,
        fallback: 0
    )
    private var latestLegalDocumentsVersion: Int
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - Present Legal Update Consent Form if needed

private extension ContentView {
    
    /// Present legal update consent form if needed.
    /// - Parameters:
    ///   - user: The user.
    ///   - latestLegalDocumentsVersion: The latest legal document version.
    func presentLegalUpdateConsentFormIfNeeded(
        user: User,
        latestLegalDocumentsVersion: Int
    ) {
        self.isLegalUpdateConsentFormPresented = {
            guard !ProcessInfo.processInfo.isRunningUITests else {
                return false
            }
            if let acceptedLegalDocumentVersion = user.acceptedLegalDocumentVersion {
                return latestLegalDocumentsVersion > acceptedLegalDocumentVersion
            } else {
                return true
            }
        }()
    }
    
}

// MARK: - View

extension ContentView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Group {
            switch self.firebase.authentication.state {
            case .authenticated:
                self.authenticated
            case .unauthenticated:
                self.unauthenticated
            }
        }
        .task {
            try? await LocalNotificationCenter
                .current
                .resetBadgeCount()
        }
        .onAppear {
            LocalNotificationCenter
                .current
                .removeAllDeliveredNotifications()
        }
        .animation(
            .default,
            value: self.firebase.authentication.state
        )
        .animation(
            .default,
            value: self.firebase.user,
            by: { lhs, rhs in
                switch (lhs, rhs) {
                case (.success(let lhsUser), .success(let rhsUser)):
                    return lhsUser == rhsUser
                case (.failure, .failure):
                    return true
                default:
                    return false
                }
            }
        )
    }
    
}

// MARK: - Authenticated

private extension ContentView {
    
    /// The authenticated view.
    @ViewBuilder
    var authenticated: some View {
        switch self.firebase.user {
        case .success(let user):
            if let user = user {
                TabView {
                    ConsumptionScreen(
                        user: user
                    )
                    .tabItem {
                        Label(
                            "Home",
                            systemImage: "house"
                        )
                        .accessibilityIdentifier("HomeTab")
                    }
                    PhotovoltaicScreen(
                        firebase: self.firebase
                    )
                    .tabItem {
                        Label(
                            "Solar Power",
                            systemImage: "sun.max"
                        )
                        .accessibilityIdentifier("SolarPowerTab")
                    }
                    SettingsScreen()
                        .tabItem {
                            Label(
                                "Settings",
                                systemImage: "gear"
                            )
                            .accessibilityIdentifier("SettingsTab")
                        }
                }
                .onAppear {
                    self.presentLegalUpdateConsentFormIfNeeded(
                        user: user,
                        latestLegalDocumentsVersion: self.latestLegalDocumentsVersion
                    )
                }
                .onChange(
                    of: self.latestLegalDocumentsVersion
                ) { latestLegalDocumentsVersion in
                    self.presentLegalUpdateConsentFormIfNeeded(
                        user: user,
                        latestLegalDocumentsVersion: latestLegalDocumentsVersion
                    )
                }
                .sheet(
                    isPresented: self.$isLegalUpdateConsentFormPresented
                ) {
                    LegalUpdateConsentForm(
                        latestLegalDocumentsVersion: self.latestLegalDocumentsVersion,
                        user: user
                    )
                    .interactiveDismissDisabled(true)
                    .environmentObject(self.firebase)
                }
            } else {
                CreateUserForm()
            }
        case .failure:
            EmptyPlaceholder(
                systemImage: "wifi.exclamationmark",
                title: "Error",
                subtitle: "An error occurred while loading your profile.",
                primaryAction: .init(
                    title: "Reload",
                    action: self.firebase.authentication.reloadUser
                )
            )
        case nil:
            ProgressView()
                .delay(
                    by: .init(
                        value: 2,
                        unit: .seconds
                    ),
                    animation: .default
                )
        }
    }
    
}

// MARK: - Unauthenticated

private extension ContentView {
    
    /// The unauthenticated view.
    var unauthenticated: some View {
        AuthenticationScreen()
            .task {
                try? await LocalNotificationCenter
                    .current
                    .resetBadgeCount()
            }
            .onAppear {
                LocalNotificationCenter
                    .current
                    .removeAllPendingNotificationRequests()
                LocalNotificationCenter
                    .current
                    .removeAllDeliveredNotifications()
                RecurringConsumptionsReminderService
                    .shared
                    .reset()
            }
    }
    
}
