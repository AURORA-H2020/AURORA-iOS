import AuthenticationModule
import ConsumptionModule
import FirebaseKit
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
            switch self.firebase.authenticationState {
            case .authenticated:
                Group {
                    switch self.firebase.user {
                    case .success(let user):
                        Group {
                            if user == nil {
                                UserModule
                                    .UserContentView(
                                        mode: .create
                                    )
                            } else {
                                TabView {
                                    ConsumptionModule
                                        .ConsumptionContentView()
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
                            }
                        }
                        .environment(
                            \.user,
                             user
                        )
                    case .failure:
                        Text(
                            verbatim: "An error occurred while loading your profile."
                        )
                    case nil:
                        ProgressView()
                    }
                }
                .animation(
                    .default,
                    value: EquatableUserResult(
                        result: self.firebase.user
                    )
                )
            case .unauthenticated:
                AuthenticationModule
                    .AuthenticationContentView()
            }
        }
        .animation(
            .default,
            value: self.firebase.authenticationState
        )
    }
    
}

private extension ContentView {
    
    struct EquatableUserResult: Equatable {
        
        let result: Result<User?, Error>?
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs.result, rhs.result) {
            case (.success(let lhsUser), .success(let rhsUser)):
                return lhsUser == rhsUser
            case (.failure, .failure):
                return true
            default:
                return false
            }
        }
        
    }
    
}
