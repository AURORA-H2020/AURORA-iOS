import FirebaseAnalyticsSwift
import SwiftUI

// MARK: - SettingsContentView

/// The SettingsContentView
struct SettingsContentView {
    
    // MARK: Properties
    
    /// Bool value if change mail address form is presented
    @State
    private var isChangeMailAddressFormPresented = false
    
    /// Bool value if change password form is presented
    @State
    private var isChangePasswordFormPresented = false
    
    /// Bool value if feature preview is presented
    @State
    private var isFeaturePreviewPresented = false
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension SettingsContentView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                self.accountSection
                self.notificationsSection
                self.privacySection
                self.legalSection
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
        .analyticsScreen(
            name: "Settings",
            class: "SettingsContentView"
        )
        .sheet(
            isPresented: self.$isChangeMailAddressFormPresented
        ) {
            SheetNavigationView {
                ChangeMailAddressForm()
            }
            .environmentObject(self.firebase)
        }
        .sheet(
            isPresented: self.$isChangePasswordFormPresented
        ) {
            SheetNavigationView {
                ChangePasswordForm()
            }
            .environmentObject(self.firebase)
        }
        .sheet(
            isPresented: self.$isFeaturePreviewPresented
        ) {
            SheetNavigationView {
                FeaturePreview()
            }
        }
    }
    
}

private extension SettingsContentView {
    
    var accountSection: some View {
        Section(
            header: Text("Account")
        ) {
            if (try? self.firebase.authentication.providers.contains(.password)) == true {
                Button {
                    self.isChangeMailAddressFormPresented = true
                } label: {
                    Label(
                        "Change E-Mail",
                        systemImage: "envelope"
                    )
                }
                Button {
                    self.isChangePasswordFormPresented = true
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
                        title: Text("Logout"),
                        message: Text("Are you sure you want to logout?"),
                        buttons: [
                            .destructive(
                                Text("Logout"),
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
                        title: Text("Error"),
                        message: Text("An error occurred while trying to logout.")
                    )
                },
                action: {
                    try self.firebase.authentication.logout()
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
            header: Text("Notifications")
        ) {
            NavigationLink(
                destination: LocalNotificationForm(
                    id: .electricityBillReminder
                )
            ) {
                Label(
                    "Electricity bill reminder",
                    systemImage: "bolt"
                )
            }
            NavigationLink(
                destination: LocalNotificationForm(
                    id: .heatingBillReminder
                )
            ) {
                Label(
                    "Heating bill reminder",
                    systemImage: "heater.vertical"
                )
            }
            NavigationLink(
                destination: LocalNotificationForm(
                    id: .mobilityReminder
                )
            ) {
                Label(
                    "Mobility reminder",
                    systemImage: "car"
                )
            }
        }
        .headerProminence(.increased)
    }
    
}

private extension SettingsContentView {
    
    var privacySection: some View {
        Section(
            header: Text("Data privacy")
        ) {
            AsyncButton(
                alert: { result in
                    switch result {
                    case .success(let userDataFile):
                        return .init(
                            title: Text("Export Data"),
                            message: Text(
                                "Your data has been successfully downloaded. Do you want to export it?"
                            ),
                            primaryButton: .default(Text("Export")) {
                                self.export(userDataFile: userDataFile)
                            },
                            secondaryButton: .cancel()
                        )
                    case .failure:
                        return .init(
                            title: Text("Error"),
                            message: Text(
                                "An error occurred while trying to download your data."
                            )
                        )
                    }
                },
                action: {
                    try await self.firebase.functions.downloadUserData()
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
                        title: Text("Account deletion"),
                        message: Text(
                            "Are you sure you want to delete your account?"
                        ),
                        buttons: [
                            .destructive(
                                Text("Delete account"),
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
                        title: Text("Error"),
                        message: Text(
                            "An error occurred while trying to delete your account."
                        )
                    )
                },
                action: {
                    try await self.firebase.authentication.deleteAccount()
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

// MARK: - Export User Data

private extension SettingsContentView {
    
    /// Export user data file
    /// - Parameter userDataFile: The user data file url which should be exported.
    func export(
        userDataFile: URL
    ) {
        // Verify root ViewController is available
        guard let rootViewController = UIApplication
            .shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController else {
            // Otherwise return out of function
            return
        }
        // Initialize UIActivityViewController
        let activityViewController = UIActivityViewController(
            activityItems: [userDataFile],
            applicationActivities: nil
        )
        // Initialize source view
        let sourceView: UIView = rootViewController.view
        // Set source view
        activityViewController.popoverPresentationController?.sourceView = sourceView
        // Set source rect
        activityViewController.popoverPresentationController?.sourceRect = .init(
            x: sourceView.bounds.width / 2,
            y: sourceView.bounds.height / 2,
            width: 0,
            height: 0
        )
        // Present UIActivityViewController
        rootViewController
            .present(
                activityViewController,
                animated: true
            )
    }
    
}

private extension SettingsContentView {
    
    var legalSection: some View {
        Section(
            header: Text("Legal information")
        ) {
            Button {
                self.isFeaturePreviewPresented = true
            } label: {
                Label(
                    "Feature Preview",
                    systemImage: "wand.and.stars"
                )
            }
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
