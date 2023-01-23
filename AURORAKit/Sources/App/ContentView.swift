import AuthenticationModule
import ConsumptionModule
import FirebaseKit
import LocalNotificationKit
import ModuleKit
import SettingsModule
import SwiftUI
import UserModule

// MARK: - ContentView

/// The ContentView
struct ContentView {
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
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
            value: self.firebase.authentication.user,
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
        switch self.firebase.authentication.user {
        case .success(let user):
            if let user = user {
                TabView {
                    ConsumptionModule
                        .ConsumptionContentView(
                            user: user
                        )
                        .tabItem {
                            Label(
                                "Home",
                                systemImage: "chart.pie"
                            )
                        }
                    SettingsModule
                        .SettingsContentView()
                        .tabItem {
                            Label(
                                "Settings",
                                systemImage: "gear"
                            )
                        }
                }
            } else {
                UserModule
                    .CreateUserContentView()
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
        AuthenticationModule
            .AuthenticationContentView()
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
            }
    }
    
}
