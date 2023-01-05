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
        if self.firebase.isAuthenticated {
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
        } else {
            AuthenticationModule
                .AuthenticationContentView()
        }
    }
    
}
