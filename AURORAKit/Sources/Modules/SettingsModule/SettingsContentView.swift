import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - SettingsContentView

/// The SettingsContentView
public struct SettingsContentView {
    
    // MARK: Properties
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `SettingsContentView`
    public init() {}
    
}

// MARK: - View

extension SettingsContentView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        NavigationView {
            List {
                self.accountSection
                self.notificationsSection
                self.privacySection
                self.legalSection
            }
            .navigationTitle("Settings")
        }
        .analyticsScreen(
            name: "Settings",
            class: "SettingsContentView"
        )
    }
    
}

private extension SettingsContentView {
    
    var accountSection: some View {
        Section(
            header: Text(verbatim: "Account")
        ) {
            if let email = try? self.firebase.authenticationState.user.email {
                Label(email, systemImage: "envelope.fill")
            }
            if (try? self.firebase.isLoggedInViaPassword) == true {
                Button {
                    
                } label: {
                    Label(
                        "Change E-Mail address",
                        systemImage: "envelope"
                    )
                }
                Button {
                    
                } label: {
                    Label(
                        "Change Password",
                        systemImage: "key"
                    )
                }
            }
            AsyncButton(
                confirmationDialog: { action in
                    .init(
                        title: .init(
                            verbatim: "Logout"
                        ),
                        message: .init(
                            verbatim: "Are you sure you want to log out?"
                        ),
                        buttons: [
                            .destructive(
                                .init(verbatim: "Logout"),
                                action: action
                            ),
                            .cancel()
                        ]
                    )
                },
                alert: { result in
                    guard case .failure = result else {
                        return nil
                    }
                    return .init(
                        title: Text(verbatim: "Error"),
                        message: Text(verbatim: "An error occurred while trying to logout.")
                    )
                },
                action: {
                    try self.firebase.logout()
                },
                label: {
                    Label(
                        "Logout",
                        systemImage: "arrow.up.forward.square"
                    )
                }
            )
            .foregroundColor(.red)
        }
        .headerProminence(.increased)
    }
    
}

private extension SettingsContentView {
    
    var notificationsSection: some View {
        Section(
            header: Text(verbatim: "Notifications")
        ) {
            NavigationLink(
                "Electricity bill reminder",
                destination: EmptyView()
            )
            NavigationLink(
                "Heating bill reminder",
                destination: EmptyView()
            )
            NavigationLink(
                "Mobility reminder",
                destination: EmptyView()
            )
        }
        .headerProminence(.increased)
    }
    
}

private extension SettingsContentView {
    
    var privacySection: some View {
        Section(
            header: Text(verbatim: "Data privacy")
        ) {
            AsyncButton(
                alert: { result in
                    switch result {
                    case .success:
                        return .init(
                            title: .init(
                                verbatim: "Download my data"
                            ),
                            message: .init(
                                verbatim: "Your data will be send to your E-Mail address. Please check your inbox."
                            )
                        )
                    case .failure:
                        return .init(
                            title: .init(
                                verbatim: "Error"
                            ),
                            message: .init(
                                verbatim: "An error occurred while trying to download your data."
                            )
                        )
                    }
                },
                action: {
                    try await self.firebase.sendDownloadDataRequest()
                },
                label: {
                    Label(
                        "Download my data",
                        systemImage: "square.and.arrow.down"
                    )
                }
            )
            AsyncButton(
                confirmationDialog: { action in
                    .init(
                        title: .init(
                            verbatim: "Account deletion"
                        ),
                        message: .init(
                            verbatim: "Are you sure you want to delete your account?"
                        ),
                        buttons: [
                            .destructive(
                                .init(verbatim: "Delete account"),
                                action: action
                            ),
                            .cancel()
                        ]
                    )
                },
                alert: { result in
                    guard case .failure = result else {
                        return nil
                    }
                    return .init(
                        title: .init(
                            verbatim: "Error"
                        ),
                        message: .init(
                            verbatim: "An error occurred while trying to delete your account."
                        )
                    )
                },
                action: {
                    try await self.firebase.deleteAccount()
                },
                label: {
                    Label(
                        "Delete my account",
                        systemImage: "trash"
                    )
                }
            )
            .foregroundColor(.red)
        }
        .headerProminence(.increased)
    }
    
}

private extension SettingsContentView {
    
    var legalSection: some View {
        Section(
            header: Text(verbatim: "Legal information")
        ) {
            Link(
                destination: .init(
                    string: "https://www.aurora-h2020.eu/aurora/privacy-policy/"
                )!
            ) {
                Label(
                    "Imprint",
                    systemImage: "info.circle.fill"
                )
            }
            Link(
                destination: .init(
                    string: "https://www.aurora-h2020.eu/aurora/privacy-policy/"
                )!
            ) {
                Label(
                    "Privacy policy",
                    systemImage: "lock.fill"
                )
            }
            NavigationLink(
                destination: ThirdPartyDependencyList()
            ) {
                Label(
                    "Licenses",
                    systemImage: "doc.append.fill"
                )
            }
        }
        .headerProminence(.increased)
    }
    
}
