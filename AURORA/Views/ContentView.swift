import SwiftUI

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
                        ).accessibilityIdentifier("homeTab")
                    }
                    PhotovoltaicScreen(
                        firebase: self.firebase
                    )
                    .tabItem {
                        Label(
                            "Solar Power",
                            systemImage: "sun.max"
                        ).accessibilityIdentifier("solarPowerTab")
                    }
                    SettingsScreen()
                        .tabItem {
                            Label(
                                "Settings",
                                systemImage: "gear"
                            ).accessibilityIdentifier("settingsTab")
                        }
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
